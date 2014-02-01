/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.net/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * hprose/filter.go                                       *
 *                                                        *
 * hprose filter interface for Go.                        *
 *                                                        *
 * LastModified: Feb 1, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

import (
	"io"
)

type Filter interface {
	InputFilter(io.Reader) io.Reader
	OutputFilter([]byte) []byte
}
