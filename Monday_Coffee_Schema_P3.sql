
-- Monday Coffee SCHEMAS 

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS city;

-- Creating Table 


CREATE TABLE city
    (city_id INT PRIMARY KEY,
	 city_name VARCHAR(20),
	 population	BIGINT,
	 estimated_rent	FLOAT,
	 city_rank INT
);

CREATE TABLE customers
     (customer_id INT PRIMARY KEY,	
	  customer_name	VARCHAR(50),
	  city_id INT,
	  CONSTRAINT fk_city 
     FOREIGN KEY (city_id) REFERENCES city(city_id)
);  


CREATE TABLE products
      (product_id INT PRIMARY KEY,
	   product_name	VARCHAR(70),
	   price FLOAT
);


CREATE TABLE sales
      (sale_id INT PRIMARY KEY,
	   sale_date DATE,	
	   product_id	INT,
	   customer_id	INT,
	   total	FLOAT,
	   rating INT,
	   CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	   CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

                                      -- END of SCHEMAS -- 







