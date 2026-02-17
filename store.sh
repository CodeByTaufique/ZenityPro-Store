#!/bin/bash

# STORE MANAGEMENT SYSTEM


USERS="users.txt"
PRODUCTS="products.txt"
REQUESTS="requests.txt"
SALES="sales.txt"

touch "$USERS" "$PRODUCTS" "$REQUESTS" "$SALES"

# to verify that its a number it will be used in later
isNumber() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Low Stock Alert
lowStockAlert() {
    alert=""

    while IFS='|' read -r id name price stock
    do
        if [ "$stock" -lt 5 ]; then
            alert="${alert}${name} (Stock: $stock)\n"
        fi
    done < "$PRODUCTS"

    if [ -n "$alert" ]; then
        zenity --warning --width=300 --text="Low Stock:\n$alert"
    fi
}

# Change Password
changePassword() {
    data=$(zenity --forms \
        --title="Change Password" \
        --width=400 \
        --height=200 \
        --add-password="Old Password" \
        --add-password="New Password")

    if [ $? -ne 0 ]; then
        return
    fi

    oldPass=$(echo "$data" | cut -d'|' -f1)
    newPass=$(echo "$data" | cut -d'|' -f2)

    storedPass=$(grep "^$USERNAME|" "$USERS" | cut -d'|' -f2)

    if [ "$oldPass" != "$storedPass" ]; then
        zenity --error --width=300 --text="Wrong old password"
        return
    fi

    while IFS='|' read -r u p r
    do
        if [ "$u" = "$USERNAME" ]; then
            p="$newPass"
        fi
        echo "$u|$p|$r"
    done < "$USERS" > temp.txt

    mv temp.txt "$USERS"

    zenity --info --width=300 --text="Password Updated"
}

# Purchase History
purchaseHistory() {
    history=$(grep "^$USERNAME|" "$SALES")

    if [ -z "$history" ]; then
        zenity --info --width=300 --text="No purchase history"
        return
    fi

    zenity --text-info \
        --title="My Purchases" \
        --width=500 \
        --height=400 \
        --filename=<(echo "$history")
}

# this  will be the first method which will show the option 
startMenu() {
    choice=$(zenity --list \
        --title="Store System" \
        --width=450 \
        --height=350 \
        --column="Option" \
        "Login" \
        "Create Account" \
        "Exit")

    case "$choice" in
        "Login") login ;;
        "Create Account") register ;;
        *) exit ;;
    esac
}

# Register Account
register() {
    data=$(zenity --forms \
        --title="Create Account" \
        --width=400 \
        --height=250 \
        --add-entry="Username" \
        --add-password="Password" \
        --add-combo="Role" --combo-values="admin|user")

    if [ $? -ne 0 ]; then
        startMenu
        return
    fi

    user=$(echo "$data" | cut -d'|' -f1)
    pass=$(echo "$data" | cut -d'|' -f2)
    role=$(echo "$data" | cut -d'|' -f3)

    if [ -z "$user" ] || [ -z "$pass" ]; then
        zenity --error --width=300 --text="All fields required!"
        startMenu
        return
    fi

    if grep -q "^$user|" "$USERS"; then
        zenity --error --width=300 --text="User already exists!"
        startMenu
        return
    fi

    echo "$user|$pass|$role" >> "$USERS"

    zenity --info --width=300 --text="Account Created Successfully!"
    startMenu
}

# Login
login() {
    data=$(zenity --forms \
        --title="Login" \
        --width=400 \
        --height=200 \
        --add-entry="Username" \
        --add-password="Password")

    if [ $? -ne 0 ]; then
        startMenu
        return
    fi

    USERNAME=$(echo "$data" | cut -d'|' -f1)
    password=$(echo "$data" | cut -d'|' -f2)

    line=$(grep "^$USERNAME|$password|" "$USERS")
    role=$(echo "$line" | cut -d'|' -f3)

    if [ -z "$role" ]; then
        zenity --error --width=300 --text="Invalid Login!"
        startMenu
        return
    fi

    if [ "$role" = "admin" ]; then
        adminMenu
    else
        userMenu
    fi
}

# Admin Menu
adminMenu() {
    lowStockAlert

    choice=$(zenity --list \
        --title="Admin Menu" \
        --width=400 \
        --height=400 \
        --column="Select Option" \
        "Add Product" \
        "View Products" \
        "View Requests" \
        "View Sales" \
        "Change Password" \
        "Logout")

    case "$choice" in
        "Add Product") addProduct ;;
        "View Products") viewProducts ;;
        "View Requests") viewReq ;;
        "View Sales") viewSales ;;
        "Change Password") changePassword ;;
        *) startMenu ;;
    esac
    adminMenu
}

