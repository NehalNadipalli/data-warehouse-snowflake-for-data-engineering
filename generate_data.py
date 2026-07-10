"""
Generates synthetic e-commerce sample data for the pipeline:
  customers.csv, products.csv, orders.csv, order_items.csv

Run:
    python generate_data.py

Output lands in ./output/ as CSVs, ready to feed into the NiFi flow
(point NiFi's GetFile processor at this folder, or upload directly to S3
to test Snowpipe before wiring up NiFi).
"""

import csv
import os
import random
from datetime import datetime, timedelta

random.seed(42)

OUT_DIR = os.path.join(os.path.dirname(__file__), "output")
os.makedirs(OUT_DIR, exist_ok=True)

N_CUSTOMERS = 200
N_PRODUCTS = 40
N_ORDERS = 800
MAX_ITEMS_PER_ORDER = 4

FIRST_NAMES = ["Ava","Liam","Olivia","Noah","Emma","Oliver","Sophia","Elijah","Mia","Lucas",
               "Amelia","Mason","Isabella","Ethan","Harper","Logan","Evelyn","James","Camila","Benjamin"]
LAST_NAMES = ["Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez",
              "Hernandez","Lopez","Gonzalez","Wilson","Anderson","Thomas","Taylor","Moore","Jackson","Martin"]
CITIES = [("Dallas","TX"),("Austin","TX"),("Denver","CO"),("Seattle","WA"),("Miami","FL"),
          ("Chicago","IL"),("Boston","MA"),("Phoenix","AZ"),("Atlanta","GA"),("Portland","OR")]
CATEGORIES = ["Electronics","Home & Kitchen","Sports & Outdoors","Books","Toys","Beauty","Apparel"]
STATUSES = ["completed","completed","completed","completed","cancelled","refunded"]

def gen_customers():
    rows = []
    start = datetime(2023, 1, 1)
    for i in range(1, N_CUSTOMERS + 1):
        city, state = random.choice(CITIES)
        signup = start + timedelta(days=random.randint(0, 900))
        rows.append({
            "customer_id": i,
            "first_name": random.choice(FIRST_NAMES),
            "last_name": random.choice(LAST_NAMES),
            "email": f"customer{i}@example.com",
            "city": city,
            "state": state,
            "signup_date": signup.strftime("%Y-%m-%d"),
        })
    return rows

def gen_products():
    rows = []
    for i in range(1, N_PRODUCTS + 1):
        category = random.choice(CATEGORIES)
        price = round(random.uniform(5, 300), 2)
        rows.append({
            "product_id": i,
            "product_name": f"{category.split()[0]} Item {i}",
            "category": category,
            "unit_price": price,
        })
    return rows

def gen_orders_and_items(customers, products):
    orders = []
    items = []
    item_id = 1
    start = datetime(2024, 1, 1)
    for order_id in range(1, N_ORDERS + 1):
        customer = random.choice(customers)
        order_date = start + timedelta(days=random.randint(0, 550), hours=random.randint(0, 23))
        status = random.choice(STATUSES)
        n_items = random.randint(1, MAX_ITEMS_PER_ORDER)
        order_total = 0.0
        chosen_products = random.sample(products, n_items)
        for p in chosen_products:
            qty = random.randint(1, 3)
            line_total = round(p["unit_price"] * qty, 2)
            order_total += line_total
            items.append({
                "order_item_id": item_id,
                "order_id": order_id,
                "product_id": p["product_id"],
                "quantity": qty,
                "unit_price": p["unit_price"],
                "line_total": line_total,
            })
            item_id += 1
        orders.append({
            "order_id": order_id,
            "customer_id": customer["customer_id"],
            "order_date": order_date.strftime("%Y-%m-%d %H:%M:%S"),
            "status": status,
            "order_total": round(order_total, 2),
        })
    return orders, items

def write_csv(path, rows, fieldnames):
    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

def main():
    customers = gen_customers()
    products = gen_products()
    orders, items = gen_orders_and_items(customers, products)

    write_csv(os.path.join(OUT_DIR, "customers.csv"), customers,
               ["customer_id","first_name","last_name","email","city","state","signup_date"])
    write_csv(os.path.join(OUT_DIR, "products.csv"), products,
               ["product_id","product_name","category","unit_price"])
    write_csv(os.path.join(OUT_DIR, "orders.csv"), orders,
               ["order_id","customer_id","order_date","status","order_total"])
    write_csv(os.path.join(OUT_DIR, "order_items.csv"), items,
               ["order_item_id","order_id","product_id","quantity","unit_price","line_total"])

    print(f"Generated {len(customers)} customers, {len(products)} products, "
          f"{len(orders)} orders, {len(items)} order items in {OUT_DIR}/")

if __name__ == "__main__":
    main()
