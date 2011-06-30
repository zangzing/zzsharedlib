$:.unshift(File.dirname(__FILE__))
require 'rubygems'

require 'right_aws'
require 'sdb/active_sdb'

require 'zzsharedlib/utilities'
require 'zzsharedlib/monkey_patches'
require 'zzsharedlib/amazon'
require 'zzsharedlib/options'
require 'zzsharedlib/deploy_group_simple_db'
