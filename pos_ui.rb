require 'active_record'

require './lib/cashier'
require './lib/customer'
require './lib/product'
require './lib/purchase'
require './lib/receipt'

ActiveRecord::Base.establish_connection(YAML::load(File.open('./db/config.yml'))['development'])
I18n.enforce_available_locales = false

def menu
  choice = nil
  until choice == 'x'
    manager_options
    choice = prompt('Enter choice')
    case choice
    when '+pr'
      add_product
    when 'lpr'
      list_products
    when 'lcu'
      list_customers
    when '+cu'
      add_customer
    when '+ca'
      add_cashier
    when 'lca'
      list_cashiers
    when 'log'
      cashier_login
    when 'data'
      data_menu
    when 'lr'
      list_receipts
    when 'x'
      puts 'Good-bye!'
    else
      puts 'Invalid option!'
    end
  end
end

def login_menu
  puts "Enter 'm' for store manager options"
  puts "Enter 'c' for cashier options"
  choice = prompt('Enter choice').downcase
  case choice
  when 'm'
    password = prompt('Enter password').downcase
    if password == 'epicodus'
      menu
    else
      puts "Invalid input!"
      exit
    end
  when 'c'
    cashier_login
  else
    puts "Invalid input!"
  end
end

def manager_options
  puts "\n\n"
  puts "Enter '+pr' to add a product to the store's catalog."
  puts "Enter 'lpr' to list all products in catalog."
  puts "Enter '+ca' to create a cashier login."
  puts "Enter 'lca' to list cashiers."
  puts "Enter 'log' to login as a cashier."
  puts "Enter '+cu' to add a customer."
  puts "Enter 'lcu' to list customers."
  puts "Enter 'data' to query store data."
  puts "Enter 'lr' to list receipts."
  puts "Enter 'x' to exit."
end

def prompt(string)
  print string + ': '
  gets.chomp
end

def list_products
  puts "\n******* Product Catalog *******"
  Product.all.each do |product|
    puts product.name + "\t\t$" + product.price.to_s
  end
  print '*'*31 + "\n\n"
end

def add_product
  list_products
  product_name = prompt('Enter new product name').downcase
  product_price = prompt("Enter #{product_name} price").to_f
  new_product = Product.new({ :name => product_name, :price => product_price })
  if new_product.save
    puts "Created #{new_product.name}"
  else
    puts "Catalog already has #{new_product.name}!"
  end
end

def list_customers
  puts "\n__________ Customers __________"
  Customer.all.each do |customer|
    puts customer.name
  end
  print '_'*31 + "\n\n"
end

def add_customer
  list_customers
  customer_name = prompt('Enter customer name').titlecase
  new_customer = Customer.new({ :name => customer_name })
  if new_customer.save
    puts "Created #{new_customer.name}."
  else
    puts 'Customer already exists!'
  end
end

def list_cashiers
  puts "\n---------- Cashiers -----------"
  Cashier.all.each do |cashier|
    puts cashier.login
  end
  print '-'*31 + "\n\n"
end

def add_cashier
  list_cashiers
  cashier_login = prompt('Enter cashier name').titlecase
  new_cashier = Cashier.new({ :login => cashier_login })
  if new_cashier.save
    puts "Created #{new_cashier.login}."
  else
    puts 'Cashier already exists!'
  end
end

def cashier_login
  login = prompt('Enter your cashier login')
  cashier = Cashier.find_by_login(login)
  unless cashier.nil?
    cashier_menu(cashier)
  else
    puts "Invalid login, return to main menu."
  end
end

def cashier_menu(cashier)
  choice = nil
  until choice == 'm'
    puts "Enter 'p' to checkout customer."
    puts "Enter 'r' to process a return."
    puts "Enter 'm' to logout and return to main menu."
    choice = prompt('Enter choice').downcase
    case choice
    when 'p'
      checkout(cashier)
    when 'r'
      process_return(cashier)
    when 'm'
      puts "Logging out.\n\n"
    else
      puts 'Invalid option!'
    end
  end
end

def checkout(cashier)
  purchases = []
  list_customers
  customer_name = prompt('Who is checking out?')
  customer = Customer.find_by_name(customer_name)
  unless customer.nil?
    continue = 'y'
    until continue == 'n'
      purchase = add_purchase
      unless purchase.nil?
        purchases << purchase
        puts "Purchase of #{purchase.quantity} #{purchase.product.name} added."
      end
      continue = prompt('Add another purchase? (y/n)').downcase
    end
    receipt = Receipt.create({ :customer_id => customer.id, :cashier_id => cashier.id })
    purchases.each do |purchase|
      receipt.purchases << purchase
    end
    print_receipt(receipt)
  else
    puts 'Invalid customer name!'
  end
