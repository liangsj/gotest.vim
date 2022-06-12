package main

import "testing"

func TestName(t *testing.T) {
	name := Name("liangsj")
	if name != "liangsj" {
		t.Fail()
	}
	t.Log("ok----")
}

func TestOne(t *testing.T){
             t.Fail()
}


func Test1(t *testing.T){}

func Test2(t *testing.T){}
func Test3(t *testing.T){}

func Test4(t *testing.T){}
func Test5(t *testing.T){}
func Test6(t *testing.T){}
func Test7(t *testing.T){}





