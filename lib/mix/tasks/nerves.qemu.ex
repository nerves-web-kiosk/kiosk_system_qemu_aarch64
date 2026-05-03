# SPDX-FileCopyrightText: 2026 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0

defmodule Mix.Tasks.Nerves.Qemu do
  @moduledoc """
  Run QEMU for the current Nerves environment.

  The disk image is created from the firmware on the first run and reused on
  subsequent runs. Pass `--force` to rebuild it from the current firmware.

  ## Command line options

    * `--force` (`-f`) - rebuild the disk image even if it already exists.
    * `--firmware <path>` (`-i`) - path to the `.fw` file. Defaults to the
      Nerves environment's firmware path.
    * `--disk <path>` (`-d`) - path to the virtual disk image. Defaults to
      `virtual-disk.img` in the current directory.
  """
  @shortdoc "Run QEMU"

  use Mix.Task

  alias KioskSystemQemuAarch64.Qemu

  @switches [force: :boolean, firmware: :string, disk: :string]
  @aliases [f: :force, i: :firmware, d: :disk]

  @impl Mix.Task
  def run(argv) do
    {opts, _argv, _} = OptionParser.parse(argv, switches: @switches, aliases: @aliases)

    fw_path = opts[:firmware] || Nerves.Env.firmware_path()
    disk_path = opts[:disk] || "virtual-disk.img"

    cond do
      opts[:force] == true ->
        Qemu.create_disk_image(fw_path, disk_path)

      File.exists?(disk_path) ->
        Mix.shell().info("Reusing existing disk image '#{disk_path}'. Pass --force to rebuild.")

      true ->
        Qemu.create_disk_image(fw_path, disk_path)
    end

    args = Qemu.args(Qemu.bootloader_path(), disk_path)

    Mix.shell().info("Starting #{Qemu.executable()}...")

    case InteractiveCmd.cmd(Qemu.executable(), args) do
      {_, 0} -> :ok
      {_, status} -> Mix.raise("#{Qemu.executable()} exited with status #{status}")
    end
  end
end
