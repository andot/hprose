#if SILVERLIGHT
using System;
using System.Diagnostics;
using System.Threading;

public class ReaderWriterLock {
    int myLock;
    int owners;

    uint numWriteWaiters;
    uint numReadWaiters;
    uint numUpgradeWaiters;

    EventWaitHandle writeEvent;
    EventWaitHandle readEvent;
    EventWaitHandle upgradeEvent;

    public ReaderWriterLock() {
    }

    public void AcquireReaderLock(int millisecondsTimeout) {
        EnterMyLock();
        for (; ; ) {
            if (owners >= 0 && numWriteWaiters == 0) {
                owners++;
                break;
            }
            if (readEvent == null) {
                LazyCreateEvent(ref readEvent, false);
                continue;
            }
            WaitOnEvent(readEvent, ref numReadWaiters, millisecondsTimeout);
        }
        ExitMyLock();
    }

    public void AcquireWriterLock(int millisecondsTimeout) {
        EnterMyLock();
        for (; ; ) {
            if (owners == 0) {
                owners = -1;
                break;
            }

            if (writeEvent == null) {
                LazyCreateEvent(ref writeEvent, true);
                continue;
            }

            WaitOnEvent(writeEvent, ref numWriteWaiters, millisecondsTimeout);
        }
        ExitMyLock();
    }

    public void UpgradeToWriterLock(int millisecondsTimeout) {
        EnterMyLock();
        for (; ; ) {
            if (owners == 1) {
                owners = -1;
                break;
            }

            if (upgradeEvent == null) {
                LazyCreateEvent(ref upgradeEvent, false);
                continue;
            }

            if (numUpgradeWaiters > 0) {
                ExitMyLock();
                throw new InvalidOperationException("UpgradeToWriterLock already in process.  Deadlock!");
            }

            WaitOnEvent(upgradeEvent, ref numUpgradeWaiters, millisecondsTimeout);
        }
        ExitMyLock();
    }

    public void ReleaseReaderLock() {
        EnterMyLock();
        --owners;
        ExitAndWakeUpAppropriateWaiters();
    }

    public void ReleaseWriterLock() {
        EnterMyLock();
        owners++;
        ExitAndWakeUpAppropriateWaiters();
    }

    public void DowngradeToReaderLock() {
        EnterMyLock();
        owners = 1;
        ExitAndWakeUpAppropriateWaiters();
    }

    private void LazyCreateEvent(ref EventWaitHandle waitEvent, bool makeAutoResetEvent) {
        ExitMyLock();
        EventWaitHandle newEvent;
        if (makeAutoResetEvent)
            newEvent = new AutoResetEvent(false);
        else
            newEvent = new ManualResetEvent(false);
        EnterMyLock();
        if (waitEvent == null)
            waitEvent = newEvent;
    }

    private void WaitOnEvent(EventWaitHandle waitEvent, ref uint numWaiters, int millisecondsTimeout) {
        waitEvent.Reset();
        numWaiters++;

        bool waitSuccessful = false;
        ExitMyLock();
        try {
            if (!waitEvent.WaitOne(millisecondsTimeout))
                throw new InvalidOperationException("ReaderWriterLock timeout expired");
            waitSuccessful = true;
        }
        finally {
            EnterMyLock();
            --numWaiters;
            if (!waitSuccessful)
                ExitMyLock();
        }
    }

    private void ExitAndWakeUpAppropriateWaiters() {
        Debug.Assert(MyLockHeld);

        if (owners == 0 && numWriteWaiters > 0) {
            ExitMyLock();
            writeEvent.Set();
        }
        else if (owners == 1 && numUpgradeWaiters != 0) {
            ExitMyLock();
            upgradeEvent.Set();
        }
        else if (owners >= 0 && numReadWaiters != 0) {
            ExitMyLock();
            readEvent.Set();
        }
        else
            ExitMyLock();
    }

    private void EnterMyLock() {
        if (Interlocked.CompareExchange(ref myLock, 1, 0) != 0)
            EnterMyLockSpin();
    }

    private void EnterMyLockSpin() {
        for (int i = 0; ; i++) {
            if (i < 3 && Environment.ProcessorCount > 1)
                Thread.SpinWait(20);
            else
                Thread.Sleep(0);

            if (Interlocked.CompareExchange(ref myLock, 1, 0) == 0)
                return;
        }
    }
    private void ExitMyLock() {
        myLock = 0;
    }

    private bool MyLockHeld {
        get {
            return myLock != 0;
        }
    }

}
#endif