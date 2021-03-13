require "rubygems"
require "bundler/setup"

require "active_record"
require "pg"
require "active_support/all"

require_relative "../db/connection"

Bundler.require(:default)

loader = Zeitwerk::Loader.new
loader.push_dir("db/models")
loader.push_dir("lib")
loader.enable_reloading
loader.setup

loader.eager_load
