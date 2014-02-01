using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Hprose.IO;
using System.IO;

namespace TestSerialize
{
    public class User
    {
        public string name;
        public int age;
        public bool male;
        public List<User> friends;
    }
    public enum IntEnum
    {
        First, Second, Third
    }
    public enum UShortEnum : ushort
    {
        First, Second, Third
    }
    public enum LongEnum : long
    {
        First, Second, Third
    }
    class Program
    {
        static void Main(string[] args)
        {
            DateTime start, end;
            int n;
            ArrayList users = new ArrayList();
            User user1 = new User();
            user1.name = "李雷";
            user1.age = 32;
            user1.male = true;
            user1.friends = new List<User>();
            User user2 = new User();
            user2.name = "韩梅梅";
            user2.age = 31;
            user2.male = false;
            user2.friends = new List<User>();
            user1.friends.Add(user2);
            user2.friends.Add(user1);
            users.Add(user1);
            users.Add(user2);

            MemoryStream s = HproseFormatter.Serialize(users, HproseMode.FieldMode);
            Console.WriteLine(Encoding.UTF8.GetString(s.ToArray()));
            s.Position = 0;
            s = HproseFormatter.Serialize(
                HproseFormatter.Unserialize(
                s));
            Console.WriteLine(Encoding.UTF8.GetString(s.ToArray()));
            s.Position = 0;
            List<User> users3 = HproseFormatter.Unserialize<List<User>>(s);
            s = HproseFormatter.Serialize(users3);
            Console.WriteLine(Encoding.UTF8.GetString(s.ToArray()));
            s.Position = 0;
            ArrayList users4 = HproseFormatter.Unserialize<ArrayList>(s);
            s = HproseFormatter.Serialize(users4);
            Console.WriteLine(Encoding.UTF8.GetString(s.ToArray()));
            s.Position = 0;
            s = HproseFormatter.Serialize(new IntEnum[] { IntEnum.First, IntEnum.Second, IntEnum.Third });
            Console.WriteLine(Encoding.UTF8.GetString(s.ToArray()));
            s.Position = 0;
            LongEnum[] longEnums = HproseFormatter.Unserialize<LongEnum[]>(s);
            s = HproseFormatter.Serialize(longEnums);
            Console.WriteLine(Encoding.UTF8.GetString(s.ToArray()));
            s.Position = 0;
            UShortEnum[] ushortEnums = HproseFormatter.Unserialize<UShortEnum[]>(s);
            s = HproseFormatter.Serialize(ushortEnums);
            Console.WriteLine(Encoding.UTF8.GetString(s.ToArray()));
            s.Position = 0;
            
            start = DateTime.Now;
            for (int i = 0; i < 10000; i++)
            {
                HproseFormatter.Serialize(users3);
            }
            end = DateTime.Now;
            Console.WriteLine(end.Ticks - start.Ticks);

            start = DateTime.Now;
            for (int i = 0; i < 10000; i++)
            {
                HproseFormatter.Serialize(users4);
            }
            end = DateTime.Now;
            Console.WriteLine(end.Ticks - start.Ticks);

            start = DateTime.Now;
            for (int i = 0; i < 10000; i++)
            {
                HproseFormatter.Serialize(users3);
            }
            end = DateTime.Now;
            Console.WriteLine(end.Ticks - start.Ticks);

            start = DateTime.Now;
            for (int i = 0; i < 10000; i++)
            {
                HproseFormatter.Serialize(users4);
            }
            end = DateTime.Now;
            Console.WriteLine(end.Ticks - start.Ticks);
            
            Console.ReadKey();
        }
    }
}
