using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Hprose.Server;
using Hprose.IO;

namespace HproseServer
{
    public class User
    {
        public string name;
        public int age;
        public bool male;
        public List<User> friends;
    }
    class TestService
    {
        public List<User> SendUsers(List<User> users)
        {
            foreach (User user in users)
            {
                Console.WriteLine("name={0}, age={1}, male={2}", user.name, user.age, user.male);
            }
            return users;
        }
    }
    class Program
    {
        static void Main(string[] args)
        {
            ClassManager.Register(typeof(User), "User");
            HproseHttpListenerServer server = new HproseHttpListenerServer("http://localhost:2012/");
            server.Methods.AddInstanceMethods(new TestService());
            server.IsCrossDomainEnabled = true;
            server.CrossDomainXmlFile = "crossdomain.xml";
            server.Start();
            Console.WriteLine("Server started.");
            Console.ReadLine();
            Console.WriteLine("Server stopped.");
        }
    }
}
