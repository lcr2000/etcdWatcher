module etcdWatcher

go 1.13

require (
	github.com/coreos/etcd v3.3.25+incompatible
	github.com/dustin/go-humanize v1.0.0 // indirect
	sigs.k8s.io/yaml v1.2.0 // indirect
)

replace google.golang.org/grpc => google.golang.org/grpc v1.26.0
