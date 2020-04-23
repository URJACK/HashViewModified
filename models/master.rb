require 'rubygems'
require 'sequel'
require 'bcrypt'
require 'rotp'

Sequel::Model.plugin :json_serializer

# read config
options = YAML.load_file('config/database.yml')

# there has to be a better way to handle this shit
if ENV['RACK_ENV'] == 'test'
  HVDB = Sequel.mysql2(options['test'])
  HVDB.loggers << Logger.new(STDOUT)
  HVDB.sql_log_level = :debug
elsif ENV['RACK_ENV'] == 'development'
  HVDB = Sequel.mysql2(options['development'])
  #HVDB.max_connections = '10'
  #HVDB.pool_timeout = '600'
  HVDB.loggers << Logger.new(STDOUT)
  HVDB.sql_log_level = :debug
elsif ENV['RACK_ENV'] == ('production' || 'default')
  HVDB = Sequel.mysql2(options['production'])
  # HVDB.loggers << Logger.new(STDOUT)
else
  puts 'ERROR: You must define an environment. ex: RACK_ENV=production'
  exit
end

# User class object to handle user account credentials
class User < Sequel::Model(:users)
  plugin :validation_class_methods
  attr_accessor :password
  validates_presence_of :username

  def password=(pass)
    @password = pass
    self.hashed_password = User.encrypt(@password)
  end

  def self.encrypt(pass)
    BCrypt::Password.create(pass)
  end

  def self.authenticate(username, pass)
    user = User.first(username: username)
    if user.mfa
      return user.username if pass == ROTP::TOTP.new(user.auth_secret).now.to_s
    elsif user
      return user.username if BCrypt::Password.new(user.hashed_password) == pass
    end
  end

  def self.create_test_user(attrs = {})
    user = User.new(
      username: 'test',
      admin: true,
      phone: '12223334444',
      email: 'test@localhost.com',
      hashed_password: BCrypt::Password.create('omgplains')
    )
    user.save
    user.update(attrs) if attrs
    user.save
    return user.id
  end

  def self.delete_test_user(id)
    user = User.first(id: id)
    user.delete
  end

  def self.delete_all_users
    @users = User.all
    @users.each do |user|
      user.delete
    end
  end

end

# Class to handle authenticated sessions
class Sessions < Sequel::Model(:sessions)
  def self.isValid?(session_key)
    sessions = Sessions.first(session_key: session_key)

    return true if sessions
  end

  def self.type(session_key)
    sess = Sessions.first(session_key: session_key)

    if sess
      if User.first(username: sess.username).admin
        return TRUE
      else
        return FALSE
      end
    end
  end

  def self.getUsername(session_key)
    sess = Sessions.first(session_key: session_key)

    return sess.username if sess
  end
end

# Each Customer record will be stored here
class Customers < Sequel::Model(:customers)

end

class Agents < Sequel::Model(:agents)

end

# Each job generated by user will be stored here
class Jobs < Sequel::Model(:jobs)

end

# Jobs will have multiple crack tasks
class Jobtasks < Sequel::Model(:jobtasks)

end

# Task definitions
class Tasks < Sequel::Model(:tasks)

end

# Task Groups
class TaskGroups < Sequel::Model(:task_groups)

end

# Table for handling hashes cracked and uncracked
class Hashes < Sequel::Model(:hashes)

end

# Table for managing association between users and hashes
class Hashfilehashes < Sequel::Model(:hashfilehashes)

end

# User Settings
class Settings < Sequel::Model(:settings)

end

# HashCat settings
class HashcatSettings < Sequel::Model(:hashcat_settings)

end

# Hashview Hub Settings
class HubSettings < Sequel::Model(:hub_settings)

end

# Wordlist
class Wordlists < Sequel::Model(:wordlists)

end

# Rules Class
class Rules < Sequel::Model(:rules)

end

# Hashfile Class
class Hashfiles < Sequel::Model(:hashfiles)

end

# task queue (we no logger use a resque worker)
class Taskqueues < Sequel::Model(:taskqueues)

end

class NetPackets < Sequel::Model(:netpackets)
  
end

class Operations < Sequel::Model(:operations)

end

class Messages < Sequel::Model(:messages)

end

class OperationPackets < Sequel::Model(:operationpackets)
  
end