#!/usr/bin/env bash

url="https://www.colamanga.com/js/custom.js"
savePath="coco.js"
ua_string="user-agent:Mozilla/5.0 (Linux; Android 11;Pixel XL) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/100.0.4896.79 Mobile Safari/537.36"

# 启用选项
# 对应依赖 package.json requirements.txt
use_puppeteer=true
# 似乎无法通过
use_cloudscraper=false
# 建议使用puppeteer
use_selenium=false


function extraKeys() {
    [ -e decodeObfuscator ] || git clone https://github.com/xiaohan231/decodeObfuscator --depth 1
    node ./decodeObfuscator/main.js $savePath common cocomanhua
}

function checkDown() {
   if [ -e $savePath ]; then
       [ -z "$(cat $savePath | grep "<html")" ] && return 0
   else
       return 1
   fi
}

function cloudscraper() {
    echo -e "\033[42;30m INFO \033[40;32m start cloudscraper"
    python3 ./lib/cloudscraper_fetch.py $url $savePath
    if checkDown;then
        extraKeys
        return 0
    else
       echo -e "\033[41;30m ERROR \033[40;31m cloudscraper fetch content error"
       return 1
    fi
}

function selenium() {
    echo -e "\033[42;30m INFO \033[40;32m start selenium"
    python3 ./lib/selenium_fetch.py $url $savePath
    if checkDown;then
        extraKeys
        return 0
    else
       echo -e "\033[41;30m ERROR \033[40;31m selenium fetch content error"
       return 1
    fi
}

function puppeteer() {
    echo -e "\033[42;30m INFO \033[40;32m start puppeteer"
    node ./lib/puppeteer_fetch.js $url $savePath
    if checkDown;then
        extraKeys
        return 0
    else
       echo -e "\033[41;30m ERROR \033[40;31m puppeteer fetch content error"
       return 1
    fi
}

function main() {
    echo -e "\033[42;30m INFO \033[40;32m fetch $url"
    statusCode=$(curl -s -I -H "$ua_string" -w %{http_code} "$url" -o /dev/null)
    #statusCode=504
    if [ $statusCode == "200" ];then
        curl -s -H "$ua_string" "$url" -o "$savePath"
    else
        echo -e "\033[42;30m INFO \033[40;32m http code is $statusCode try bypass tool"
    fi

    if checkDown;then
        extraKeys
    else
        $use_cloudscraper && cloudscraper && exit
        $use_puppeteer && puppeteer && exit
        $use_selenium && selenium && exit
    fi
}
