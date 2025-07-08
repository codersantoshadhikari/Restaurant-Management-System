# SMAIT Restaurant Management System

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
- **Dependencies**: No extermal packages pure Dart
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
│ │ └── inventory_item.dart
│ │
│ ├── services/ # Business logic
│ │ ├── auth_service.dart
│ │ ├── menu_service.dart
│ │ ├── table_service.dart
│ │ ├── order_service.dart
│ │ ├── billing_service.dart
│ │ ├── inventory_service.dart
│ │ └── report_service.dart
│ │
│ └── utils/ # Helpers
│ ├── file_handler.dart
│ └── validator.dart
|
├── data/ # JSON database
│ ├── users.json
│ ├── menu.json
│ ├── tables.json
│ ├── inventory.json
│ └── invoices/ # Generated reports
| ├── sales_report.csv

## User Roles

| Role        | Permissions                |
| ----------- | -------------------------- |
| **Admin**   | Full system control        |
| **Cashier** | Process bills, view orders |
| **Waiter**  | Take orders, manage tables |

## 🚀 Features

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

### Reporting

- Daily sales (TXT + CSV)
- Inventory status
- Financial summaries

## Setup

1. **Install Dart SDK**:

2. **Run the system**:
   ```cmd
   dart run main.dart #make sure you are ath the right directory
   ```
   Copyright © 2025. All rights reserved.
