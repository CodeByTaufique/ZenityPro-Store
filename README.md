# 🛒 Zenity Store Pro

**Zenity Store Pro** is a robust, lightweight graphical **Store Management System** powered entirely by **Bash Shell Scripting**.

It provides an interactive GUI for both **Administrators** and **Customers** to manage inventory, track sales, and handle product requests — all without needing a traditional database.

---

## ✨ Features

### 🔐 Secure Access

* **Dual Role Support** – Separate interfaces for Admin and Users
* **Persistent Authentication** – Credentials stored securely in flat-file database
* **Password Management** – Users can change passwords inside the GUI

---

### 📦 Inventory & Sales

* **Real-Time Stock Tracking** – Automatic deduction after purchase
* **Low Stock Alerts** – Admin notified when stock drops below 5
* **Automated Billing** – Instant `.txt` invoice generation
* **Purchase History** – Users can view personal transaction logs

---

### 🛠️ Demand Management

* **Request System** – Users can request unavailable items
* **Sales Analytics** – Admin-only sales reporting

---

## 🛠️ Tech Stack

| Component        | Technology                |
| ---------------- | ------------------------- |
| Logic Engine     | Bash Shell                |
| GUI Toolkit      | Zenity (GTK Dialogs)      |
| Data Storage     | Flat-file `.txt` system   |
| Processing Tools | grep, cut, sed, subshells |

---

## 🚀 Getting Started

### Prerequisites

Install Zenity:

```bash
sudo apt update && sudo apt install zenity -y
```

---

### Installation

1. Download or clone the project
2. Give execution permission:

```bash
chmod +x store.sh
```

3. Run the application:

```bash
./store.sh
```

---

## 📘 System Reference

### 1. File Database Structure

The system automatically creates and manages:

| File           | Purpose             | Format                       |
| -------------- | ------------------- | ---------------------------- |
| `users.txt`    | Credentials & Roles | `username\|password\|role`   |
| `products.txt` | Inventory Data      | `ID\|Name\|Price\|Stock`     |
| `sales.txt`    | Transaction Records | `User\|ID\|Qty\|Total\|Date` |
| `requests.txt` | Restock Requests    | `User\|Item\|Qty\|Date`      |

---

### 2. Billing System

After every purchase, an invoice is generated:

```
bill_USERNAME_YYYY-MM-DD.txt
```

Example:

```
User: Taufique
Product ID: 101
Quantity: 2
Total: 1600
Date: 2026-02-16
```

---

## 📂 Project Structure

```
ZenityStore/
├── store.sh
├── users.txt
├── products.txt
├── sales.txt
├── requests.txt
└── bill_*.txt
```

---

## 🔧 Troubleshooting

| Problem            | Solution                                                |
| ------------------ | ------------------------------------------------------- |
| Permission Denied  | Run `chmod +x store.sh`                                 |
| Empty Product List | Populate `products.txt` with: `ID\|Name\|Price\|Stock`  |
| GUI Not Appearing  | Ensure running inside Desktop Environment (X11/Wayland) |

⚠️ Zenity will NOT run inside pure SSH / TTY without X-forwarding.

---

## 📜 License

Educational Use Only.

Designed to demonstrate:

* Efficient Bash data handling
* GUI integration
* File-based system architecture

---

## ✍️ Author

**Taufique**
*Clean Code. Minimalist Design. Powerful Scripting.*
