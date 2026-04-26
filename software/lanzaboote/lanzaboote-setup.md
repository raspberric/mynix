# Setting up Secure Boot with Lanzaboote & Windows 11 Dual Boot

This guide explains how to properly set up Secure Boot using Lanzaboote on your NixOS configuration, while keeping the ability to boot into Windows 11. 

⚠️ **IMPORTANT**: Because Windows 11 requires Secure Boot with Microsoft's keys, it is critical to follow the enrollment step exactly, otherwise you will be locked out of Windows 11.

## Prerequisites
- The NixOS configuration has been updated to include the `lanzaboote` module.
- Do **not** rebuild and reboot until you are ready to complete these steps sequentially.

---

## Step 1: Suspend BitLocker (Crucial First Step)
If your Windows 11 partition is encrypted with BitLocker, changing the Secure Boot keys and bootloader path will trip the TPM measurements and force a BitLocker Recovery prompt. You can avoid needing your recovery key entirely by suspending BitLocker *before* you begin.

1. Boot into **Windows 11**.
2. Open the Start menu and search for **Manage BitLocker**.
3. Click **Suspend protection** (Do not click "Turn off", just suspend).
4. Reboot your computer and boot into **NixOS**.

## Step 2: Generate Secure Boot Keys
Before rebooting again, we need to generate your own cryptographic keys. The module has installed `sbctl` which we will use for this.

Open a terminal and run:
```bash
sudo sbctl create-keys
```
This will generate custom keys and store them in `/var/lib/sbctl`. 

## Step 3: Verify Configuration
Verify that `sbctl` correctly sees your boot files. Run:
```bash
sudo sbctl verify
```
You should see that files like `systemd-bootx64.efi` and your Linux kernel images are listed. It's okay if they say "not signed" yet, Lanzaboote will sign them on your next rebuild, but this command confirms the tool works.

## Step 4: Enter UEFI / BIOS Setup Mode
Now we need to tell your motherboard to accept new Secure Boot keys.

1. Reboot your computer and enter your BIOS/UEFI settings (usually by pressing `F2`, `Del`, `F10`, or `F12` during startup).
2. Navigate to the **Security** or **Boot** tab.
3. Find the **Secure Boot** section.
4. You need to put Secure Boot into **Setup Mode**. This is usually done by selecting an option like:
   - "Reset to Setup Mode"
   - "Delete Platform Key (PK)"
   - "Clear Secure Boot Keys" (Be careful with this one, as some buggy firmwares wipe the dbx forbidden database. If given the choice, just delete the PK).
5. *(ASUS Motherboards only)*: Ensure the **OS Type** is set to "Windows UEFI mode".
6. Save your changes and reboot back into NixOS.

## Step 5: Enroll the Keys into Firmware
Now that your motherboard is in Setup Mode, we can push your newly generated keys into the firmware. 

**CRITICAL**: You MUST include the `--microsoft` flag. If you don't, Windows 11's bootloader (`bootmgfw.efi`) will be rejected by the motherboard and you won't be able to boot Windows.

Open a terminal in NixOS and run:
```bash
sudo sbctl enroll-keys --microsoft
```
*(Note: If you are using a Framework laptop, you should also append `--firmware-builtin` to keep vendor keys for firmware updates).*

You should see output indicating that the keys, along with vendor keys from Microsoft, were enrolled.

## Step 6: Enable Secure Boot
1. Reboot your computer and enter your BIOS/UEFI settings again.
2. Go back to the **Secure Boot** section.
3. Change the Secure Boot status from **Disabled** to **Enabled** (or User Mode).
4. Save your changes and boot into NixOS.

## Step 7: Verify Success
Once booted into NixOS, open a terminal and run:
```bash
bootctl status
```
Look for the `Secure Boot:` line. It should now say `enabled (user)`.

## Step 8: Resume BitLocker
Now that the new boot path and Secure Boot keys are established, we can resume BitLocker.

1. Reboot your computer and boot into **Windows 11** via the `systemd-boot` menu.
2. Because BitLocker was suspended, Windows will boot normally without asking for a recovery key.
3. Open **Manage BitLocker** and click **Resume protection**. 
4. The TPM will now reseal using the new measurements, and your dual boot Secure Boot setup is fully complete!
