package main

import "fmt"

func main(){
	fmt.Println("hello vim-sript")
	g := &GoTest{}
	g.vimL()
}


func  Name(name string)string{
	return name
}

type GoTest struct{
	name string
	scrit string
}
func (g *GoTest)vimL()string{
	fmt.Println(g.name)
	fmt.Println(g.scrit)
	return "ok"
}
