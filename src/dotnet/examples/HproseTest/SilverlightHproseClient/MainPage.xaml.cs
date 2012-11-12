using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using Hprose.Client;
using Hprose.Common;
using Hprose.IO;
using System.IO;
using System.Text;
using System.Threading;

namespace SilverlightHproseClient
{
    public partial class MainPage : UserControl
    {
        public MainPage()
        {
            InitializeComponent();
        }

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            //HproseClient.SynchronizationContext = SynchronizationContext.Current;
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
            MemoryStream stream = HproseFormatter.Serialize(users);
            byte[] bytes = stream.ToArray();
            System.Windows.Browser.HtmlPage.Window.Eval("alert('" + UTF8Encoding.UTF8.GetString(bytes, 0, bytes.Length) + "')");

            var AsyncSendUsers = client.GetAsyncAction<List<User>, HproseCallback1<List<User>>>("sendUsers");
            AsyncSendUsers(users, result =>
            {
                MemoryStream s = HproseFormatter.Serialize(result);
                byte[] b = s.ToArray();
                System.Windows.Browser.HtmlPage.Window.Eval("alert('" + UTF8Encoding.UTF8.GetString(b, 0, b.Length) + "')");
            });

            new Thread(() =>
            {
                var SendUsers = client.GetFunc<List<User>, List<User>>("sendUsers");
                MemoryStream ss = HproseFormatter.Serialize(SendUsers(users));
                byte[] bb = ss.ToArray();
                Dispatcher.BeginInvoke(() =>
                {
                    System.Windows.Browser.HtmlPage.Window.Eval("alert('" + UTF8Encoding.UTF8.GetString(bb, 0, bb.Length) + "')");
                });
            }).Start();
        }
    }
}
