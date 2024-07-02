#!/bin/bash

# Function to display services
display_services() {
    echo "Services we offer:"
    psql --username=freecodecamp --dbname=salon -c "SELECT service_id, name FROM services;" | awk '{print $1 ") " $3 " " $4}'
}

# Display services
display_services

# Prompt for service_id
echo "Enter the service_id:"
read SERVICE_ID_SELECTED

# Validate service_id
while ! psql --username=freecodecamp --dbname=salon -c "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED;" | grep -q "(1 row)"
do
    echo "Invalid service_id. Please try again:"
    display_services
    read SERVICE_ID_SELECTED
done

# Prompt for phone number
echo "Enter your phone number:"
read CUSTOMER_PHONE

# Check if phone number exists in customers table
if ! psql --username=freecodecamp --dbname=salon -c "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE';" | grep -q "(1 row)"
then
    # If not, prompt for name and insert into customers table
    echo "Enter your name:"
    read CUSTOMER_NAME
    psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
fi

# Prompt for time
echo "Enter the appointment time:"
read SERVICE_TIME

# Insert into appointments table
psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) SELECT customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME' FROM customers WHERE phone = '$CUSTOMER_PHONE';"

# Fetch the service name
SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;" | awk 'NR==3{print $1 " " $2}')

# Fetch the customer name
CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -c "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';" | awk 'NR==3{print $1}')

# Output the appointment message
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
