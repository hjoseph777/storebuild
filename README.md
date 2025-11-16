# storebuild
The storebuild script  has the functionality  and the automation capabilities to bring store POS at end state
# Store Build II - POS System Configuration Tool

<div align="center">
  <img src="assets/storebuild-icon.png" alt="Store Build II Icon" width="128" height="128">
  
  <p>
    <img src="https://img.shields.io/badge/AutoIt-3.x-blue.svg" alt="AutoIt Version">
    <img src="https://img.shields.io/badge/Windows-7%20%7C%208%20%7C%2010-brightgreen.svg" alt="Windows Compatibility">
    <img src="https://img.shields.io/badge/License-Custom-red.svg" alt="License">
    <img src="https://img.shields.io/badge/Release-v1.0-brightgreen.svg" alt="Release">
    <img src="https://img.shields.io/badge/Download-Latest-blue.svg" alt="Download">
  </p>
</div>

## Overview

Store Build II is a comprehensive Windows automation tool designed to streamline the configuration and deployment of Point-of-Sale (POS) systems in retail environments. The application provides automated setup for both fixed and tablet POS systems, including network configuration, printer management, and system personalization.

## Features

### 🖥️ **Dual POS Configuration**
- **Fixed POS Systems**: Static IP configuration with complete network setup
- **Tablet POS Systems**: DHCP configuration with wireless capabilities

### 🌐 **Network Management**
- Automatic IP address assignment based on store configuration
- Network interface configuration (Ethernet/Wi-Fi)
- DNS and WINS server configuration
- Gateway and subnet mask setup

### 🖨️ **Printer Integration**
- **Epson JavaPOS ADK**: Receipt printer configuration
- **Samsung Universal Print Driver**: Front and back office printers
- **Tab Printer Support**: For mobile tablet systems
- Automatic printer IP assignment and validation

### 🏪 **Store Configuration**
- Live store setup (01-08 registers)
- Training store setup (21-28 registers)  
- Tablet store setup (50-57 registers)
- Legacy store support (01-15 registers)

### 📊 **Real-time Monitoring**
- Progress tracking with visual indicators
- Live IP subnet information display
- Error handling and logging system
- Process execution monitoring

## System Requirements

### Minimum Requirements
- **Operating System**: Windows 7/8/10 (32-bit or 64-bit)
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 100MB free space
- **Network**: Ethernet or Wi-Fi adapter
- **Privileges**: Administrator rights required

### Dependencies
- Oracle Retail POS Client
- Java Runtime Environment (JRE)
- Epson JavaPOS ADK
- Samsung Universal Print Driver
- Network connectivity for personalization

## Download and Installation

