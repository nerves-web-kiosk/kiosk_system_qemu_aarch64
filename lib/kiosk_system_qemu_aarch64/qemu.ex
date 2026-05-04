# SPDX-FileCopyrightText: 2026 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0

defmodule KioskSystemQemuAarch64.Qemu do
  @moduledoc false
  # Shared helpers for the `nerves.gen.qemu` and `nerves.qemu` mix tasks.

  @qemu_executable "qemu-system-aarch64"

  @doc "Name of the qemu executable to invoke."
  @spec executable() :: String.t()
  def executable(), do: @qemu_executable

  @doc """
  Build the argv list passed to qemu.

  This is the canonical source of qemu options — both the shell-pasteable
  command string and the `InteractiveCmd.cmd/3` invocation derive from it.
  """
  @spec args(String.t(), String.t()) :: [String.t()]
  def args(bootloader, disk_path) do
    {machine, cpu} = host_machine_and_cpu()

    [
      "-machine", machine,
      "-cpu", cpu,
      "-smp", "4",
      "-m", "2G",
      "-kernel", bootloader,
      "-netdev", "user,id=eth0,hostfwd=tcp:127.0.0.1:10022-:22,hostfwd=tcp:127.0.0.1:14000-:4000,hostfwd=tcp:127.0.0.1:19222-:9222",
      "-device", "virtio-net-device,netdev=eth0,mac=fe:db:ed:de:d0:01",
      "-global", "virtio-mmio.force-legacy=false",
      "-drive", "if=none,file=#{disk_path},format=raw,id=vdisk",
      "-device", "virtio-blk-device,drive=vdisk,bus=virtio-mmio-bus.0",
      "-device", "virtio-gpu-gl-pci,edid=on,xres=1280,yres=720",
      "-device", "virtio-keyboard-pci",
      "-device", "virtio-tablet-pci",
      "-display", "gtk,gl=on,zoom-to-fit=off"
    ]
  end

  @doc "Format `args/2` as a human-readable, shell-pasteable command line."
  @spec command_line(String.t(), String.t()) :: String.t()
  def command_line(bootloader, disk_path) do
    [@qemu_executable | args(bootloader, disk_path)]
    |> Enum.chunk_every(2)
    |> Enum.map_join(" \\\n  ", &Enum.join(&1, " "))
  end

  @doc "Path to the bootloader ELF inside the active Nerves SDK images directory."
  @spec bootloader_path() :: String.t()
  def bootloader_path() do
    Path.join(System.fetch_env!("NERVES_SDK_IMAGES"), "little_loader.elf")
  end

  @doc """
  Run `fwup` to (re)create `disk_path` from the firmware at `fw_path`.

  Raises via `Mix.raise/1` if the firmware file is missing or fwup fails.
  """
  @spec create_disk_image(String.t(), String.t()) :: :ok
  def create_disk_image(fw_path, disk_path) do
    if !File.exists?(fw_path) do
      Mix.raise("Firmware not found at '#{fw_path}'. Run `mix firmware` first.")
    end

    File.rm(disk_path)
    Mix.shell().info("Creating disk image '#{disk_path}' from '#{fw_path}'...")

    case System.cmd("fwup", ["-a", "-i", fw_path, "-d", disk_path, "-t", "complete"],
           into: IO.stream()
         ) do
      {_, 0} -> :ok
      {_, status} -> Mix.raise("fwup exited with status #{status}")
    end
  end

  @doc """
  Pick the qemu `-machine` and `-cpu` values for the current host.

  Uses KVM on aarch64 Linux when available and HVF on Apple Silicon. Falls
  back to TCG with a generic `cortex-a76` model otherwise.
  """
  @spec host_machine_and_cpu() :: {String.t(), String.t()}
  def host_machine_and_cpu() do
    {a, o} = type = {arch(), os()}
    Mix.shell().info("Generating command line for arch '#{a}' on host OS '#{o}'.")

    case type do
      {:aarch64, :linux} ->
        if System.find_executable("kvm") != nil do
          Mix.shell().info("Detected KVM support.")
          {"virt,accel=kvm", "host"}
        else
          {"virt", "cortex-a76"}
        end

      {:aarch64, :macos} ->
        Mix.shell().info("Apple Silicon on MacOS, using HVF.")
        {"virt,accel=hvf", "host"}

      _ ->
        {"virt", "cortex-a76"}
    end
  end

  defp arch() do
    case to_string(:erlang.system_info(:system_architecture)) do
      "aarch64-" <> _ ->
        :aarch64

      a ->
        Mix.shell().info("Got arch #{a}, using 'other'.")
        :other
    end
  end

  defp os() do
    case :os.type() do
      {:unix, :linux} -> :linux
      {:unix, :darwin} -> :macos
      _ -> :other
    end
  end
end
