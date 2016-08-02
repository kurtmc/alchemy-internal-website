[![Build Status](https://travis-ci.org/kurtmc/alchemy-internal-website.svg?branch=master)](https://travis-ci.org/kurtmc/alchemy-internal-website)
Alchemy Internal Website
========================
This project integrates with Alchemy's Microsoft Dynamics NAV database
providing useful features to the Alchemy staff.
- Secure login service allowing only Alchemy employees to access
- Tools:
	* Tools for branding special PDF documents such as Safety Data
	  Sheets for Product Data Sheets
	* Tool for translating CRM reports into vendor specific
	  requirements
- Products:
	* Sales, Cost, Margin and Volume chart for the last 5 years
	* Summerised view of individual products
	* Allows uploading and downloading of documents associated with
	  product
- Customers:
	* Sales, Cost, Margin and Volume chart for the last 5 years
	* Summerised view of customers
	* Includes customer credit information
	* Lists product sell prices per customer
	* Compares YTD to PY for each product the volume, sales and marign
- Vendors:
	* Sales, Cost, Margin and Volume chart for the last 5 years
	* Able to show Vendor group stats, whereby all metrics are
	  combined for a particular vendor group
	* List of products associate with vendor
- Sales:
	* Overall company sales over the years chart
	* Comparison of individual sales people charts	

Development environment
=======================

### Build
```
docker build -t alchemy-internal-docker .
```

### Run
First time only:
```
docker run -v $(pwd):/var/alchemy -i -t alchemy-internal-docker /var/alchemy/initialise-database-dev.sh
```
To start web app:
```
docker run --net=host -v $(pwd):/var/alchemy -i -t alchemy-internal-docker /var/alchemy/start.sh
```

### Login
username: admin@example.com
password: password
