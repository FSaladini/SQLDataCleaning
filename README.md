# SQLDataCleaning
The idea of this project is to use SQL to clean some data.

The data used in this project is about housing sales in Nashville, you can download it raw here = https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx

There are six steps for this project:

### 1 - Standardize Date Format
  The SaleDate column has date and time information, being all time 00:00:00.000, which is useless for us, therefore we'll use a simple *CONVERT function* to make it a little bit better for unterstanding
  
### 2 - Populate PropertyAddress column
  There's an important column called PropertyAddress with some NULL cases, and we know that using an unique house identifier we can find out their address within the table and populate them, so we use a *self join* function to do so

### 3 - Braking out the address into columns: Address, City, State
  We use a *SUBSTRING with CHARINDEX* to filter this out
  
### 4 - Change Y and N to YES and NO in "sold as vacant" Field
  There's some inconsistancies in the data, we'll use some *CASE statements* to standardize it
  
### 5 - Remove Duplicates
  There are some duplicate rows, we'll filther them out using a *ROW_NUMBER OVER a PARTITION BY function within a CTE*, than simply deleting it (I know it'ss not advised, it is just for this study case)
  
### 6 - Remove Useless Columns
  No need for a new disclamer about being a good practice or not, we'll just drop the columns.
  
  
  This wasa a great study case for SQL and I hope it's possible to see some basic and advanced techniques being used here!
