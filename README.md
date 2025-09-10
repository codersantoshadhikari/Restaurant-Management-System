# SMAIT Restaurant Management System

### Simple System Flow

<img width="1000" height="1000" alt="Image" src="https://github.com/user-attachments/assets/91d91efe-e2f1-4df6-a545-676280c654b8" />

\_A pure Dart terminal-based System

## Team Members

| Name            |
| --------------- |
| Deephang Thegim |
| Pradip KC       |

## Overview

A complete CLI system for managing restaurant operations including:

- Menu management
- Table booking & orders
- Inventory tracking
- Billing & reporting
- Role-based access control

## 🛠️ Tech Stack

- **Language**: Dart
- **Storage**: JSON files and a csv file
- **Dependencies**: No external packages pure Dart
- **IDE**: Visual Studio Code

## File Structure

restaurant_system/
├── main.dart #Main Entry Point
├─|
│ ├── models/ # Data structures
│ │ ├── user.dart
│ │ ├── menu_item.dart
│ │ ├── table.dart
│ │ ├── order.dart
| | └── attendacne.dart
│ │
│ ├── services/ # Business logic
│ │ ├── auth_service.dart
│ │ ├── menu_service.dart
│ │ ├── table_service.dart
│ │ ├── order_service.dart
│ │ ├── billing_service.dart
│ │ ├── inventory_service.dart
│ │ └── report_service.dart
│ │ └── transfer_service.dart
│ │ └── branch_service.dart
│ │ └── attendance_service.dart
│ │
│ └── utils/ # Helpers
│ ├── file_handler.dart
|
├── data/ # JSON database
| ├── attendance/
|-----├── attendance.csv
│ ├── users.json
│ ├── menu.json
│ ├── tables.json
│ ├── inventory.json
| └── staffs.json
│ └── invoices/ # Generated reports
| ├── sales_report.csv
| ├── branches/
|-----├── frankfurt.json
|-----├── lisbon.json
|----├── noida.json
|-----├── oslo.json
|-----├── pokhara.json
| ├── transfers/ #Generate Transfer Report

## User Roles

| Role        | Permissions                |
| ----------- | -------------------------- |
| **Admin**   | Full system control        |
| **Cashier** | Process bills, view orders |
| **Waiter**  | Take orders, manage tables |

## Features

### Attendance

- can be performed by managers, waiters and cashiers and other staffs
- Checkin and checkout feature

### Menu Management

- Add/update menu items
- Set categories (Appetizers, Mains, etc.)
- Toggle item availability

### Table Operations

- Book/free tables
- Track occupancy status
- Manage orders per table

### Order Processing

- Add/remove items
- Calculate totals
- Modify quantities

### Inventory Management

- Add/remove items of different branches
- View inventory items in different branches
- Modify quantities of different branches
- Handles inventory transfer

### Reporting

- Daily sales (TXT + CSV)
- Inventory status
- Financial summaries

## Setup

1. **Install Dart SDK** or **simply install flutter where Dart SDk comes along with it**

2. **Run the system**:
   ```cmd
   dart run main.dart #make sure you are at the right directory
   ```

Copyright © 2025. All rights reserved.
