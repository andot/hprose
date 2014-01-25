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
 * LastModified: Jan 17, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose

type Filter interface {
	InputFilter([]byte) []byte
	OutputFilter([]byte) []byte
}
