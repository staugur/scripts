package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
)

//定义检测 http 服务的脚本，成功返回1，失败返回0
func chttp(url, checkword string) int {
	res, err := http.Get(url)
	if err != nil {
		//如果连接失败返回错误
		panic(err)
	}

	//使用 ioutil 读取得到的响应
	robots, err := ioutil.ReadAll(res.Body)
	//关闭资源
	res.Body.Close()

	//失败返回原因
	if err != nil {
		fmt.Println(err.Error())
		return 0
	}

	//调用 regexp 函数查找 checkword
	word, err := regexp.MatchString(checkword, string(robots))
	if err != nil {
		fmt.Println(err)
		return 0
	}
	if word {
		fmt.Printf("The `%s` find in `%s`\n", checkword, url)
		return 1
	}
	fmt.Printf("The `%s` not find in `%s`\n", checkword, url)
	return 0
}

func main() {
	if len(os.Args) < 3 {
		fmt.Printf("usage: %s url keyword\n", filepath.Base(os.Args[0]))
		return
	}
	chttp(os.Args[1], os.Args[2])
}
