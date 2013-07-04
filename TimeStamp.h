//
//  TimeStamp.h
//  HelloWorldOpenCV
//
//  Created by XUDONG LU on 2013-04-17.
//  Copyright (c) 2013 XUDONG LU. All rights reserved.
//

#ifndef HelloWorldOpenCV_TimeStamp_h
#define HelloWorldOpenCV_TimeStamp_h

class TIMER_DEPTH_COUNTER {
public:
        static inline int getDepth() { return mDepth; }
        static inline void push() { mDepth++; }
        static inline void pop() { mDepth--; if(mDepth < 0){ mDepth = 0; } }
private:
        static int mDepth;
};

#define START_TIMER(name) NSTimeInterval pm_timer_start##name = [NSDate timeIntervalSinceReferenceDate]; TIMER_DEPTH_COUNTER::push();
#define END_TIMER(name, msg) NSTimeInterval pm_timer_stop##name = [NSDate timeIntervalSinceReferenceDate]; TIMER_DEPTH_COUNTER::pop(); for(int __i = 0; __i < TIMER_DEPTH_COUNTER::getDepth(); __i++){ printf("\t"); } printf("TIMER (%s) COMPLETE / %f\n", msg, pm_timer_stop##name-pm_timer_start##name);
#define ELAPSED_SINCE_LAST_CALL(name) { static NSTimeInterval rate_timer_last_time = [NSDate timeIntervalSinceReferenceDate]; NSTimeInterval rate_timer_elapsed = [NSDate timeIntervalSinceReferenceDate] - rate_timer_last_time; printf("%s ELAPSED: %0.2f\n", name, rate_timer_elapsed); rate_timer_last_time = [NSDate timeIntervalSinceReferenceDate]; }



#endif
