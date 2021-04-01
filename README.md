# EtcdWatcher

ETCD key监听器实现

### 结构体

```go
// EtcdWatcher是内部维护的一个ETCD key监视器。包含etcd client提供和管理的etcd v3 client会话。
type EtcdWatcher struct {
	// 省略了内部维护的字段
}
```

### 接口
```go
// Listener对外通知接口
// key是键（以字节为单位）。不允许使用空键。
// value是key保存的值，以字节为单位。
// version是key的版本version。删除会将version重置为零，并且对key的任何修改都会增加其version。
// 当Exit方法被调用时，说明watch已经退出。err为退出原因（如果有）。
type Listener interface {
	Set(key []byte, value []byte, version int64)
	Create(key []byte, value []byte, version int64)
	Modify(key []byte, value []byte, version int64)
	Delete(key []byte, version int64)
	Exit(err string)
}
```
当使用方法`AddWatch`时，需要传入一个`Listener`类型的参数。在监听`key`过程中，将对应的事件下发到具体的实现中。使用前，请先实现此接口。

### 方法说明

```go
func NewEtcdWatcher(servers []string) (*EtcdWatcher, error)
```

方法`NewEtcdWatcher`构造一个新的`EtcdWatcher`。`EtcdWatcher`是内部维护的一个`ETCD Key`监视器。入参`servers`是网址列表，如`[]string{"127.0.0.1:2379"}`。

```go
func (mgr *EtcdWatcher) AddWatch(key string, prefix bool, listener Listener) bool
```

方法`AddWatch`添加需要监视的键。入参`key`为需要监视的键； `prefix`允许对具有匹配前缀的键进行操作。例如，`"Get (foo，WithPrefix())" `可以返回`" foo1","foo2"`，依此类推；`listener`当监听到对应的事件时，将动作转发到`Listener`对应的实现。

```go
func (mgr *EtcdWatcher) RemoveWatch(key string) bool
```

方法`RemoveWatch`删除`key`对应的监视。入参`key`为需要删除监视的键。

```go
func (mgr *EtcdWatcher) ClearWatch()
```

方法`ClearWatch`清除所有监视。

```go
func (mgr *EtcdWatcher) Close()
```
方法`Close`关闭`EtcdWatcher`中`etcd`连接。

```go
func (mgr *EtcdWatcher) Put(ctx context.Context, key, value string) (err error)
```

方法`Put`将一个键值对放入`etcd`中。注意：`key`，`value`可以是纯字节数组，而`string`是该字节数组的不可变表示形式。

### 快速开始

```go
package main

import (
   "fmt"
   "testing"
)

var (
   testServer = []string{"127.0.0.1:2379"}
   testKey    = []string{"/test/hello", "/test/world"}
)

func main() {
   // 构造一个watcher
   watcher, err := NewEtcdWatcher(testServer)
   if err != nil {
      fmt.Println(err)
      return
   }
   // 添加对应key的监视 
   for _, key := range testKey {
      watcher.AddWatch(key, false, emptyListen{})
   }
   select {}
}

// emptyListen是实现Listener接口的类
type emptyListen struct{}

func (e emptyListen) Set(key []byte, value []byte, version int64) {
   fmt.Println("set_key:", string(key), "set_val:", string(value), "version:", version)
}

func (e emptyListen) Create(key []byte, value []byte, version int64) {
   fmt.Println("create_key:", string(key), "create_val:", string(value), "version:", version)
}

func (e emptyListen) Modify(key []byte, value []byte, version int64) {
   fmt.Println("modify_key:", string(key), "modify_val:", string(value), "version:", version)
}

func (e emptyListen) Delete(key []byte, version int64) {
   fmt.Println("delete:", string(key), "version:", version)
}

func (e emptyListen) Exit(err string) {
	fmt.Println("watch exit", err)
}
```