
# Data Dictionary for Petstore Database

### Table: `category`

**Description:** Stores category information for pets (e.g., Dogs, Cats).

| Column     | Data Type   | Constraints                          | Description                          |
|------------|-------------|--------------------------------------|--------------------------------------|
| id         | BIGINT      | PRIMARY KEY                          | Unique identifier for each category. |
| name       | VARCHAR(255)|                                      | Name of the category.                |

### Table: `pet`

**Description:** Stores information about pets available in the store.

| Column     | Data Type   | Constraints                          | Description                          |
|------------|-------------|--------------------------------------|--------------------------------------|
| id         | BIGINT      | PRIMARY KEY                          | Unique identifier for each pet.      |
| name       | VARCHAR(255)| NOT NULL                             | Name of the pet.                     |
| category   | BIGINT      | FOREIGN KEY REFERENCES category(id) ON DELETE SET NULL | Category ID referencing the category. |
| photoUrls  | TEXT[]      |                                      | Array of URLs pointing to pet photos.|
| status     | VARCHAR(255)|                                      | Current status of the pet (e.g., available, pending, sold). |

**Relationships:**
- category (FK): Each pet belongs to one category.
- tags (Many-to-Many via `pettag`): Each pet can have multiple tags.

### Table: `customer`

**Description:** Stores information about customers.

| Column     | Data Type   | Constraints                          | Description                          |
|------------|-------------|--------------------------------------|--------------------------------------|
| id         | BIGINT      | PRIMARY KEY                          | Unique identifier for each customer. |
| username   | VARCHAR(255)|                                      | Username of the customer.            |

### Table: `address`

**Description:** Stores address information associated with customers.

| Column     | Data Type   | Constraints                          | Description                          |
|------------|-------------|--------------------------------------|--------------------------------------|
| id         | BIGINT      | PRIMARY KEY                          | Unique identifier for each address.  |
| customerid | BIGINT      | FOREIGN KEY REFERENCES customer(id) ON DELETE SET NULL | Foreign key referencing customer.    |
| street     | VARCHAR(255)|                                      | Street address.                      |
| city       | VARCHAR(255)|                                      | City of the address.                 |
| state      | VARCHAR(255)|                                      | State of the address.                |
| zip        | VARCHAR(255)|                                      | Postal code of the address.          |

### Table: `user`

**Description:** Stores user account information associated with customers.

| Column     | Data Type   | Constraints                          | Description                          |
|------------|-------------|--------------------------------------|--------------------------------------|
| id         | BIGINT      | PRIMARY KEY                          | Unique identifier for each user.     |
| customerid | BIGINT      | FOREIGN KEY REFERENCES customer(id) ON DELETE SET NULL | Foreign key referencing customer.    |
| username   | VARCHAR(255)|                                      | Username of the user.                |
| firstname  | VARCHAR(255)|                                      | First name of the user.              |
| lastname   | VARCHAR(255)|                                      | Last name of the user.               |
| email      | VARCHAR(255)|                                      | Email address of the user.           |
| password   | VARCHAR(255)|                                      | Password for accessing the account.  |
| phone      | VARCHAR(255)|                                      | Contact phone number of the user.    |
| userStatus | INTEGER     |                                      | Status of the user (e.g., active, inactive).|

### Table: `order`

**Description:** Stores order information related to pets.

| Column     | Data Type   | Constraints                          | Description                          |
|------------|-------------|--------------------------------------|--------------------------------------|
| id         | BIGINT      | PRIMARY KEY                          | Unique identifier for each order.    |
| customerid | BIGINT      | FOREIGN KEY REFERENCES customer(id) ON DELETE SET NULL | Foreign key referencing customer.    |
| petId      | BIGINT      | FOREIGN KEY REFERENCES pet(id) ON DELETE SET NULL | Foreign key referencing pet.         |
| quantity   | INTEGER     |                                      | Number of pets ordered.              |
| shipDate   | TIMESTAMP   |                                      | Date and time when the order is shipped.|
| status     | VARCHAR(255)|                                      | Current status of the order.         |
| complete   | BOOLEAN     |                                      | Indicator if the order is completed. |

### Table: `tag`

**Description:** Stores tag information for categorizing pets.

| Column     | Data Type   | Constraints                          | Description                          |
|------------|-------------|--------------------------------------|--------------------------------------|
| id         | BIGINT      | PRIMARY KEY                          | Unique identifier for each tag.      |
| name       | VARCHAR(255)|                                      | Name of the tag.                     |

### Table: `pettag`

**Description:** Stores relationships between pets and tags (many-to-many).

| Column     | Data Type   | Constraints                          | Description                          |
|------------|-------------|--------------------------------------|--------------------------------------|
| petid      | BIGINT      | FOREIGN KEY REFERENCES pet(id) ON DELETE CASCADE | Foreign key referencing pet.         |
| tagid      | BIGINT      | FOREIGN KEY REFERENCES tag(id) ON DELETE CASCADE | Foreign key referencing tag.         |

**Relationships:**
- pet (FK): Each relationship links a pet to a tag.
- tag (FK): Each relationship links a tag to a pet.