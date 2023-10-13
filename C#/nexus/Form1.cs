using System.Diagnostics;
using System.Net;

namespace nexus
{
    public partial class Form1 : Form
    {
        WebClient webClient;
        Stopwatch sw = new Stopwatch();
        private static string filePath;

        public Form1()
        {
            InitializeComponent();
        }
        private void Form1_Load(object sender, EventArgs e)
        {
            portal.AllowDrop = true;
        }

        void portal_DragDrop(object sender, DragEventArgs e)
        {
            string[] fileList = (string[])e.Data.GetData(DataFormats.FileDrop, false);
            Upload_Files_to_nexus(fileList, e);
        }

        void portal_DragEnter(object sender, DragEventArgs e)
        {
            if (e.Data.GetDataPresent(DataFormats.FileDrop))
            {
                e.Effect = DragDropEffects.Copy;
            }  
        }

        public void Upload_Files_to_nexus(string[] file, DragEventArgs e)
        {

            progressBar1.Value = 0;

            for (int i = 0; i < file.Length; i++)
            {

                    Upload_File_to_nexus(file[i].ToString(), e);

            }
        }

        public void Upload_File_to_nexus(string file, DragEventArgs e)
        {

            using (WebClient webClient = new WebClient())
                {
                    filePath = Path.GetFileName(file);
                    webClient.Credentials = new NetworkCredential(textBox_login.Text, textBox_pass.Text);

                    Uri uri = new Uri("<http://FWDN_server_nesus>/nexus/content/repositories/" + textBox_path_nexus.Text + "/" + filePath);


                    webClient.UploadProgressChanged += UploadFileProgressChanged;
                    /*webClient.UploadProgressChanged += (s, e) => 
                    {

                        progressBar1.Value = e.ProgressPercentage;
                        label1.Text = "Отправляю... " + Environment.NewLine + Path.GetFileName(file) + Environment.NewLine + e.ProgressPercentage + "%";
                        
                    };*/

                    //webClient.UploadProgressChanged += 
                    //webClient.UploadFileCompleted += (s, e) =>
                    //{
                    //    label1.Text = "Перетащите файл...";
                    //    progressBar1.Value = 100;
                    //
                    //};

                    webClient.UploadFileCompleted += UploadFileCallback;

                    webClient.UploadFileAsync(uri, "PUT", file);


            }
 
        }
        private void UploadFileProgressChanged(Object sender, UploadProgressChangedEventArgs e)
        {
            progressBar1.Value = e.ProgressPercentage;
            label1.Text = $"Отправляю... \r {filePath} \r {e.ProgressPercentage} %";

        }


        private void UploadFileCallback(Object sender, UploadFileCompletedEventArgs e)
        {
            try
            {
                string reply = System.Text.Encoding.UTF8.GetString(e.Result);
                label1.Text = "Перетащите файл...";
                progressBar1.Value = 100;
            }
            catch (Exception ex)
            {
                var Message = ex.Message;
                MessageBox.Show(ex.InnerException.Message);
            }

        }

        private void portal_DragLeave(object sender, EventArgs e)
        {

        }

    }
}
