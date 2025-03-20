# ZeroTier Restart Script

This PowerShell script stops the ZeroTier service, flushes the routing table, restarts the service, and reopens the ZeroTier UI. It includes error handling and validation to ensure the process completes successfully.

## Requirements

- Windows operating system
- ZeroTier One installed
- PowerShell with administrative privileges
- Execution policy set to allow running scripts (e.g., `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`)

## Usage

1. **Clone or Download the Repository**:
   Clone this repository or download the `restartzt.ps1` script:
   ```git clone <your-repo-url>```

2. **Run the Script as Administrator**:
   Open PowerShell as Administrator, navigate to the script directory, and run:
   ```.\restartzt.ps1```

3. **Verify the Output**:
   The script will output the status of each step. Ensure the final message indicates the ZeroTier service and UI have restarted successfully.

## Script Details

The `restartzt.ps1` script performs the following steps:
- Checks for administrative privileges
- Stops the ZeroTier service (`ZeroTierOneService`)
- Flushes the routing table using `netsh`
- Restarts the ZeroTier service
- Reopens the ZeroTier UI

If the service fails to stop, the script will attempt to kill ZeroTier processes and proceed. The script is located in the root of this repository.

## Troubleshooting

- **Service Won’t Stop**: Check Event Viewer (`eventvwr.msc`) under "Windows Logs > System" for errors related to `ZeroTierOneService`.
- **UI Doesn’t Restart**: Verify the path to `zerotier_desktop_ui.exe` in the script matches your installation. The default path is `C:\Program Files (x86)\ZeroTier\One\zerotier_desktop_ui.exe`.
- **Execution Policy Error**: Ensure the PowerShell execution policy allows scripts. Run `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned` if needed.

## License

This project is licensed under the MIT License.
