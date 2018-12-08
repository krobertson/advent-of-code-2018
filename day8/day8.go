package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

type node struct {
	numChildren int
	numMetadata int
	children    []*node
	metadata    []int
}

func (n *node) String() string {
	return n.string("")
}

func (n *node) string(prefix string) string {
	str := fmt.Sprintf("%schildren: %d\n%smetadata: %+v\n", prefix, n.numChildren, prefix, n.metadata)
	for _, c := range n.children {
		str += c.string(prefix + "  ")
	}
	return str
}

func (n *node) sumMetadata() int {
	sum := 0

	for _, m := range n.metadata {
		sum += m
	}
	for _, c := range n.children {
		sum += c.sumMetadata()
	}

	return sum
}

func (n *node) value() int {
	sum := 0
	for _, m := range n.metadata {
		sum += n.metadataValue(m)
	}
	return sum
}

func (n *node) metadataValue(m int) int {
	if n.numChildren == 0 {
		return m
	}

	if m == 0 {
		return 0
	}

	if m > n.numChildren {
		return 0
	}
	idx := m - 1
	return n.children[idx].value()
}

func parseNode(segments []int) (*node, []int) {
	n := &node{
		numChildren: segments[0],
		numMetadata: segments[1],
		children:    []*node{},
		metadata:    []int{},
	}
	segments = segments[2:]

	for i := 0; i < n.numChildren; i++ {
		var c *node
		c, segments = parseNode(segments)
		n.children = append(n.children, c)
	}

	n.metadata = segments[0:n.numMetadata]
	return n, segments[n.numMetadata:]
}

func main() {
	input, _ := ioutil.ReadFile(os.Args[1])
	var segments []int
	for _, str := range strings.Split(strings.TrimSpace(string(input)), " ") {
		i, _ := strconv.Atoi(str)
		segments = append(segments, i)
	}

	n, _ := parseNode(segments)

	fmt.Printf("%s", n.String())

	fmt.Printf("sum of metadata: %d\n", n.sumMetadata())
	fmt.Printf("value of root node: %d\n", n.value())
}
