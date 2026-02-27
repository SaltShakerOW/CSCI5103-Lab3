// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

#define NSUPERPAGES 60 //per the lab document

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

struct {
  struct spinlock lock; //lock specifically for supermem operations
  void *superpages[NSUPERPAGES]; //array to catalog our superpages
  int nfree; //number of free superpages
} supermem;

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  superinit(); //allocate space for superpages before regular pages
  freerange(end, (void*)PHYSTOP - (uint64)NSUPERPAGES * SUPERPGSIZE); //modification made here to ensure space for 60 superpages
}

void
superinit() {
  initlock(&supermem.lock, "supermem");
  supermem.nfree = 0; //reset number of free superpages

  uint64 top = PHYSTOP; //start allocation at top of memory space
  for (int i = 0; i < NSUPERPAGES; i++) { //free up memory for each superpage
    top -= SUPERPGSIZE;
    top = top & ~((uint64)SUPERPGSIZE - 1); //superpage boundary alignment
    supermem.superpages[supermem.nfree] = (void*)top; //add superpage address to pool
    supermem.nfree++; //increase number of free superpages
  }
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    kfree(p);
  }
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if (r) {
    kmem.freelist = r->next;
  }
  release(&kmem.lock);

  if (r) {
    memset((char*)r, 5, PGSIZE); // fill with junk
  }
  return (void*)r;
}

void *
superalloc(void) {
  acquire(&supermem.lock);
  if (supermem.nfree == 0) { //no free superpages
    release(&supermem.lock);
    return 0;
  }
  supermem.nfree--;
  void *pg = supermem.superpages[supermem.nfree];
  release(&supermem.lock);
  memset(pg, 5, SUPERPGSIZE);
  return pg;
}

void
superfree(void *pa) {
  if (((uint64)pa & (SUPERPGSIZE - 1)) != 0) { //check if pa belongs to our address pool (address alignment)
    panic("superfree: pa not 2MiB aligned");
  }
  if ((uint64)pa < PHYSTOP - (uint64)NSUPERPAGES * SUPERPGSIZE || (uint64)pa >= PHYSTOP) {
    panic("superfree: pa outside of superpage pool range");
  }
  memset(pa, 1, SUPERPGSIZE); //set page to junk just like kfree
  acquire(&supermem.lock);
  if (supermem.nfree >= NSUPERPAGES) {
    panic("superfree: superpage pool overflow");
  }
  supermem.superpages[supermem.nfree] = pa;
  supermem.nfree++;
  release(&supermem.lock);
}
