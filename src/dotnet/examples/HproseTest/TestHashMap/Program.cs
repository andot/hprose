using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestHashMap
{

    class Program
    {
        static void Main(string[] args)
        {
            HashMap<string, string> map = new HashMap<string, string>();
            map[null] = "null";
            map["name"] = "Ma Bingyao";
            map["sex"] = "male";
            Console.WriteLine(map.Count);
            Console.WriteLine(((IDictionary<string, string>)map).Count);
            Console.WriteLine(((IDictionary)map).Contains(null));
            Console.WriteLine(((IDictionary)map).Contains("name"));
            Console.ReadKey();
        }
    }
}