# User Menu
userMenu() {
    choice=$(zenity --list \
        --title="User Menu" \
        --width=400 \
        --height=450 \
        --column="Select Option" \
        "View Products" \
        "Buy Product" \
        "Request Product" \
        "Purchase History" \
        "Change Password" \
        "Logout")

    case "$choice" in
        "View Products") viewProducts ;;
        "Buy Product") buyProduct ;;
        "Request Product") reqProduct ;;
        "Purchase History") purchaseHistory ;;
        "Change Password") changePassword ;;
        *) startMenu ;;
    esac
    userMenu
}

addProduct() {
    data=$(zenity --forms \
        --title="Add Product" \
        --width=400 \
        --height=450 \
        --add-entry="Product Name" \
        --add-entry="Price" \
        --add-entry="Quantity")

    if [ $? -ne 0 ]; then
        return
    fi

    name=$(echo "$data" | cut -d'|' -f1)
    price=$(echo "$data" | cut -d'|' -f2)
    qty=$(echo "$data" | cut -d'|' -f3)

    if [ -z "$name" ] || [ "$(isNumber "$price"; echo $?)" -ne 0 ] || [ "$(isNumber "$qty"; echo $?)" -ne 0 ]; then
        zenity --error --width=300 --text="Invalid input"
        return
    fi

    id=$(( $(wc -l < "$PRODUCTS") + 1 ))

    echo "$id|$name|$price|$qty" >> "$PRODUCTS"

    zenity --info --width=300 --text="Product Added Successfully"
}

# View products
viewProducts() {
    if [ ! -s "$PRODUCTS" ]; then
        zenity --info --width=300 --text="No products available"
        return
    fi

    zenity --text-info \
        --title="Available Products" \
        --width=500 \
        --height=400 \
        --filename="$PRODUCTS"
}

# Buy product
buyProduct() {
    if [ ! -s "$PRODUCTS" ]; then
        zenity --info --width=300 --text="No products available"
        return
    fi

    list=$(while IFS='|' read -r id name price stock
    do
        echo "$id $name Price:$price Stock:$stock"
    done < "$PRODUCTS")

    choice=$(echo "$list" | zenity --list \
        --title="Select Product" \
        --width=450 \
        --height=450 \
        --column="Products")

    if [ $? -ne 0 ]; then
        return
    fi

    pid=$(echo "$choice" | cut -d' ' -f1)

    qty=$(zenity --entry \
        --title="Enter Quantity" \
        --width=300 \
        --text="Enter quantity to buy")

    if [ "$(isNumber "$qty"; echo $?)" -ne 0 ]; then
        zenity --error --width=300 --text="Invalid quantity"
        return
    fi

    stock=$(grep "^$pid|" "$PRODUCTS" | cut -d'|' -f4)
    price=$(grep "^$pid|" "$PRODUCTS" | cut -d'|' -f3)

    if (( qty > stock )); then
        zenity --error --width=300 --text="Not enough stock. Please send a request."
        return
    fi

    while IFS='|' read -r id name pr st
    do
        if [ "$id" = "$pid" ]; then
            st=$((st - qty))
        fi
        echo "$id|$name|$pr|$st"
    done < "$PRODUCTS" > temp.txt

    mv temp.txt "$PRODUCTS"

    total=$(( qty * price ))
    dateNow=$(date '+%F')

    echo "$USERNAME|$pid|$qty|$total|$dateNow" >> "$SALES"

    bill="bill_${USERNAME}_${dateNow}.txt"

    echo "User: $USERNAME" > "$bill"
    echo "Product ID: $pid" >> "$bill"
    echo "Quantity: $qty" >> "$bill"
    echo "Total: $total" >> "$bill"
    echo "Date: $dateNow" >> "$bill"

    zenity --info --width=300 --text="Purchase Successful\nTotal: $total"
}

# Request product
reqProduct() {
    data=$(zenity --forms \
        --title="Request Product" \
        --width=400 \
        --height=200 \
        --add-entry="Product Name" \
        --add-entry="Required Quantity")

    if [ $? -ne 0 ]; then
        return
    fi

    name=$(echo "$data" | cut -d'|' -f1)
    qty=$(echo "$data" | cut -d'|' -f2)

    if [ -z "$name" ] || [ "$(isNumber "$qty"; echo $?)" -ne 0 ]; then
        zenity --error --width=300 --text="Invalid request"
        return
    fi

    echo "$USERNAME|$name|$qty|$(date '+%F')" >> "$REQUESTS"

    zenity --info --width=300 --text="Request submitted"
}

# View request
viewReq() {
    if [ ! -s "$REQUESTS" ]; then
        zenity --info --width=300 --text="No requests"
        return
    fi

    zenity --text-info \
        --title="Product Requests" \
        --width=500 \
        --height=400 \
        --filename="$REQUESTS"
}

# View Sales
viewSales() {
    if [ ! -s "$SALES" ]; then
        zenity --info --width=300 --text="No sales yet"
        return
    fi

    zenity --text-info \
        --title="Sales Report" \
        --width=500 \
        --height=400 \
        --filename="$SALES"
}
# Start
startMenu



