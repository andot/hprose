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
 * LastModified: Feb 2, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

type Filter interface {
	InputFilter(BufReader) BufReader
	OutputFilter([]byte) []byte
}
