module Armory
  class Request
    include HTTParty
    format :xml
    headers 'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.6) Gecko/20050317 Firefox/1.0.2'
    headers 'Accept' => 'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8'
    headers 'Accept-Charset' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7'
  end
end