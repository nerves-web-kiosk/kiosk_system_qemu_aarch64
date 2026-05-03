# SPDX-FileCopyrightText: 2025 Lars Wikman
#
# SPDX-License-Identifier: Apache-2.0

defmodule Mix.Tasks.Nerves.Gen.Qemu do
  @moduledoc "Generate qemu command line for the current environment"
  @shortdoc "Generate qemu command line"

  use Mix.Task

  alias KioskSystemQemuAarch64.Qemu

  @impl Mix.Task
  def run(args) do
    fw_path =
      case args do
        [fw_path] ->
          fw_path

        [] ->
          Nerves.Env.firmware_path()

        _ ->
          Mix.shell().error(
            "Multiple arguments provided. Task only accepts no arguments or the single firmware path as an argument."
          )

          System.halt(1)
      end

    disk_path = "virtual-disk.img"
    Qemu.create_disk_image(fw_path, disk_path)

    cmd = Qemu.command_line(Qemu.bootloader_path(), disk_path)
    Mix.shell().info("Command:\n#{cmd}")
  end
end
