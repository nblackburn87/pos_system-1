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
    print_options
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
    when 'x'
      puts 'Good-bye!'
    else
      puts 'Invalid option!'
    end
  end
end

def print_options
  puts "\n\n"
  puts "Enter '+pr' to add a product to the store's catalog."
  puts "Enter 'lpr' to list all products in catalog."
  puts "Enter '+ca' to create a cashier login."
  puts "Enter 'lca' to list cashiers."
  puts "Enter 'log' to login as a cashier."
  puts "Enter '+cu' to add a customer."
  puts "Enter 'lcu' to list customers."
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
    puts "Enter 'm' to logout and return to main menu."
    choice = prompt('Enter choice').downcase
    case choice
    when 'p'
      checkout(cashier)
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
  grand_total = 0.0
  receipt.purchases.each do |purchase|
    purchase_total = purchase.quantity * purchase.product.price
    grand_total += purchase_total
    puts purchase.product.name + "\t (" + purchase.quantity.to_s + ") at $" + purchase.product.price.to_s + "\t = " + purchase_total.to_s
  end
  print '_'*40 + "\n"
  puts "Total:\t\t$#{grand_total}"

end

puts 'Welcome to the Point-Of-Sale System!'
menu
