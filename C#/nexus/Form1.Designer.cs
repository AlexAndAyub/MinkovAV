namespace nexus
{
    partial class Form1
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.portal = new System.Windows.Forms.PictureBox();
            this.textBox_path_nexus = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.progressBar1 = new System.Windows.Forms.ProgressBar();
            this.textBox_login = new System.Windows.Forms.TextBox();
            this.textBox_pass = new System.Windows.Forms.TextBox();
            ((System.ComponentModel.ISupportInitialize)(this.portal)).BeginInit();
            this.SuspendLayout();
            // 
            // portal
            // 
            this.portal.Image = ((System.Drawing.Image)(resources.GetObject("portal.Image")));
            this.portal.Location = new System.Drawing.Point(14, 58);
            this.portal.Name = "portal";
            this.portal.Size = new System.Drawing.Size(221, 352);
            this.portal.TabIndex = 0;
            this.portal.TabStop = false;
            this.portal.DragDrop += new System.Windows.Forms.DragEventHandler(this.portal_DragDrop);
            this.portal.DragEnter += new System.Windows.Forms.DragEventHandler(this.portal_DragEnter);
            this.portal.DragLeave += new System.EventHandler(this.portal_DragLeave);
            // 
            // textBox_path_nexus
            // 
            this.textBox_path_nexus.Location = new System.Drawing.Point(0, 223);
            this.textBox_path_nexus.Name = "textBox_path_nexus";
            this.textBox_path_nexus.Size = new System.Drawing.Size(245, 23);
            this.textBox_path_nexus.TabIndex = 1;
            this.textBox_path_nexus.Text = "/test/";
            // 
            // label1
            // 
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(0, 440);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(245, 66);
            this.label1.TabIndex = 2;
            this.label1.Text = "Перетащите файл...";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // progressBar1
            // 
            this.progressBar1.ForeColor = System.Drawing.Color.GreenYellow;
            this.progressBar1.Location = new System.Drawing.Point(0, 413);
            this.progressBar1.Name = "progressBar1";
            this.progressBar1.Size = new System.Drawing.Size(245, 23);
            this.progressBar1.TabIndex = 3;
            // 
            // textBox_login
            // 
            this.textBox_login.Location = new System.Drawing.Point(12, 12);
            this.textBox_login.Name = "textBox_login";
            this.textBox_login.Size = new System.Drawing.Size(100, 23);
            this.textBox_login.TabIndex = 4;
            this.textBox_login.Text = "Логин";
            // 
            // textBox_pass
            // 
            this.textBox_pass.Location = new System.Drawing.Point(134, 12);
            this.textBox_pass.Name = "textBox_pass";
            this.textBox_pass.PasswordChar = '*';
            this.textBox_pass.Size = new System.Drawing.Size(100, 23);
            this.textBox_pass.TabIndex = 5;
            this.textBox_pass.Text = "Пароль";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Black;
            this.ClientSize = new System.Drawing.Size(246, 507);
            this.Controls.Add(this.textBox_pass);
            this.Controls.Add(this.textBox_login);
            this.Controls.Add(this.textBox_path_nexus);
            this.Controls.Add(this.portal);
            this.Controls.Add(this.progressBar1);
            this.Controls.Add(this.label1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "Form1";
            this.Text = "http://seis.rccf.ru/nexus/";
            this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.portal)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private PictureBox portal;
        private TextBox textBox_path_nexus;
        private Label label1;
        private ProgressBar progressBar1;
        private TextBox textBox_login;
        private TextBox textBox_pass;
    }
}