end

def add_purchase
  list_products
  product_name = prompt("Enter a product that the customer wants to purchase")
  product_id = Product.find_by_name(product_name).id
  new_purchase = nil
  unless product_id.nil?
    quantity = prompt('Enter quantity').to_i
    new_purchase = Purchase.create({ :product_id => product_id, :quantity => quantity })
  else
    puts "Invalid product name."
  end
  new_purchase
end

def print_receipt(receipt)
  puts "//// Neighborhood Irish Pub & Jeweler ////"
  puts "Customer: #{receipt.customer.name}\t\tCashier: #{receipt.cashier.login}"
  puts "Date: #{receipt.created_at}"
  print '/'*42 + "\n"
  receipt.purchases.each do |purchase|
    purchase_total = purchase.quantity * purchase.product.price
    puts purchase.product.name + "\t (" + purchase.quantity.to_s + ") at $" + purchase.product.price.to_s + "\t = " + purchase_total.to_s
  end
  print '_'*40 + "\n"
  puts "Total:\t\t$#{receipt.total_income}"
end

def process_return(cashier)
  list_customers
  customer_name = prompt('Enter customer name')
  customer = Customer.find_by_name(customer_name)
  customer.receipts.each do |receipt|
    receipt.purchases.each do |purchase|
      puts "Receipt ID: " + receipt.id.to_s + ", " + purchase.product.name + ", (" + purchase.quantity.to_s + ")"
    end
  end
  receipt_id = prompt('Enter receipt ID').to_i
  product_name = prompt('Enter product to return')
  product_id = Product.find_by_name(product_name).id
  return_quantity = prompt('Enter quantity to return').to_i

  return_receipt = Receipt.create({ :customer_id => customer.id, :cashier_id => cashier.id })
  return_purchase = Purchase.create({ :receipt_id => return_receipt.id, :product_id => product_id, :quantity => - return_quantity })

  puts "Return proessed for #{return_receipt.customer.name}, by cashier #{return_receipt.cashier.login} for #{return_purchase.product.name}"
end

def data_menu
  puts "Enter 's' to review sales by date."
  puts "Enter 'ce' to review cashier efficency."
  puts "Enter 'm' to return to main menu."
  choice = prompt('Enter choice')
  case choice
  when 's'
    list_receipts
    sales_by_date
  when 'ce'
    list_cashiers
    cashier_login = prompt('Enter a cashier name to see their customer count')
    cashier = Cashier.find_by_login(cashier_login)
    unless cashier.nil?
      cashier_customer_count(cashier)
    else
      puts 'Invalid cashier name!'
    end
  when 'm'
    puts 'Returning to main menu...'
  else
    puts 'Invalid entry'
  end
end

def list_receipts
  Receipt.all.each do |receipt|
    puts "#{receipt.created_at}\t\t#{receipt.customer.name}\t$#{receipt.total_income}"
  end
end

def sales_by_date
  date_input = prompt('Enter starting date (YYYY-MM-DD format)')
  first_date = Time.parse(date_input)
  date_input = prompt('Enter end date (YYYY-MM-DD format)')
  temp = Time.parse(date_input)
  second_date = Time.local(temp.year, temp.month, temp.day+1)
  receipts = Receipt.receipts_for_period(first_date, second_date)
  grand_total = 0.0
  unless receipts.nil?
    receipts.each do |receipt|
      grand_total += receipt.total_income
      puts receipt.id.to_s + ")\t\t$"+ receipt.total_income.to_s
    end
    puts "Total for this date range is: $#{grand_total}."
  else
    puts "Invalid date range"
  end
end

def cashier_customer_count(cashier)
  date_input = prompt('Enter starting date (YYYY-MM-DD format)')
  first_date = Time.parse(date_input)
  date_input = prompt('Enter end date (YYYY-MM-DD format)')
  temp = Time.parse(date_input)
  second_date = Time.local(temp.year, temp.month, temp.day+1)
  receipts = cashier.receipts.select do |receipt|
    receipt.created_at >= first_date && receipt.created_at <= second_date
  end
  puts "#{cashier.login} has served #{receipts.length} customers."
end

puts 'Welcome to the Point-Of-Sale System!'
login_menu
