Feature goals:
- User login
- Access levels, directors can see all accounts, reps can see
  only their own accounts
- Ability to see Sales, Profit and Volume by rep and total (per
  year, per month) [See profit.png]
- Sales Volumes by Customer (Year to date, Previous 5 years, Last
  12 months rolling) [see CRM.png] – data is extracted from Nav
and into CRM staging table each night  – so presumably could use
this.
-  Sell Prices by Customer (found under customer card – Sales /
   Prices). Just item no & sell price (for current date) [see
sell.png]
-  Credit Info by Customer (found first page customer card – see
   highlighted fields) [see credit.png]
- Stock availability (found item card – see highlighted fields.
  Would be good to be able to drill down on purchase orders and
packing slips to get more details [see stock.png and stock2.png]

Read from another db
=====================
http://stackoverflow.com/questions/16533393/efficient-way-to-pull-data-from-second-database/16685353#16685353

SQL Server
===========
https://github.com/rails-sqlserver/activerecord-sqlserver-adapter/tree/4-1-stable

Rails 4.1.0 setup
================
rvm install ruby-2.1.1
rvm 2.1.1
gem install rails -v 4.1.0
rvm gemset create rails410
rvm 2.1.1@rails410
gem install rails -v 4.1.0
