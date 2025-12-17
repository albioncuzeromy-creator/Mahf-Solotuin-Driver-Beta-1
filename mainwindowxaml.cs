/*
 * Mahf Firmware CPU Driver - Control Panel Application
 * Copyright (c) 2024 Mahf Corporation
 * 
 * Windows Presentation Foundation (WPF) Control Panel
 * Version: 2.5.1
 */

using System;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Threading;
using Microsoft.Win32;

namespace MahfCPUControlPanel
{
    public partial class MainWindow : Window
    {
        // P/Invoke for driver communication
        [DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr CreateFile(
            string lpFileName,
            uint dwDesiredAccess,
            uint dwShareMode,
            IntPtr lpSecurityAttributes,
            uint dwCreationDisposition,
            uint dwFlagsAndAttributes,
            IntPtr hTemplateFile);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool DeviceIoControl(
            IntPtr hDevice,
            uint dwIoControlCode,
            IntPtr lpInBuffer,
            uint nInBufferSize,
            IntPtr lpOutBuffer,
            uint nOutBufferSize,
            out uint lpBytesReturned,
            IntPtr lpOverlapped);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool CloseHandle(IntPtr hObject);

        // Constants
        const uint GENERIC_READ = 0x80000000;
        const uint GENERIC_WRITE = 0x40000000;
        const uint OPEN_EXISTING = 3;
        const uint FILE_ATTRIBUTE_NORMAL = 0x80;

        const uint IOCTL_MAHF_GET_CPU_INFO = 0x222000;
        const uint IOCTL_MAHF_SET_PERFORMANCE = 0x222004;
        const uint IOCTL_MAHF_GET_PERFORMANCE = 0x222008;

        // Device handle
        private IntPtr driverHandle = IntPtr.Zero;
        private DispatcherTimer updateTimer;

        // Performance modes
        public enum PerformanceMode
        {
            PowerSave = 0,
            Balanced = 1,
            Performance = 2,
            Extreme = 3
        }

        // Structures matching driver definitions
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
        public struct CpuInfo
        {
            public uint CoreCount;
            public uint ThreadCount;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 13)]
            public string VendorString;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 49)]
            public string BrandString;
            public uint Family;
            public uint Model;
            public uint Stepping;
            public uint BaseFrequency;
            public uint MaxFrequency;
            public uint CurrentFrequency;
            public bool HyperThreading;
            public bool TurboBoost;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct PerformanceData
        {
            public PerformanceMode Mode;
            public uint Usage;
            public uint Temperature;
            public uint PowerConsumption;
            public uint CurrentFrequency;
            public uint Voltage;
        }

        public MainWindow()
        {
            InitializeComponent();
            InitializeDriver();
            InitializeTimer();
            LoadSystemInfo();
        }

        private void InitializeDriver()
        {
            try
            {
                // Open driver device
                driverHandle = CreateFile(
                    @"\\.\MahfCPU",
                    GENERIC_READ | GENERIC_WRITE,
                    0,
                    IntPtr.Zero,
                    OPEN_EXISTING,
                    FILE_ATTRIBUTE_NORMAL,
                    IntPtr.Zero);

                if (driverHandle == new IntPtr(-1))
                {
                    int error = Marshal.GetLastWin32Error();
                    MessageBox.Show(
                        "Mahf CPU Driver'a bağlanılamadı. Sürücünün yüklü olduğundan emin olun.\n\n" +
                        $"Error Code: {error}",
                        "Driver Connection Error",
                        MessageBoxButton.OK,
                        MessageBoxImage.Error);
                    
                    StatusLabel.Content = "Driver: Not Connected";
                    StatusLabel.Foreground = System.Windows.Media.Brushes.Red;
                }
                else
                {
                    StatusLabel.Content = "Driver: Connected";
                    StatusLabel.Foreground = System.Windows.Media.Brushes.Green;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Driver initialization error: {ex.Message}", 
                    "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void InitializeTimer()
        {
            updateTimer = new DispatcherTimer();
            updateTimer.Interval = TimeSpan.FromSeconds(1);
            updateTimer.Tick += UpdateTimer_Tick;
            updateTimer.Start();
        }

        private void LoadSystemInfo()
        {
            // Load from registry
            try
            {
                using (RegistryKey key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Mahf\CPU"))
                {
                    if (key != null)
                    {
                        string version = key.GetValue("Version")?.ToString() ?? "Unknown";
                        VersionLabel.Content = $"Version: {version}";
                    }
                }
            }
            catch { }

            // Get CPU info from driver
            if (driverHandle != IntPtr.Zero && driverHandle != new IntPtr(-1))
            {
                CpuInfo cpuInfo = GetCpuInfo();
                if (cpuInfo.CoreCount > 0)
                {
                    CpuNameLabel.Content = cpuInfo.BrandString;
                    CpuCoresLabel.Content = $"{cpuInfo.CoreCount} Cores / {cpuInfo.ThreadCount} Threads";
                    CpuVendorLabel.Content = cpuInfo.VendorString;
                    BaseFreqLabel.Content = $"Base: {cpuInfo.BaseFrequency} MHz";
                }
            }
        }

        private CpuInfo GetCpuInfo()
        {
            CpuInfo cpuInfo = new CpuInfo();
            
            if (driverHandle == IntPtr.Zero || driverHandle == new IntPtr(-1))
                return cpuInfo;

            int size = Marshal.SizeOf(typeof(CpuInfo));
            IntPtr buffer = Marshal.AllocHGlobal(size);

            try
            {
                uint bytesReturned;
                if (DeviceIoControl(driverHandle, IOCTL_MAHF_GET_CPU_INFO,
                    IntPtr.Zero, 0, buffer, (uint)size, out bytesReturned, IntPtr.Zero))
                {
                    cpuInfo = Marshal.PtrToStructure<CpuInfo>(buffer);
                }
            }
            finally
            {
                Marshal.FreeHGlobal(buffer);
            }

            return cpuInfo;
        }

        private PerformanceData GetPerformanceData()
        {
            PerformanceData perfData = new PerformanceData();
            
            if (driverHandle == IntPtr.Zero || driverHandle == new IntPtr(-1))
                return perfData;

            int size = Marshal.SizeOf(typeof(PerformanceData));
            IntPtr buffer = Marshal.AllocHGlobal(size);

            try
            {
                uint bytesReturned;
                if (DeviceIoControl(driverHandle, IOCTL_MAHF_GET_PERFORMANCE,
                    IntPtr.Zero, 0, buffer, (uint)size, out bytesReturned, IntPtr.Zero))
                {
                    perfData = Marshal.PtrToStructure<PerformanceData>(buffer);
                }
            }
            finally
            {
                Marshal.FreeHGlobal(buffer);
            }

            return perfData;
        }

        private void SetPerformanceMode(PerformanceMode mode)
        {
            if (driverHandle == IntPtr.Zero || driverHandle == new IntPtr(-1))
                return;

            int size = Marshal.SizeOf(typeof(PerformanceMode));
            IntPtr buffer = Marshal.AllocHGlobal(size);

            try
            {
                Marshal.StructureToPtr(mode, buffer, false);
                uint bytesReturned;
                DeviceIoControl(driverHandle, IOCTL_MAHF_SET_PERFORMANCE,
                    buffer, (uint)size, IntPtr.Zero, 0, out bytesReturned, IntPtr.Zero);
            }
            finally
            {
                Marshal.FreeHGlobal(buffer);
            }
        }

        private void UpdateTimer_Tick(object sender, EventArgs e)
        {
            PerformanceData perfData = GetPerformanceData();

            // Update UI
            CpuUsageLabel.Content = $"{perfData.Usage}%";
            CpuUsageBar.Value = perfData.Usage;

            TemperatureLabel.Content = $"{perfData.Temperature}°C";
            TemperatureBar.Value = perfData.Temperature;

            PowerLabel.Content = $"{perfData.PowerConsumption}W";
            PowerBar.Value = perfData.PowerConsumption;

            FrequencyLabel.Content = $"{perfData.CurrentFrequency} MHz";

            // Update mode indicator
            switch (perfData.Mode)
            {
                case PerformanceMode.PowerSave:
                    CurrentModeLabel.Content = "Power Save";
                    break;
                case PerformanceMode.Balanced:
                    CurrentModeLabel.Content = "Balanced";
                    break;
                case PerformanceMode.Performance:
                    CurrentModeLabel.Content = "Performance";
                    break;
                case PerformanceMode.Extreme:
                    CurrentModeLabel.Content = "Extreme";
                    break;
            }
        }

        private void PowerSaveButton_Click(object sender, RoutedEventArgs e)
        {
            SetPerformanceMode(PerformanceMode.PowerSave);
            MessageBox.Show("Performance mode set to Power Save", "Mahf CPU Driver", 
                MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private void BalancedButton_Click(object sender, RoutedEventArgs e)
        {
            SetPerformanceMode(PerformanceMode.Balanced);
            MessageBox.Show("Performance mode set to Balanced", "Mahf CPU Driver", 
                MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private void PerformanceButton_Click(object sender, RoutedEventArgs e)
        {
            SetPerformanceMode(PerformanceMode.Performance);
            MessageBox.Show("Performance mode set to Performance", "Mahf CPU Driver", 
                MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private void ExtremeButton_Click(object sender, RoutedEventArgs e)
        {
            var result = MessageBox.Show(
                "Extreme mode may cause higher temperatures and power consumption. Continue?",
                "Warning", MessageBoxButton.YesNo, MessageBoxImage.Warning);
            
            if (result == MessageBoxResult.Yes)
            {
                SetPerformanceMode(PerformanceMode.Extreme);
            }
        }

        private void AdvancedButton_Click(object sender, RoutedEventArgs e)
        {
            AdvancedWindow advWindow = new AdvancedWindow();
            advWindow.Owner = this;
            advWindow.ShowDialog();
        }

        private void AboutButton_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show(
                "Mahf Firmware CPU Driver\n" +
                "Version 2.5.1\n\n" +
                "Copyright © 2024 Mahf Corporation\n" +
                "All Rights Reserved.\n\n" +
                "Universal CPU Performance and Power Management Driver\n" +
                "Supports: Intel, AMD, ARM architectures",
                "About Mahf CPU Driver",
                MessageBoxButton.OK,
                MessageBoxImage.Information);
        }

        protected override void OnClosed(EventArgs e)
        {
            updateTimer?.Stop();
            
            if (driverHandle != IntPtr.Zero && driverHandle != new IntPtr(-1))
            {
                CloseHandle(driverHandle);
            }

            base.OnClosed(e);
        }
    }
}