using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Hprose.Client;
using Hprose.IO;

namespace HproseClient
{
    public class User
    {
        public string name;
        public int age;
        public bool male;
        public List<User> friends;
    }
    class Program
    {
        static void Main(string[] args)
        {
            ClassManager.Register(typeof(User), "User");
            HproseHttpClient client = new HproseHttpClient("http://localhost:2012/");
            List<User> users = new List<User>();
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
            Func<List<User>, List<User>> SendUsers = userList => client.Invoke<List<User>>("sendUsers", new object[] { userList });

            MemoryStream stream = (MemoryStream)HproseFormatter.Serialize(SendUsers(users));
            Console.WriteLine(Encoding.UTF8.GetString(stream.ToArray()));
            Console.ReadLine();
        }
    }
}
