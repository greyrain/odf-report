require 'rubygems'
require 'zip'
require 'fileutils'
require 'nokogiri'
require 'marcel'
require 'fastimage'
require 'securerandom'

require File.expand_path('../odf-report/parser/default',  __FILE__)

require File.expand_path('../odf-report/images',    __FILE__)
require File.expand_path('../odf-report/field',     __FILE__)
require File.expand_path('../odf-report/text',      __FILE__)
require File.expand_path('../odf-report/template',      __FILE__)
require File.expand_path('../odf-report/nested',    __FILE__)
require File.expand_path('../odf-report/section',   __FILE__)
require File.expand_path('../odf-report/table',     __FILE__)
require File.expand_path('../odf-report/report',    __FILE__)
