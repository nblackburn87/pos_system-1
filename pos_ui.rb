require 'active_record'

require './lib/cashier'
require './lib/customer'
require './lib/product'
require './lib/purchase'

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
    when '+ca'
      add_cashier
    when 'lca'
      list_cashiers
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

puts 'Welcome to the Point-Of-Sale System!'
menu