### 📦 Latest Release
[![Download Latest Release](https://img.shields.io/badge/Download-v1.0-success.svg?style=for-the-badge)](https://github.com/hjoseph777/GoldStoreBuildBeta5.zip)

**Direct Download**: [GoldStoreBuildBeta5.zip](https://github.com/hjoseph777/GoldStoreBuildBeta5.zip)

### Installation Steps

1. **Download** the application executable from the link above
2. **Extract** the zip file to your desired location
3. **Run as Administrator** (required for system modifications)
4. **Place dependencies** in the appropriate directories:
   - POS Client Installer on Desktop
   - Java installation in `D:\Apps\Java\`
   - Epson drivers in specified directory

## Installation

1. **Download** the application executable from the release link above
2. **Extract** the zip file to your desired location
3. **Run as Administrator** (required for system modifications)
4. **Place dependencies** in the appropriate directories:
   - POS Client Installer on Desktop
   - Java installation in `D:\Apps\Java\`
   - Epson drivers in specified directory

## Usage

### Quick Start Guide

1. **Launch Application**: Run as Administrator
2. **Select POS Type**: Choose between Fixed or Tablet
3. **Configure Store**: Enter store number and select register
4. **Training Mode**: Enable if configuring training systems
5. **Start Process**: Click "Start" to begin automated configuration

### Configuration Steps

#### Fixed POS Setup
1. Enter 4-digit store number
2. Select register number (01-08 for live, 21-28 for training)
3. Choose training RIAB if applicable
4. Automated process includes:
   - Static IP configuration
   - Computer naming
   - Oracle POS installation
   - Printer setup
   - Pinpad configuration

#### Tablet POS Setup  
1. Enter store number
2. Select tablet register (50-57)
3. Automated process includes:
   - DHCP configuration
   - Computer naming
   - Oracle POS installation
   - Tab printer setup

### Interface Components

- **Main Control Panel**: POS type selection and configuration
- **Progress Monitor**: Real-time status updates
- **IP Information Display**: Network configuration details
- **Timer**: Process duration tracking

## Network Configuration

### IP Address Scheme
- **Server LAN Subnet**: /28 network
- **Register Subnet**: /26 network  
- **Static IP Range**: Gateway +16 to +23
- **Printer IP Range**: Gateway +24 to +36
- **DHCP Range**: Gateway +37 to +62

### DNS Configuration
- **Primary DNS**: 10.1.246.40
- **Secondary DNS**: 10.224.41.40

### WINS Configuration
- **Primary WINS**: 10.1.40.68
- **Secondary WINS**: 10.224.40.68

## File Structure

```
Store Build II/
├── beta5.au3                 # Main application script
├── DataStorage/              # Configuration files
│   ├── SetModules.bat       # System module configuration
│   ├── RepairNetwork.cmd    # Network repair utilities
│   ├── HostNWGroup.cmd      # Host and workgroup setup
│   ├── NewRetail1.txt       # Store configuration data
│   ├── Ethernet/            # Wired printer configs
│   └── Wireless/            # Wireless printer configs
├── Dependencies/
│   ├── GUIExtender.au3      # GUI extension library
│   ├── PrintMgr.au3         # Printer management
│   ├── ProcessEx.au3        # Process monitoring
│   └── [Other includes]
└── Logs/                    # Application logs
```

## Logging and Monitoring

### Event Logging
- Comprehensive activity logging
- Error tracking and reporting
- Process timing and performance metrics
- Network configuration validation

### Log Locations
- **Main Log**: `%TEMP%\StoreBuild[YYYY][MM][DD][HH][MM].log`
- **Error Log**: Integrated with main log
- **Process Output**: Real-time console display

## Troubleshooting

### Common Issues

**Network Configuration Fails**
- Verify administrator privileges
- Check network adapter status
- Validate store number format

**Printer Installation Issues**
- Ensure Epson JavaPOS ADK compatibility
- Verify printer IP accessibility
- Check Samsung driver installation

**Oracle POS Installation Problems**
- Confirm internet connectivity
- Validate Java installation
- Check available disk space

### Error Codes
- **Error 1**: User cancellation
- **Network Error**: IP configuration failure
- **Printer Error**: Driver installation failure
- **Oracle Error**: POS client installation failure

## Security Considerations

- **Administrator Rights**: Required for system modifications
- **Network Access**: Validates connectivity before installation
- **Registry Modifications**: Controlled system configuration changes
- **Process Isolation**: Singleton execution prevention

## Changelog

### Version History
- **Beta 5**: Enhanced GUI, improved error handling, training mode support
- **Beta 4**: Added tablet support, wireless configuration
- **Beta 3**: Printer management improvements
- **Beta 2**: Network configuration automation
- **Beta 1**: Initial release with basic POS setup

## Support and Documentation

### Technical Support
- Review application logs for detailed error information
- Verify system requirements and dependencies
- Contact IT support team for deployment issues

### Additional Resources
- Oracle Retail POS documentation
- Epson JavaPOS ADK developer guide
- Samsung printer driver documentation

## License and Disclaimer

This software is provided "as is" without warranty of any kind. Users are responsible for testing in development environments before production deployment.

## Credits

**Author**: Harry Joseph  
**Original Date**: July 12, 2017  
**Project Repository**: [GoldStoreBuildBeta5](https://github.com/hjoseph777/GoldStoreBuildBeta5)  
**Release Version**: v1.0

---

*For technical support and inquiries, please contact the development team or refer to the integrated logging system for diagnostic information.*

