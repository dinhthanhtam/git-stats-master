#!/usr/bin/env ruby

require "optparse"
require "fileutils"
require "date"
require "rubygems"
require "pry-rails"
require "./git_stats/author"
require "./git_stats/yearmonth"
require "./git_stats/git"

require "./git_stats/stats"
require "./git_stats/stats/commit"
require "./git_stats/stats/commit/author"
require "./git_stats/stats/commit/time"
require "./git_stats/stats/file"
require "./git_stats/stats/file/filetype"

require "./git_stats/statgen"
require 'erb'

$options = {
  respos: "../",
  path: "../",
  branch: nil,
  start_date: nil,
  end_date: nil,
  file_type: false
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage git_stats.rb -r [resposibility] -p [path] -b [branch] -f [from_YYYYMMDD] -t [to_YYYYMMDD] -c [classify based on file type]"

  opts.on("-r", "--respos=arg", "resposibility name") do |arg|
    $options[:respos] = arg
  end

  opts.on("-p", "--path=arg", "directory of resposibility") do |arg|
    $options[:path] = arg
  end

  opts.on("-b", "--branch=arg", "branch name") do |arg|
    $options[:branch] = arg
  end

  opts.on("-f", "--start_date=arg", "from date") do |arg|
    $options[:start_date] = arg
  end

  opts.on("-t", "--end_date=arg", "to date") do |arg|
    $options[:end_date] = arg
  end

  opts.on("-c", "classify file statistics") do |arg|
    $options[:file_type] = arg
  end
end

def get_items()
  ['bread', 'milk', 'eggs', 'spam']
end

def get_template()
  %{
        <DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    </head>
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
        <script src="http://code.highcharts.com/highcharts.js"></script>
		<script src="http://code.highcharts.com/modules/exporting.js"></script>

		<div id="container" style="min-width: 310px; height: 400px; margin: 0 auto"></div>
		<script lang = "javascript">
			$(function () {
			    $('#container').highcharts({
			        title: {
			            text: 'Commit Per Day',
			            x: -20 //center
			        },        
			        xAxis: {
			            categories: <%= @days_commits.keys %>
			        },
			        yAxis: {
			            title: {
			                text: 'Commit'
			            },
			            plotLines: [{
			                value: 0,
			                width: 1,
			                color: '#808080'
			            }]
			        },
			        tooltip: {
			            valueSuffix: 'commits'
			        },
			        legend: {
			            layout: 'vertical',
			            align: 'right',
			            verticalAlign: 'middle',
			            borderWidth: 0
			        },
			        series: [{
			            name: '',
			            data: <%= @days_commits.values %>
			        }]
			    });
			});
		</script>
    </html>
  }
end

parser.parse!
stats = StatGen.new
stats.start_date ||= Date.parse($options[:start_date])
stats.end_date ||= Date.parse($options[:end_date])
stats << [$options[:respos], $options[:path], "HEAD"]
stats.calc($options[:branch])
stats.template = get_template
stats.save('index.html')
exec("firefox 'index.html'")