class ScansController < ApplicationController
  require "rubygems"
  require "rest_client"
  require "rexml/document"

  def new
    @abc = Image.new
  end

  def create
    @abc.save
  end
end
