// Standalone Windows QA tool, never loaded by Godot. No image pixels are read or saved.
// DXGI Output Duplication timestamps belong to one explicitly selected display.
// This is a capture-path cross-check, not an optical scanout/latency measurement.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text.Json;
using System.Threading;

unsafe class OutputProbe
{
    [DllImport("dxgi.dll")] static extern int CreateDXGIFactory1(ref Guid id, out IntPtr factory);
    [DllImport("d3d11.dll")] static extern int D3D11CreateDevice(IntPtr adapter, uint driver, IntPtr software, uint flags, IntPtr levels, uint levelCount, uint sdk, out IntPtr device, out uint level, out IntPtr context);
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)] struct OutputDesc
    {
        public fixed char name[32];
        public int left, top, right, bottom, attached;
        public uint rotation;
        public IntPtr monitor;
    }
    [StructLayout(LayoutKind.Sequential)] struct FrameInfo
    {
        public long present, mouse;
        public uint accumulated;
        public int coalesced, masked, pointerX, pointerY, pointerVisible;
        public uint metadataBytes, pointerBytes;
    }
    static void Check(int hr) { if (hr < 0) Marshal.ThrowExceptionForHR(hr); }
    static void* Method(IntPtr obj, int slot) => (void*)Marshal.ReadIntPtr(Marshal.ReadIntPtr(obj), slot * IntPtr.Size);
    static void Release(IntPtr obj) { if (obj != IntPtr.Zero) ((delegate* unmanaged[Stdcall]<IntPtr, uint>)Method(obj, 2))(obj); }
    static IntPtr Query(IntPtr obj, Guid id)
    {
        IntPtr result;
        Check(((delegate* unmanaged[Stdcall]<IntPtr, Guid*, IntPtr*, int>)Method(obj, 0))(obj, &id, &result));
        return result;
    }
    static int Main(string[] args)
    {
        IntPtr factory=IntPtr.Zero, adapter=IntPtr.Zero, output=IntPtr.Zero, output1=IntPtr.Zero, device=IntPtr.Zero, context=IntPtr.Zero, duplicate=IntPtr.Zero;
        try
        {
            // Output indices are DXGI's, not Godot's. Print geometry before selecting.
            var factoryId = new Guid("770aae78-f26f-4dba-a829-253c83d1b387");
            Check(CreateDXGIFactory1(ref factoryId, out factory));
            var enumAdapters = (delegate* unmanaged[Stdcall]<IntPtr, uint, IntPtr*, int>)Method(factory, 12);
            Check(enumAdapters(factory, 0, &adapter));
            var enumOutputs = (delegate* unmanaged[Stdcall]<IntPtr, uint, IntPtr*, int>)Method(adapter, 7);
            for (uint i=0; ; i++)
            {
                IntPtr candidate;
                int hr=enumOutputs(adapter,i,&candidate);
                if ((uint)hr==0x887A0002) break;
                Check(hr);
                OutputDesc desc;
                Check(((delegate* unmanaged[Stdcall]<IntPtr, OutputDesc*, int>)Method(candidate,7))(candidate,&desc));
                Console.WriteLine($"DXGI output {i}: {new string(desc.name)} ({desc.left},{desc.top})-({desc.right},{desc.bottom})");
                Release(candidate);
            }
            if (args.Length==0) return 0;
            uint index=uint.Parse(args[0]);
            int duration=int.Parse(args[1]), delay=int.Parse(args[2]);
            Check(enumOutputs(adapter,index,&output));
            OutputDesc selected;
            Check(((delegate* unmanaged[Stdcall]<IntPtr, OutputDesc*, int>)Method(output,7))(output,&selected));
            Check(D3D11CreateDevice(adapter,0,IntPtr.Zero,0,IntPtr.Zero,0,7,out device,out _,out context));
            output1=Query(output,new Guid("00cddea8-939b-4b83-a340-a685226666cc"));
            Thread.Sleep(delay*1000);
            Check(((delegate* unmanaged[Stdcall]<IntPtr, IntPtr, IntPtr*, int>)Method(output1,22))(output1,device,&duplicate));
            var acquire=(delegate* unmanaged[Stdcall]<IntPtr, uint, FrameInfo*, IntPtr*, int>)Method(duplicate,8);
            var releaseFrame=(delegate* unmanaged[Stdcall]<IntPtr, int>)Method(duplicate,14);
            var samples=new List<object>();
            var intervals=new List<double>();
            long previous=0;
            uint accumulatedMax=0;
            int mouseOnly=0;
            var timer=Stopwatch.StartNew();
            while(timer.Elapsed.TotalSeconds<duration)
            {
                FrameInfo frame;
                IntPtr resource;
                int hr=acquire(duplicate,1000,&frame,&resource);
                if ((uint)hr==0x887A0027) continue; // WAIT_TIMEOUT
                Check(hr);
                Release(resource);
                Check(releaseFrame(duplicate));
                if(frame.present==0) { mouseOnly++; continue; }
                double interval=previous==0 ? 0 : (frame.present-previous)*1000.0/Stopwatch.Frequency;
                if(previous!=0) intervals.Add(interval);
                samples.Add(new { qpc=frame.present, interval_ms=interval, accumulated_frames=frame.accumulated, coalesced=frame.coalesced!=0, protected_content=frame.masked!=0 });
                previous=frame.present;
                accumulatedMax=Math.Max(accumulatedMax,frame.accumulated);
            }
            if(intervals.Count<10) throw new Exception("Insufficient display updates");
            double[] sorted=intervals.OrderBy(x=>x).ToArray();
            double Q(double p)=>sorted[(int)Math.Ceiling(sorted.Length*p)-1];
            var report=new { method="DXGI Output Duplication metadata; no pixel readback", output_index=index, device_name=new string(selected.name), rectangle=new[]{selected.left,selected.top,selected.right,selected.bottom}, qpc_frequency=Stopwatch.Frequency, seconds=timer.Elapsed.TotalSeconds, frames=intervals.Count, mean_fps=1000/intervals.Average(), p95_ms=Q(.95), p99_ms=Q(.99), max_ms=sorted[^1], over_20=intervals.Count(x=>x>20), accumulated_max=accumulatedMax, mouse_only=mouseOnly, samples };
            File.WriteAllText(args[3],JsonSerializer.Serialize(report,new JsonSerializerOptions{WriteIndented=true})+"\n");
            Console.WriteLine($"{intervals.Count} intervals: {1000/intervals.Average():F3} FPS, p99 {Q(.99):F3} ms, max {sorted[^1]:F3} ms, >20 {intervals.Count(x=>x>20)}");
            return 0;
        }
        catch(Exception error) { Console.Error.WriteLine(error); return 1; }
        finally { Release(duplicate); Release(context); Release(device); Release(output1); Release(output); Release(adapter); Release(factory); }
    }
}
