#!/usr/bin/env ruby
#-*- coding: utf-8 -*-
 
require "open-uri"
require "nokogiri"
require 'net/http' # LINE
require 'uri' # LINE

url = "https://www.pref.shizuoka.jp/kinkyu/covid-19-keikailevel.html"
charset = nil

# open-uriにてdom読み込み
html = open(url) do |f|
  charset = f.charset
  f.read
end
 
# 読み込んだものから、Nokogiri でスクレイピング
contents = Nokogiri::HTML.parse(html,nil,charset)
list = []
contents.xpath('//h1').each do |tr|
  tr_content = tr.content
  list.push(tr_content)
end

# textファイル（設定ファイル）の読み込み
f = File.open("/Users/totsukashouta/Desktop/korona/config.txt")
s = f.read

# ファイルの書き込み
def txt_write(content)
  File.open("/Users/totsukashouta/Desktop/korona/config.txt", mode = "w") {|f|
    f.write(content)
  }
end

# ラインのメッセージ送信
# トークン qXSplrDzc8FQeKhyRYaAzZ2rVfzbp2NlkrNTDZTax4E

class LineNotify
  TOKEN = 'tokenを記載'.freeze
  URL = 'https://notify-api.line.me/api/notify'.freeze

  attr_reader :message

  def self.send(message)
    new(message).send
  end

  def initialize(message)
    @message = message
  end

  def send
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |https|
      https.request(request)
    end
  end

  private

  def request
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{TOKEN}"
    request.set_form_data(message: message)
    request
  end

  def uri
    URI.parse(URL)
  end
end

# 出力（更新されていた場合、txtファイルの書き換えを行う）
if s != list[1]
  LineNotify.send("\n" + "【更新】#{list[1]}" + "\n" + "#{url}")
  txt_write(list[1])
end