using System;
using System.IO;

class WavGen {
    static int SR = 22050;
    
    static void WriteWav(string path, short[] samp) {
        MemoryStream ms = new MemoryStream();
        BinaryWriter bw = new BinaryWriter(ms);
        int ds = samp.Length * 2;
        bw.Write(new byte[]{82,73,70,70});
        bw.Write(ds + 36);
        bw.Write(new byte[]{87,65,86,69,102,109,116,32});
        bw.Write(16);
        bw.Write((short)1);
        bw.Write((short)1);
        bw.Write(SR);
        bw.Write(SR * 2);
        bw.Write((short)2);
        bw.Write((short)16);
        bw.Write(new byte[]{100,97,116,97});
        bw.Write(ds);
        foreach(short s in samp) bw.Write(s);
        File.WriteAllBytes(path, ms.ToArray());
    }
    
    static short Clamp(double v) {
        int i = (int)(v * 32767);
        if(i > 32767) i = 32767;
        if(i < -32767) i = -32767;
        return (short)i;
    }
    
    static void Main() {
        string dir = @"C:\Users\yusuf\Documents\yeni-oyun-projesi\sounds";
        int n; short[] buf;
        
        // HEARTBEAT
        n = (int)(SR * 1.2);
        buf = new short[n];
        for(int i = 0; i < n; i++) {
            double t = i / (double)SR;
            double v = 0;
            if(t < 0.12)
                v = Math.Sin(Math.PI * t / 0.12) * Math.Exp(-t * 18) * 0.85;
            if(t >= 0.18 && t < 0.30) {
                double tt = t - 0.18;
                v = Math.Sin(Math.PI * tt / 0.12) * Math.Exp(-tt * 14) * 0.55;
            }
            buf[i] = Clamp(v);
        }
        WriteWav(Path.Combine(dir, "heartbeat.wav"), buf);
        Console.WriteLine("OK heartbeat.wav");
        
        // FOOTSTEP
        n = (int)(SR * 0.20);
        buf = new short[n];
        Random rnd = new Random(42);
        for(int i = 0; i < n; i++) {
            double t = i / (double)SR;
            double f = 80 * Math.Exp(-t * 25);
            double v = Math.Sin(2 * Math.PI * f * t) * Math.Exp(-t * 30) * 0.6;
            v += (rnd.NextDouble() * 2 - 1) * 0.12 * Math.Exp(-t * 40);
            buf[i] = Clamp(v);
        }
        WriteWav(Path.Combine(dir, "footstep.wav"), buf);
        Console.WriteLine("OK footstep.wav");
        
        // HIT IMPACT
        n = (int)(SR * 0.18);
        buf = new short[n];
        for(int i = 0; i < n; i++) {
            double t = i / (double)SR;
            double v = Math.Sin(2 * Math.PI * 440 * t) * 0.4;
            v += Math.Sin(2 * Math.PI * 880 * t) * 0.3;
            v += Math.Sin(2 * Math.PI * 220 * t) * 0.2;
            v *= Math.Exp(-t * 22);
            buf[i] = Clamp(v);
        }
        WriteWav(Path.Combine(dir, "hit_impact.wav"), buf);
        Console.WriteLine("OK hit_impact.wav");
        
        Console.WriteLine("TUM SESLER TAMAM");
    }
}
