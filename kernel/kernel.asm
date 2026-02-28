
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	a5013103          	ld	sp,-1456(sp) # 80007a50 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	767040ef          	jal	ra,80004f7c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <superinit>:
  superinit(); //allocate space for superpages before regular pages
  freerange(end, (void*)PHYSTOP - (uint64)NSUPERPAGES * SUPERPGSIZE); //modification made here to ensure space for 60 superpages
}

void
superinit() {
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
  initlock(&supermem.lock, "supermem");
    80000024:	00007597          	auipc	a1,0x7
    80000028:	fec58593          	addi	a1,a1,-20 # 80007010 <etext+0x10>
    8000002c:	00008517          	auipc	a0,0x8
    80000030:	a7450513          	addi	a0,a0,-1420 # 80007aa0 <supermem>
    80000034:	0cf050ef          	jal	ra,80005902 <initlock>
  supermem.nfree = 0; //reset number of free superpages

  uint64 top = PHYSTOP; //start allocation at top of memory space
  for (int i = 0; i < NSUPERPAGES; i++) { //free up memory for each superpage
    80000038:	00008697          	auipc	a3,0x8
    8000003c:	a8068693          	addi	a3,a3,-1408 # 80007ab8 <supermem+0x18>
  initlock(&supermem.lock, "supermem");
    80000040:	4705                	li	a4,1
  uint64 top = PHYSTOP; //start allocation at top of memory space
    80000042:	47c5                	li	a5,17
    80000044:	07ee                	slli	a5,a5,0x1b
    top -= SUPERPGSIZE;
    80000046:	ffe00537          	lui	a0,0xffe00
  for (int i = 0; i < NSUPERPAGES; i++) { //free up memory for each superpage
    8000004a:	10100613          	li	a2,257
    8000004e:	065e                	slli	a2,a2,0x17
    top -= SUPERPGSIZE;
    80000050:	97aa                	add	a5,a5,a0
    top = top & ~((uint64)SUPERPGSIZE - 1); //superpage boundary alignment
    supermem.superpages[supermem.nfree] = (void*)top; //add superpage address to pool
    80000052:	e29c                	sd	a5,0(a3)
    supermem.nfree++; //increase number of free superpages
    80000054:	0007059b          	sext.w	a1,a4
  for (int i = 0; i < NSUPERPAGES; i++) { //free up memory for each superpage
    80000058:	0705                	addi	a4,a4,1
    8000005a:	06a1                	addi	a3,a3,8
    8000005c:	fec79ae3          	bne	a5,a2,80000050 <superinit+0x34>
    80000060:	00008797          	auipc	a5,0x8
    80000064:	c2b7ac23          	sw	a1,-968(a5) # 80007c98 <supermem+0x1f8>
  }
}
    80000068:	60a2                	ld	ra,8(sp)
    8000006a:	6402                	ld	s0,0(sp)
    8000006c:	0141                	addi	sp,sp,16
    8000006e:	8082                	ret

0000000080000070 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000070:	7179                	addi	sp,sp,-48
    80000072:	f406                	sd	ra,40(sp)
    80000074:	f022                	sd	s0,32(sp)
    80000076:	ec26                	sd	s1,24(sp)
    80000078:	e84a                	sd	s2,16(sp)
    8000007a:	e44e                	sd	s3,8(sp)
    8000007c:	1800                	addi	s0,sp,48
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    8000007e:	03451793          	slli	a5,a0,0x34
    80000082:	ebb1                	bnez	a5,800000d6 <kfree+0x66>
    80000084:	84aa                	mv	s1,a0
    80000086:	00021797          	auipc	a5,0x21
    8000008a:	f4a78793          	addi	a5,a5,-182 # 80020fd0 <end>
    8000008e:	04f56463          	bltu	a0,a5,800000d6 <kfree+0x66>
    80000092:	47c5                	li	a5,17
    80000094:	07ee                	slli	a5,a5,0x1b
    80000096:	04f57063          	bgeu	a0,a5,800000d6 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    8000009a:	6605                	lui	a2,0x1
    8000009c:	4585                	li	a1,1
    8000009e:	214000ef          	jal	ra,800002b2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    800000a2:	00008997          	auipc	s3,0x8
    800000a6:	9fe98993          	addi	s3,s3,-1538 # 80007aa0 <supermem>
    800000aa:	00008917          	auipc	s2,0x8
    800000ae:	bf690913          	addi	s2,s2,-1034 # 80007ca0 <kmem>
    800000b2:	854a                	mv	a0,s2
    800000b4:	0cf050ef          	jal	ra,80005982 <acquire>
  r->next = kmem.freelist;
    800000b8:	2189b783          	ld	a5,536(s3)
    800000bc:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800000be:	2099bc23          	sd	s1,536(s3)
  release(&kmem.lock);
    800000c2:	854a                	mv	a0,s2
    800000c4:	157050ef          	jal	ra,80005a1a <release>
}
    800000c8:	70a2                	ld	ra,40(sp)
    800000ca:	7402                	ld	s0,32(sp)
    800000cc:	64e2                	ld	s1,24(sp)
    800000ce:	6942                	ld	s2,16(sp)
    800000d0:	69a2                	ld	s3,8(sp)
    800000d2:	6145                	addi	sp,sp,48
    800000d4:	8082                	ret
    panic("kfree");
    800000d6:	00007517          	auipc	a0,0x7
    800000da:	f4a50513          	addi	a0,a0,-182 # 80007020 <etext+0x20>
    800000de:	594050ef          	jal	ra,80005672 <panic>

00000000800000e2 <freerange>:
{
    800000e2:	7179                	addi	sp,sp,-48
    800000e4:	f406                	sd	ra,40(sp)
    800000e6:	f022                	sd	s0,32(sp)
    800000e8:	ec26                	sd	s1,24(sp)
    800000ea:	e84a                	sd	s2,16(sp)
    800000ec:	e44e                	sd	s3,8(sp)
    800000ee:	e052                	sd	s4,0(sp)
    800000f0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800000f2:	6785                	lui	a5,0x1
    800000f4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    800000f8:	00e504b3          	add	s1,a0,a4
    800000fc:	777d                	lui	a4,0xfffff
    800000fe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000100:	94be                	add	s1,s1,a5
    80000102:	0095ec63          	bltu	a1,s1,8000011a <freerange+0x38>
    80000106:	892e                	mv	s2,a1
    kfree(p);
    80000108:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    8000010a:	6985                	lui	s3,0x1
    kfree(p);
    8000010c:	01448533          	add	a0,s1,s4
    80000110:	f61ff0ef          	jal	ra,80000070 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000114:	94ce                	add	s1,s1,s3
    80000116:	fe997be3          	bgeu	s2,s1,8000010c <freerange+0x2a>
}
    8000011a:	70a2                	ld	ra,40(sp)
    8000011c:	7402                	ld	s0,32(sp)
    8000011e:	64e2                	ld	s1,24(sp)
    80000120:	6942                	ld	s2,16(sp)
    80000122:	69a2                	ld	s3,8(sp)
    80000124:	6a02                	ld	s4,0(sp)
    80000126:	6145                	addi	sp,sp,48
    80000128:	8082                	ret

000000008000012a <kinit>:
{
    8000012a:	1141                	addi	sp,sp,-16
    8000012c:	e406                	sd	ra,8(sp)
    8000012e:	e022                	sd	s0,0(sp)
    80000130:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000132:	00007597          	auipc	a1,0x7
    80000136:	ef658593          	addi	a1,a1,-266 # 80007028 <etext+0x28>
    8000013a:	00008517          	auipc	a0,0x8
    8000013e:	b6650513          	addi	a0,a0,-1178 # 80007ca0 <kmem>
    80000142:	7c0050ef          	jal	ra,80005902 <initlock>
  superinit(); //allocate space for superpages before regular pages
    80000146:	ed7ff0ef          	jal	ra,8000001c <superinit>
  freerange(end, (void*)PHYSTOP - (uint64)NSUPERPAGES * SUPERPGSIZE); //modification made here to ensure space for 60 superpages
    8000014a:	10100593          	li	a1,257
    8000014e:	05de                	slli	a1,a1,0x17
    80000150:	00021517          	auipc	a0,0x21
    80000154:	e8050513          	addi	a0,a0,-384 # 80020fd0 <end>
    80000158:	f8bff0ef          	jal	ra,800000e2 <freerange>
}
    8000015c:	60a2                	ld	ra,8(sp)
    8000015e:	6402                	ld	s0,0(sp)
    80000160:	0141                	addi	sp,sp,16
    80000162:	8082                	ret

0000000080000164 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000164:	1101                	addi	sp,sp,-32
    80000166:	ec06                	sd	ra,24(sp)
    80000168:	e822                	sd	s0,16(sp)
    8000016a:	e426                	sd	s1,8(sp)
    8000016c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    8000016e:	00008517          	auipc	a0,0x8
    80000172:	b3250513          	addi	a0,a0,-1230 # 80007ca0 <kmem>
    80000176:	00d050ef          	jal	ra,80005982 <acquire>
  r = kmem.freelist;
    8000017a:	00008497          	auipc	s1,0x8
    8000017e:	b3e4b483          	ld	s1,-1218(s1) # 80007cb8 <kmem+0x18>
  if (r) {
    80000182:	c49d                	beqz	s1,800001b0 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000184:	609c                	ld	a5,0(s1)
    80000186:	00008717          	auipc	a4,0x8
    8000018a:	b2f73923          	sd	a5,-1230(a4) # 80007cb8 <kmem+0x18>
  }
  release(&kmem.lock);
    8000018e:	00008517          	auipc	a0,0x8
    80000192:	b1250513          	addi	a0,a0,-1262 # 80007ca0 <kmem>
    80000196:	085050ef          	jal	ra,80005a1a <release>

  if (r) {
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000019a:	6605                	lui	a2,0x1
    8000019c:	4595                	li	a1,5
    8000019e:	8526                	mv	a0,s1
    800001a0:	112000ef          	jal	ra,800002b2 <memset>
  }
  return (void*)r;
}
    800001a4:	8526                	mv	a0,s1
    800001a6:	60e2                	ld	ra,24(sp)
    800001a8:	6442                	ld	s0,16(sp)
    800001aa:	64a2                	ld	s1,8(sp)
    800001ac:	6105                	addi	sp,sp,32
    800001ae:	8082                	ret
  release(&kmem.lock);
    800001b0:	00008517          	auipc	a0,0x8
    800001b4:	af050513          	addi	a0,a0,-1296 # 80007ca0 <kmem>
    800001b8:	063050ef          	jal	ra,80005a1a <release>
  if (r) {
    800001bc:	b7e5                	j	800001a4 <kalloc+0x40>

00000000800001be <superalloc>:

void *
superalloc(void) {
    800001be:	1101                	addi	sp,sp,-32
    800001c0:	ec06                	sd	ra,24(sp)
    800001c2:	e822                	sd	s0,16(sp)
    800001c4:	e426                	sd	s1,8(sp)
    800001c6:	1000                	addi	s0,sp,32
  acquire(&supermem.lock);
    800001c8:	00008497          	auipc	s1,0x8
    800001cc:	8d848493          	addi	s1,s1,-1832 # 80007aa0 <supermem>
    800001d0:	8526                	mv	a0,s1
    800001d2:	7b0050ef          	jal	ra,80005982 <acquire>
  if (supermem.nfree == 0) { //no free superpages
    800001d6:	1f84a783          	lw	a5,504(s1)
    800001da:	cf8d                	beqz	a5,80000214 <superalloc+0x56>
    release(&supermem.lock);
    return 0;
  }
  supermem.nfree--;
    800001dc:	fff7871b          	addiw	a4,a5,-1
    800001e0:	0007079b          	sext.w	a5,a4
    800001e4:	00008517          	auipc	a0,0x8
    800001e8:	8bc50513          	addi	a0,a0,-1860 # 80007aa0 <supermem>
    800001ec:	1ee52c23          	sw	a4,504(a0)
  void *pg = supermem.superpages[supermem.nfree];
    800001f0:	0789                	addi	a5,a5,2
    800001f2:	078e                	slli	a5,a5,0x3
    800001f4:	97aa                	add	a5,a5,a0
    800001f6:	6784                	ld	s1,8(a5)
  release(&supermem.lock);
    800001f8:	023050ef          	jal	ra,80005a1a <release>
  memset(pg, 5, SUPERPGSIZE);
    800001fc:	00200637          	lui	a2,0x200
    80000200:	4595                	li	a1,5
    80000202:	8526                	mv	a0,s1
    80000204:	0ae000ef          	jal	ra,800002b2 <memset>
  return pg;
}
    80000208:	8526                	mv	a0,s1
    8000020a:	60e2                	ld	ra,24(sp)
    8000020c:	6442                	ld	s0,16(sp)
    8000020e:	64a2                	ld	s1,8(sp)
    80000210:	6105                	addi	sp,sp,32
    80000212:	8082                	ret
    release(&supermem.lock);
    80000214:	8526                	mv	a0,s1
    80000216:	005050ef          	jal	ra,80005a1a <release>
    return 0;
    8000021a:	4481                	li	s1,0
    8000021c:	b7f5                	j	80000208 <superalloc+0x4a>

000000008000021e <superfree>:

void
superfree(void *pa) {
    8000021e:	1101                	addi	sp,sp,-32
    80000220:	ec06                	sd	ra,24(sp)
    80000222:	e822                	sd	s0,16(sp)
    80000224:	e426                	sd	s1,8(sp)
    80000226:	e04a                	sd	s2,0(sp)
    80000228:	1000                	addi	s0,sp,32
  if ((uint64)pa % SUPERPGSIZE != 0) { //check if pa belongs to our address pool (address alignment)
    8000022a:	02b51793          	slli	a5,a0,0x2b
    8000022e:	e3a5                	bnez	a5,8000028e <superfree+0x70>
    80000230:	84aa                	mv	s1,a0
    panic("superfree: pa not 2MiB aligned");
  }
  if ((uint64)pa < PHYSTOP - (uint64)NSUPERPAGES * SUPERPGSIZE || (uint64)pa >= PHYSTOP) {
    80000232:	eff00793          	li	a5,-257
    80000236:	07de                	slli	a5,a5,0x17
    80000238:	97aa                	add	a5,a5,a0
    8000023a:	07800737          	lui	a4,0x7800
    8000023e:	04e7fe63          	bgeu	a5,a4,8000029a <superfree+0x7c>
    panic("superfree: pa outside of superpage pool range");
  }
  memset(pa, 1, SUPERPGSIZE); //set page to junk just like kfree
    80000242:	00200637          	lui	a2,0x200
    80000246:	4585                	li	a1,1
    80000248:	06a000ef          	jal	ra,800002b2 <memset>
  acquire(&supermem.lock);
    8000024c:	00008917          	auipc	s2,0x8
    80000250:	85490913          	addi	s2,s2,-1964 # 80007aa0 <supermem>
    80000254:	854a                	mv	a0,s2
    80000256:	72c050ef          	jal	ra,80005982 <acquire>
  if (supermem.nfree >= NSUPERPAGES) {
    8000025a:	1f892783          	lw	a5,504(s2)
    8000025e:	03b00713          	li	a4,59
    80000262:	04f74263          	blt	a4,a5,800002a6 <superfree+0x88>
    panic("superfree: superpage pool overflow");
  }
  supermem.superpages[supermem.nfree] = pa;
    80000266:	00008517          	auipc	a0,0x8
    8000026a:	83a50513          	addi	a0,a0,-1990 # 80007aa0 <supermem>
    8000026e:	00278713          	addi	a4,a5,2
    80000272:	070e                	slli	a4,a4,0x3
    80000274:	972a                	add	a4,a4,a0
    80000276:	e704                	sd	s1,8(a4)
  supermem.nfree++;
    80000278:	2785                	addiw	a5,a5,1
    8000027a:	1ef52c23          	sw	a5,504(a0)
  release(&supermem.lock);
    8000027e:	79c050ef          	jal	ra,80005a1a <release>
}
    80000282:	60e2                	ld	ra,24(sp)
    80000284:	6442                	ld	s0,16(sp)
    80000286:	64a2                	ld	s1,8(sp)
    80000288:	6902                	ld	s2,0(sp)
    8000028a:	6105                	addi	sp,sp,32
    8000028c:	8082                	ret
    panic("superfree: pa not 2MiB aligned");
    8000028e:	00007517          	auipc	a0,0x7
    80000292:	da250513          	addi	a0,a0,-606 # 80007030 <etext+0x30>
    80000296:	3dc050ef          	jal	ra,80005672 <panic>
    panic("superfree: pa outside of superpage pool range");
    8000029a:	00007517          	auipc	a0,0x7
    8000029e:	db650513          	addi	a0,a0,-586 # 80007050 <etext+0x50>
    800002a2:	3d0050ef          	jal	ra,80005672 <panic>
    panic("superfree: superpage pool overflow");
    800002a6:	00007517          	auipc	a0,0x7
    800002aa:	dda50513          	addi	a0,a0,-550 # 80007080 <etext+0x80>
    800002ae:	3c4050ef          	jal	ra,80005672 <panic>

00000000800002b2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800002b2:	1141                	addi	sp,sp,-16
    800002b4:	e422                	sd	s0,8(sp)
    800002b6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800002b8:	ca19                	beqz	a2,800002ce <memset+0x1c>
    800002ba:	87aa                	mv	a5,a0
    800002bc:	1602                	slli	a2,a2,0x20
    800002be:	9201                	srli	a2,a2,0x20
    800002c0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    800002c4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800002c8:	0785                	addi	a5,a5,1
    800002ca:	fee79de3          	bne	a5,a4,800002c4 <memset+0x12>
  }
  return dst;
}
    800002ce:	6422                	ld	s0,8(sp)
    800002d0:	0141                	addi	sp,sp,16
    800002d2:	8082                	ret

00000000800002d4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800002d4:	1141                	addi	sp,sp,-16
    800002d6:	e422                	sd	s0,8(sp)
    800002d8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800002da:	ca05                	beqz	a2,8000030a <memcmp+0x36>
    800002dc:	fff6069b          	addiw	a3,a2,-1 # 1fffff <_entry-0x7fe00001>
    800002e0:	1682                	slli	a3,a3,0x20
    800002e2:	9281                	srli	a3,a3,0x20
    800002e4:	0685                	addi	a3,a3,1
    800002e6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800002e8:	00054783          	lbu	a5,0(a0)
    800002ec:	0005c703          	lbu	a4,0(a1)
    800002f0:	00e79863          	bne	a5,a4,80000300 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    800002f4:	0505                	addi	a0,a0,1
    800002f6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800002f8:	fed518e3          	bne	a0,a3,800002e8 <memcmp+0x14>
  }

  return 0;
    800002fc:	4501                	li	a0,0
    800002fe:	a019                	j	80000304 <memcmp+0x30>
      return *s1 - *s2;
    80000300:	40e7853b          	subw	a0,a5,a4
}
    80000304:	6422                	ld	s0,8(sp)
    80000306:	0141                	addi	sp,sp,16
    80000308:	8082                	ret
  return 0;
    8000030a:	4501                	li	a0,0
    8000030c:	bfe5                	j	80000304 <memcmp+0x30>

000000008000030e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    8000030e:	1141                	addi	sp,sp,-16
    80000310:	e422                	sd	s0,8(sp)
    80000312:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000314:	c205                	beqz	a2,80000334 <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000316:	02a5e263          	bltu	a1,a0,8000033a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000031a:	1602                	slli	a2,a2,0x20
    8000031c:	9201                	srli	a2,a2,0x20
    8000031e:	00c587b3          	add	a5,a1,a2
{
    80000322:	872a                	mv	a4,a0
      *d++ = *s++;
    80000324:	0585                	addi	a1,a1,1
    80000326:	0705                	addi	a4,a4,1 # 7800001 <_entry-0x787fffff>
    80000328:	fff5c683          	lbu	a3,-1(a1)
    8000032c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000330:	fef59ae3          	bne	a1,a5,80000324 <memmove+0x16>

  return dst;
}
    80000334:	6422                	ld	s0,8(sp)
    80000336:	0141                	addi	sp,sp,16
    80000338:	8082                	ret
  if(s < d && s + n > d){
    8000033a:	02061693          	slli	a3,a2,0x20
    8000033e:	9281                	srli	a3,a3,0x20
    80000340:	00d58733          	add	a4,a1,a3
    80000344:	fce57be3          	bgeu	a0,a4,8000031a <memmove+0xc>
    d += n;
    80000348:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    8000034a:	fff6079b          	addiw	a5,a2,-1
    8000034e:	1782                	slli	a5,a5,0x20
    80000350:	9381                	srli	a5,a5,0x20
    80000352:	fff7c793          	not	a5,a5
    80000356:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000358:	177d                	addi	a4,a4,-1
    8000035a:	16fd                	addi	a3,a3,-1
    8000035c:	00074603          	lbu	a2,0(a4)
    80000360:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000364:	fee79ae3          	bne	a5,a4,80000358 <memmove+0x4a>
    80000368:	b7f1                	j	80000334 <memmove+0x26>

000000008000036a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000036a:	1141                	addi	sp,sp,-16
    8000036c:	e406                	sd	ra,8(sp)
    8000036e:	e022                	sd	s0,0(sp)
    80000370:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000372:	f9dff0ef          	jal	ra,8000030e <memmove>
}
    80000376:	60a2                	ld	ra,8(sp)
    80000378:	6402                	ld	s0,0(sp)
    8000037a:	0141                	addi	sp,sp,16
    8000037c:	8082                	ret

000000008000037e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000037e:	1141                	addi	sp,sp,-16
    80000380:	e422                	sd	s0,8(sp)
    80000382:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000384:	ce11                	beqz	a2,800003a0 <strncmp+0x22>
    80000386:	00054783          	lbu	a5,0(a0)
    8000038a:	cf89                	beqz	a5,800003a4 <strncmp+0x26>
    8000038c:	0005c703          	lbu	a4,0(a1)
    80000390:	00f71a63          	bne	a4,a5,800003a4 <strncmp+0x26>
    n--, p++, q++;
    80000394:	367d                	addiw	a2,a2,-1
    80000396:	0505                	addi	a0,a0,1
    80000398:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000039a:	f675                	bnez	a2,80000386 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000039c:	4501                	li	a0,0
    8000039e:	a809                	j	800003b0 <strncmp+0x32>
    800003a0:	4501                	li	a0,0
    800003a2:	a039                	j	800003b0 <strncmp+0x32>
  if(n == 0)
    800003a4:	ca09                	beqz	a2,800003b6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    800003a6:	00054503          	lbu	a0,0(a0)
    800003aa:	0005c783          	lbu	a5,0(a1)
    800003ae:	9d1d                	subw	a0,a0,a5
}
    800003b0:	6422                	ld	s0,8(sp)
    800003b2:	0141                	addi	sp,sp,16
    800003b4:	8082                	ret
    return 0;
    800003b6:	4501                	li	a0,0
    800003b8:	bfe5                	j	800003b0 <strncmp+0x32>

00000000800003ba <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800003ba:	1141                	addi	sp,sp,-16
    800003bc:	e422                	sd	s0,8(sp)
    800003be:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800003c0:	872a                	mv	a4,a0
    800003c2:	8832                	mv	a6,a2
    800003c4:	367d                	addiw	a2,a2,-1
    800003c6:	01005963          	blez	a6,800003d8 <strncpy+0x1e>
    800003ca:	0705                	addi	a4,a4,1
    800003cc:	0005c783          	lbu	a5,0(a1)
    800003d0:	fef70fa3          	sb	a5,-1(a4)
    800003d4:	0585                	addi	a1,a1,1
    800003d6:	f7f5                	bnez	a5,800003c2 <strncpy+0x8>
    ;
  while(n-- > 0)
    800003d8:	86ba                	mv	a3,a4
    800003da:	00c05c63          	blez	a2,800003f2 <strncpy+0x38>
    *s++ = 0;
    800003de:	0685                	addi	a3,a3,1
    800003e0:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800003e4:	40d707bb          	subw	a5,a4,a3
    800003e8:	37fd                	addiw	a5,a5,-1
    800003ea:	010787bb          	addw	a5,a5,a6
    800003ee:	fef048e3          	bgtz	a5,800003de <strncpy+0x24>
  return os;
}
    800003f2:	6422                	ld	s0,8(sp)
    800003f4:	0141                	addi	sp,sp,16
    800003f6:	8082                	ret

00000000800003f8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800003f8:	1141                	addi	sp,sp,-16
    800003fa:	e422                	sd	s0,8(sp)
    800003fc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800003fe:	02c05363          	blez	a2,80000424 <safestrcpy+0x2c>
    80000402:	fff6069b          	addiw	a3,a2,-1
    80000406:	1682                	slli	a3,a3,0x20
    80000408:	9281                	srli	a3,a3,0x20
    8000040a:	96ae                	add	a3,a3,a1
    8000040c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000040e:	00d58963          	beq	a1,a3,80000420 <safestrcpy+0x28>
    80000412:	0585                	addi	a1,a1,1
    80000414:	0785                	addi	a5,a5,1
    80000416:	fff5c703          	lbu	a4,-1(a1)
    8000041a:	fee78fa3          	sb	a4,-1(a5)
    8000041e:	fb65                	bnez	a4,8000040e <safestrcpy+0x16>
    ;
  *s = 0;
    80000420:	00078023          	sb	zero,0(a5)
  return os;
}
    80000424:	6422                	ld	s0,8(sp)
    80000426:	0141                	addi	sp,sp,16
    80000428:	8082                	ret

000000008000042a <strlen>:

int
strlen(const char *s)
{
    8000042a:	1141                	addi	sp,sp,-16
    8000042c:	e422                	sd	s0,8(sp)
    8000042e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000430:	00054783          	lbu	a5,0(a0)
    80000434:	cf91                	beqz	a5,80000450 <strlen+0x26>
    80000436:	0505                	addi	a0,a0,1
    80000438:	87aa                	mv	a5,a0
    8000043a:	4685                	li	a3,1
    8000043c:	9e89                	subw	a3,a3,a0
    8000043e:	00f6853b          	addw	a0,a3,a5
    80000442:	0785                	addi	a5,a5,1
    80000444:	fff7c703          	lbu	a4,-1(a5)
    80000448:	fb7d                	bnez	a4,8000043e <strlen+0x14>
    ;
  return n;
}
    8000044a:	6422                	ld	s0,8(sp)
    8000044c:	0141                	addi	sp,sp,16
    8000044e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000450:	4501                	li	a0,0
    80000452:	bfe5                	j	8000044a <strlen+0x20>

0000000080000454 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000454:	1141                	addi	sp,sp,-16
    80000456:	e406                	sd	ra,8(sp)
    80000458:	e022                	sd	s0,0(sp)
    8000045a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000045c:	45d000ef          	jal	ra,800010b8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000460:	00007717          	auipc	a4,0x7
    80000464:	61070713          	addi	a4,a4,1552 # 80007a70 <started>
  if(cpuid() == 0){
    80000468:	c51d                	beqz	a0,80000496 <main+0x42>
    while(started == 0)
    8000046a:	431c                	lw	a5,0(a4)
    8000046c:	2781                	sext.w	a5,a5
    8000046e:	dff5                	beqz	a5,8000046a <main+0x16>
      ;
    __sync_synchronize();
    80000470:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000474:	445000ef          	jal	ra,800010b8 <cpuid>
    80000478:	85aa                	mv	a1,a0
    8000047a:	00007517          	auipc	a0,0x7
    8000047e:	c4650513          	addi	a0,a0,-954 # 800070c0 <etext+0xc0>
    80000482:	73d040ef          	jal	ra,800053be <printf>
    kvminithart();    // turn on paging
    80000486:	080000ef          	jal	ra,80000506 <kvminithart>
    trapinithart();   // install kernel trap vector
    8000048a:	748010ef          	jal	ra,80001bd2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000048e:	546040ef          	jal	ra,800049d4 <plicinithart>
  }

  scheduler();
    80000492:	084010ef          	jal	ra,80001516 <scheduler>
    consoleinit();
    80000496:	653040ef          	jal	ra,800052e8 <consoleinit>
    printfinit();
    8000049a:	212050ef          	jal	ra,800056ac <printfinit>
    printf("\n");
    8000049e:	00007517          	auipc	a0,0x7
    800004a2:	c3250513          	addi	a0,a0,-974 # 800070d0 <etext+0xd0>
    800004a6:	719040ef          	jal	ra,800053be <printf>
    printf("xv6 kernel is booting\n");
    800004aa:	00007517          	auipc	a0,0x7
    800004ae:	bfe50513          	addi	a0,a0,-1026 # 800070a8 <etext+0xa8>
    800004b2:	70d040ef          	jal	ra,800053be <printf>
    printf("\n");
    800004b6:	00007517          	auipc	a0,0x7
    800004ba:	c1a50513          	addi	a0,a0,-998 # 800070d0 <etext+0xd0>
    800004be:	701040ef          	jal	ra,800053be <printf>
    kinit();         // physical page allocator
    800004c2:	c69ff0ef          	jal	ra,8000012a <kinit>
    kvminit();       // create kernel page table
    800004c6:	350000ef          	jal	ra,80000816 <kvminit>
    kvminithart();   // turn on paging
    800004ca:	03c000ef          	jal	ra,80000506 <kvminithart>
    procinit();      // process table
    800004ce:	343000ef          	jal	ra,80001010 <procinit>
    trapinit();      // trap vectors
    800004d2:	6dc010ef          	jal	ra,80001bae <trapinit>
    trapinithart();  // install kernel trap vector
    800004d6:	6fc010ef          	jal	ra,80001bd2 <trapinithart>
    plicinit();      // set up interrupt controller
    800004da:	4e4040ef          	jal	ra,800049be <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800004de:	4f6040ef          	jal	ra,800049d4 <plicinithart>
    binit();         // buffer cache
    800004e2:	56f010ef          	jal	ra,80002250 <binit>
    iinit();         // inode table
    800004e6:	34a020ef          	jal	ra,80002830 <iinit>
    fileinit();      // file table
    800004ea:	0ec030ef          	jal	ra,800035d6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800004ee:	5d6040ef          	jal	ra,80004ac4 <virtio_disk_init>
    userinit();      // first user process
    800004f2:	65b000ef          	jal	ra,8000134c <userinit>
    __sync_synchronize();
    800004f6:	0ff0000f          	fence
    started = 1;
    800004fa:	4785                	li	a5,1
    800004fc:	00007717          	auipc	a4,0x7
    80000500:	56f72a23          	sw	a5,1396(a4) # 80007a70 <started>
    80000504:	b779                	j	80000492 <main+0x3e>

0000000080000506 <kvminithart>:
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void kvminithart()
{
    80000506:	1141                	addi	sp,sp,-16
    80000508:	e422                	sd	s0,8(sp)
    8000050a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000050c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000510:	00007797          	auipc	a5,0x7
    80000514:	5687b783          	ld	a5,1384(a5) # 80007a78 <kernel_pagetable>
    80000518:	83b1                	srli	a5,a5,0xc
    8000051a:	577d                	li	a4,-1
    8000051c:	177e                	slli	a4,a4,0x3f
    8000051e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000520:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000524:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000528:	6422                	ld	s0,8(sp)
    8000052a:	0141                	addi	sp,sp,16
    8000052c:	8082                	ret

000000008000052e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000052e:	7139                	addi	sp,sp,-64
    80000530:	fc06                	sd	ra,56(sp)
    80000532:	f822                	sd	s0,48(sp)
    80000534:	f426                	sd	s1,40(sp)
    80000536:	f04a                	sd	s2,32(sp)
    80000538:	ec4e                	sd	s3,24(sp)
    8000053a:	e852                	sd	s4,16(sp)
    8000053c:	e456                	sd	s5,8(sp)
    8000053e:	e05a                	sd	s6,0(sp)
    80000540:	0080                	addi	s0,sp,64
    80000542:	892a                	mv	s2,a0
    80000544:	89ae                	mv	s3,a1
    80000546:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80000548:	57fd                	li	a5,-1
    8000054a:	83e9                	srli	a5,a5,0x1a
    8000054c:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--)
    8000054e:	4b31                	li	s6,12
  if (va >= MAXVA)
    80000550:	02b7fb63          	bgeu	a5,a1,80000586 <walk+0x58>
    panic("walk");
    80000554:	00007517          	auipc	a0,0x7
    80000558:	b8450513          	addi	a0,a0,-1148 # 800070d8 <etext+0xd8>
    8000055c:	116050ef          	jal	ra,80005672 <panic>
      }
#endif
    }
    else
    {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000560:	060a8563          	beqz	s5,800005ca <walk+0x9c>
    80000564:	c01ff0ef          	jal	ra,80000164 <kalloc>
    80000568:	892a                	mv	s2,a0
    8000056a:	c135                	beqz	a0,800005ce <walk+0xa0>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000056c:	6605                	lui	a2,0x1
    8000056e:	4581                	li	a1,0
    80000570:	d43ff0ef          	jal	ra,800002b2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000574:	00c95793          	srli	a5,s2,0xc
    80000578:	07aa                	slli	a5,a5,0xa
    8000057a:	0017e793          	ori	a5,a5,1
    8000057e:	e09c                	sd	a5,0(s1)
  for (int level = 2; level > 0; level--)
    80000580:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde027>
    80000582:	036a0263          	beq	s4,s6,800005a6 <walk+0x78>
    pte_t *pte = &pagetable[PX(level, va)];
    80000586:	0149d4b3          	srl	s1,s3,s4
    8000058a:	1ff4f493          	andi	s1,s1,511
    8000058e:	048e                	slli	s1,s1,0x3
    80000590:	94ca                	add	s1,s1,s2
    if (*pte & PTE_V)
    80000592:	609c                	ld	a5,0(s1)
    80000594:	0017f713          	andi	a4,a5,1
    80000598:	d761                	beqz	a4,80000560 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000059a:	00a7d913          	srli	s2,a5,0xa
    8000059e:	0932                	slli	s2,s2,0xc
      if (PTE_LEAF(*pte))
    800005a0:	8bb9                	andi	a5,a5,14
    800005a2:	dff9                	beqz	a5,80000580 <walk+0x52>
    800005a4:	a801                	j	800005b4 <walk+0x86>
    }
  }
  return &pagetable[PX(0, va)];
    800005a6:	00c9d993          	srli	s3,s3,0xc
    800005aa:	1ff9f993          	andi	s3,s3,511
    800005ae:	098e                	slli	s3,s3,0x3
    800005b0:	013904b3          	add	s1,s2,s3
}
    800005b4:	8526                	mv	a0,s1
    800005b6:	70e2                	ld	ra,56(sp)
    800005b8:	7442                	ld	s0,48(sp)
    800005ba:	74a2                	ld	s1,40(sp)
    800005bc:	7902                	ld	s2,32(sp)
    800005be:	69e2                	ld	s3,24(sp)
    800005c0:	6a42                	ld	s4,16(sp)
    800005c2:	6aa2                	ld	s5,8(sp)
    800005c4:	6b02                	ld	s6,0(sp)
    800005c6:	6121                	addi	sp,sp,64
    800005c8:	8082                	ret
        return 0;
    800005ca:	4481                	li	s1,0
    800005cc:	b7e5                	j	800005b4 <walk+0x86>
    800005ce:	84aa                	mv	s1,a0
    800005d0:	b7d5                	j	800005b4 <walk+0x86>

00000000800005d2 <superwalk>:

//derivative of walk that only decends one level in the page table
//key spec for superpages
pte_t *
superwalk(pagetable_t pagetable, uint64 va, int alloc)
{
    800005d2:	7179                	addi	sp,sp,-48
    800005d4:	f406                	sd	ra,40(sp)
    800005d6:	f022                	sd	s0,32(sp)
    800005d8:	ec26                	sd	s1,24(sp)
    800005da:	e84a                	sd	s2,16(sp)
    800005dc:	e44e                	sd	s3,8(sp)
    800005de:	1800                	addi	s0,sp,48
  if(va >= MAXVA) {
    800005e0:	57fd                	li	a5,-1
    800005e2:	83e9                	srli	a5,a5,0x1a
    800005e4:	02b7ed63          	bltu	a5,a1,8000061e <superwalk+0x4c>
    800005e8:	84ae                	mv	s1,a1
    panic("superwalk");
  }

  pte_t *pte = &pagetable[PX(2, va)]; //only descend one level
    800005ea:	01e5d793          	srli	a5,a1,0x1e
    800005ee:	078e                	slli	a5,a5,0x3
    800005f0:	00f509b3          	add	s3,a0,a5
  if(*pte & PTE_V) {
    800005f4:	0009b903          	ld	s2,0(s3) # 1000 <_entry-0x7ffff000>
    800005f8:	00197793          	andi	a5,s2,1
    800005fc:	c79d                	beqz	a5,8000062a <superwalk+0x58>
    pagetable = (pagetable_t)PTE2PA(*pte);
    800005fe:	00a95913          	srli	s2,s2,0xa
    80000602:	0932                	slli	s2,s2,0xc
      return 0;
  }
    memset(pagetable, 0, PGSIZE);
    *pte = PA2PTE(pagetable) | PTE_V;
  }
  return &pagetable[PX(1, va)];
    80000604:	80d5                	srli	s1,s1,0x15
    80000606:	1ff4f493          	andi	s1,s1,511
    8000060a:	048e                	slli	s1,s1,0x3
    8000060c:	9926                	add	s2,s2,s1
}
    8000060e:	854a                	mv	a0,s2
    80000610:	70a2                	ld	ra,40(sp)
    80000612:	7402                	ld	s0,32(sp)
    80000614:	64e2                	ld	s1,24(sp)
    80000616:	6942                	ld	s2,16(sp)
    80000618:	69a2                	ld	s3,8(sp)
    8000061a:	6145                	addi	sp,sp,48
    8000061c:	8082                	ret
    panic("superwalk");
    8000061e:	00007517          	auipc	a0,0x7
    80000622:	ac250513          	addi	a0,a0,-1342 # 800070e0 <etext+0xe0>
    80000626:	04c050ef          	jal	ra,80005672 <panic>
      return 0;
    8000062a:	4901                	li	s2,0
    if (!alloc || (pagetable = (pde_t *)kalloc()) == 0) {
    8000062c:	d26d                	beqz	a2,8000060e <superwalk+0x3c>
    8000062e:	b37ff0ef          	jal	ra,80000164 <kalloc>
    80000632:	892a                	mv	s2,a0
    80000634:	dd69                	beqz	a0,8000060e <superwalk+0x3c>
    memset(pagetable, 0, PGSIZE);
    80000636:	6605                	lui	a2,0x1
    80000638:	4581                	li	a1,0
    8000063a:	c79ff0ef          	jal	ra,800002b2 <memset>
    *pte = PA2PTE(pagetable) | PTE_V;
    8000063e:	00c95793          	srli	a5,s2,0xc
    80000642:	07aa                	slli	a5,a5,0xa
    80000644:	0017e793          	ori	a5,a5,1
    80000648:	00f9b023          	sd	a5,0(s3)
    8000064c:	bf65                	j	80000604 <superwalk+0x32>

000000008000064e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    8000064e:	57fd                	li	a5,-1
    80000650:	83e9                	srli	a5,a5,0x1a
    80000652:	00b7f463          	bgeu	a5,a1,8000065a <walkaddr+0xc>
    return 0;
    80000656:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000658:	8082                	ret
{
    8000065a:	1141                	addi	sp,sp,-16
    8000065c:	e406                	sd	ra,8(sp)
    8000065e:	e022                	sd	s0,0(sp)
    80000660:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000662:	4601                	li	a2,0
    80000664:	ecbff0ef          	jal	ra,8000052e <walk>
  if (pte == 0)
    80000668:	c105                	beqz	a0,80000688 <walkaddr+0x3a>
  if ((*pte & PTE_V) == 0)
    8000066a:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    8000066c:	0117f693          	andi	a3,a5,17
    80000670:	4745                	li	a4,17
    return 0;
    80000672:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80000674:	00e68663          	beq	a3,a4,80000680 <walkaddr+0x32>
}
    80000678:	60a2                	ld	ra,8(sp)
    8000067a:	6402                	ld	s0,0(sp)
    8000067c:	0141                	addi	sp,sp,16
    8000067e:	8082                	ret
  pa = PTE2PA(*pte);
    80000680:	83a9                	srli	a5,a5,0xa
    80000682:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000686:	bfcd                	j	80000678 <walkaddr+0x2a>
    return 0;
    80000688:	4501                	li	a0,0
    8000068a:	b7fd                	j	80000678 <walkaddr+0x2a>

000000008000068c <mappages>:
// physical addresses starting at pa.
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000068c:	715d                	addi	sp,sp,-80
    8000068e:	e486                	sd	ra,72(sp)
    80000690:	e0a2                	sd	s0,64(sp)
    80000692:	fc26                	sd	s1,56(sp)
    80000694:	f84a                	sd	s2,48(sp)
    80000696:	f44e                	sd	s3,40(sp)
    80000698:	f052                	sd	s4,32(sp)
    8000069a:	ec56                	sd	s5,24(sp)
    8000069c:	e85a                	sd	s6,16(sp)
    8000069e:	e45e                	sd	s7,8(sp)
    800006a0:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    800006a2:	03459793          	slli	a5,a1,0x34
    800006a6:	e7a9                	bnez	a5,800006f0 <mappages+0x64>
    800006a8:	8aaa                	mv	s5,a0
    800006aa:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    800006ac:	03461793          	slli	a5,a2,0x34
    800006b0:	e7b1                	bnez	a5,800006fc <mappages+0x70>
    panic("mappages: size not aligned");

  if (size == 0)
    800006b2:	ca39                	beqz	a2,80000708 <mappages+0x7c>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    800006b4:	77fd                	lui	a5,0xfffff
    800006b6:	963e                	add	a2,a2,a5
    800006b8:	00b609b3          	add	s3,a2,a1
  a = va;
    800006bc:	892e                	mv	s2,a1
    800006be:	40b68a33          	sub	s4,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    800006c2:	6b85                	lui	s7,0x1
    800006c4:	012a04b3          	add	s1,s4,s2
    if ((pte = walk(pagetable, a, 1)) == 0)
    800006c8:	4605                	li	a2,1
    800006ca:	85ca                	mv	a1,s2
    800006cc:	8556                	mv	a0,s5
    800006ce:	e61ff0ef          	jal	ra,8000052e <walk>
    800006d2:	c539                	beqz	a0,80000720 <mappages+0x94>
    if (*pte & PTE_V)
    800006d4:	611c                	ld	a5,0(a0)
    800006d6:	8b85                	andi	a5,a5,1
    800006d8:	ef95                	bnez	a5,80000714 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800006da:	80b1                	srli	s1,s1,0xc
    800006dc:	04aa                	slli	s1,s1,0xa
    800006de:	0164e4b3          	or	s1,s1,s6
    800006e2:	0014e493          	ori	s1,s1,1
    800006e6:	e104                	sd	s1,0(a0)
    if (a == last)
    800006e8:	05390863          	beq	s2,s3,80000738 <mappages+0xac>
    a += PGSIZE;
    800006ec:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    800006ee:	bfd9                	j	800006c4 <mappages+0x38>
    panic("mappages: va not aligned");
    800006f0:	00007517          	auipc	a0,0x7
    800006f4:	a0050513          	addi	a0,a0,-1536 # 800070f0 <etext+0xf0>
    800006f8:	77b040ef          	jal	ra,80005672 <panic>
    panic("mappages: size not aligned");
    800006fc:	00007517          	auipc	a0,0x7
    80000700:	a1450513          	addi	a0,a0,-1516 # 80007110 <etext+0x110>
    80000704:	76f040ef          	jal	ra,80005672 <panic>
    panic("mappages: size");
    80000708:	00007517          	auipc	a0,0x7
    8000070c:	a2850513          	addi	a0,a0,-1496 # 80007130 <etext+0x130>
    80000710:	763040ef          	jal	ra,80005672 <panic>
      panic("mappages: remap");
    80000714:	00007517          	auipc	a0,0x7
    80000718:	a2c50513          	addi	a0,a0,-1492 # 80007140 <etext+0x140>
    8000071c:	757040ef          	jal	ra,80005672 <panic>
      return -1;
    80000720:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80000722:	60a6                	ld	ra,72(sp)
    80000724:	6406                	ld	s0,64(sp)
    80000726:	74e2                	ld	s1,56(sp)
    80000728:	7942                	ld	s2,48(sp)
    8000072a:	79a2                	ld	s3,40(sp)
    8000072c:	7a02                	ld	s4,32(sp)
    8000072e:	6ae2                	ld	s5,24(sp)
    80000730:	6b42                	ld	s6,16(sp)
    80000732:	6ba2                	ld	s7,8(sp)
    80000734:	6161                	addi	sp,sp,80
    80000736:	8082                	ret
  return 0;
    80000738:	4501                	li	a0,0
    8000073a:	b7e5                	j	80000722 <mappages+0x96>

000000008000073c <kvmmap>:
{
    8000073c:	1141                	addi	sp,sp,-16
    8000073e:	e406                	sd	ra,8(sp)
    80000740:	e022                	sd	s0,0(sp)
    80000742:	0800                	addi	s0,sp,16
    80000744:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000746:	86b2                	mv	a3,a2
    80000748:	863e                	mv	a2,a5
    8000074a:	f43ff0ef          	jal	ra,8000068c <mappages>
    8000074e:	e509                	bnez	a0,80000758 <kvmmap+0x1c>
}
    80000750:	60a2                	ld	ra,8(sp)
    80000752:	6402                	ld	s0,0(sp)
    80000754:	0141                	addi	sp,sp,16
    80000756:	8082                	ret
    panic("kvmmap");
    80000758:	00007517          	auipc	a0,0x7
    8000075c:	9f850513          	addi	a0,a0,-1544 # 80007150 <etext+0x150>
    80000760:	713040ef          	jal	ra,80005672 <panic>

0000000080000764 <kvmmake>:
{
    80000764:	1101                	addi	sp,sp,-32
    80000766:	ec06                	sd	ra,24(sp)
    80000768:	e822                	sd	s0,16(sp)
    8000076a:	e426                	sd	s1,8(sp)
    8000076c:	e04a                	sd	s2,0(sp)
    8000076e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    80000770:	9f5ff0ef          	jal	ra,80000164 <kalloc>
    80000774:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000776:	6605                	lui	a2,0x1
    80000778:	4581                	li	a1,0
    8000077a:	b39ff0ef          	jal	ra,800002b2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000077e:	4719                	li	a4,6
    80000780:	6685                	lui	a3,0x1
    80000782:	10000637          	lui	a2,0x10000
    80000786:	100005b7          	lui	a1,0x10000
    8000078a:	8526                	mv	a0,s1
    8000078c:	fb1ff0ef          	jal	ra,8000073c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000790:	4719                	li	a4,6
    80000792:	6685                	lui	a3,0x1
    80000794:	10001637          	lui	a2,0x10001
    80000798:	100015b7          	lui	a1,0x10001
    8000079c:	8526                	mv	a0,s1
    8000079e:	f9fff0ef          	jal	ra,8000073c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800007a2:	4719                	li	a4,6
    800007a4:	040006b7          	lui	a3,0x4000
    800007a8:	0c000637          	lui	a2,0xc000
    800007ac:	0c0005b7          	lui	a1,0xc000
    800007b0:	8526                	mv	a0,s1
    800007b2:	f8bff0ef          	jal	ra,8000073c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800007b6:	00007917          	auipc	s2,0x7
    800007ba:	84a90913          	addi	s2,s2,-1974 # 80007000 <etext>
    800007be:	4729                	li	a4,10
    800007c0:	80007697          	auipc	a3,0x80007
    800007c4:	84068693          	addi	a3,a3,-1984 # 7000 <_entry-0x7fff9000>
    800007c8:	4605                	li	a2,1
    800007ca:	067e                	slli	a2,a2,0x1f
    800007cc:	85b2                	mv	a1,a2
    800007ce:	8526                	mv	a0,s1
    800007d0:	f6dff0ef          	jal	ra,8000073c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    800007d4:	4719                	li	a4,6
    800007d6:	46c5                	li	a3,17
    800007d8:	06ee                	slli	a3,a3,0x1b
    800007da:	412686b3          	sub	a3,a3,s2
    800007de:	864a                	mv	a2,s2
    800007e0:	85ca                	mv	a1,s2
    800007e2:	8526                	mv	a0,s1
    800007e4:	f59ff0ef          	jal	ra,8000073c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800007e8:	4729                	li	a4,10
    800007ea:	6685                	lui	a3,0x1
    800007ec:	00006617          	auipc	a2,0x6
    800007f0:	81460613          	addi	a2,a2,-2028 # 80006000 <_trampoline>
    800007f4:	040005b7          	lui	a1,0x4000
    800007f8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800007fa:	05b2                	slli	a1,a1,0xc
    800007fc:	8526                	mv	a0,s1
    800007fe:	f3fff0ef          	jal	ra,8000073c <kvmmap>
  proc_mapstacks(kpgtbl);
    80000802:	8526                	mv	a0,s1
    80000804:	782000ef          	jal	ra,80000f86 <proc_mapstacks>
}
    80000808:	8526                	mv	a0,s1
    8000080a:	60e2                	ld	ra,24(sp)
    8000080c:	6442                	ld	s0,16(sp)
    8000080e:	64a2                	ld	s1,8(sp)
    80000810:	6902                	ld	s2,0(sp)
    80000812:	6105                	addi	sp,sp,32
    80000814:	8082                	ret

0000000080000816 <kvminit>:
{
    80000816:	1141                	addi	sp,sp,-16
    80000818:	e406                	sd	ra,8(sp)
    8000081a:	e022                	sd	s0,0(sp)
    8000081c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000081e:	f47ff0ef          	jal	ra,80000764 <kvmmake>
    80000822:	00007797          	auipc	a5,0x7
    80000826:	24a7bb23          	sd	a0,598(a5) # 80007a78 <kernel_pagetable>
}
    8000082a:	60a2                	ld	ra,8(sp)
    8000082c:	6402                	ld	s0,0(sp)
    8000082e:	0141                	addi	sp,sp,16
    80000830:	8082                	ret

0000000080000832 <supermappages>:

int
supermappages(pagetable_t pagetable, uint64 va, uint64 pa, int perm) {
    80000832:	1101                	addi	sp,sp,-32
    80000834:	ec06                	sd	ra,24(sp)
    80000836:	e822                	sd	s0,16(sp)
    80000838:	e426                	sd	s1,8(sp)
    8000083a:	e04a                	sd	s2,0(sp)
    8000083c:	1000                	addi	s0,sp,32
  pte_t *pte;
  if ((va % SUPERPGSIZE) != 0) {
    8000083e:	02b59793          	slli	a5,a1,0x2b
    80000842:	eb8d                	bnez	a5,80000874 <supermappages+0x42>
    80000844:	84b2                	mv	s1,a2
    80000846:	8936                	mv	s2,a3
    panic("supermappages: va not aligned");
  }
  if ((pte = superwalk(pagetable, va, 1)) == 0) { //superwalk failed
    80000848:	4605                	li	a2,1
    8000084a:	d89ff0ef          	jal	ra,800005d2 <superwalk>
    8000084e:	cd1d                	beqz	a0,8000088c <supermappages+0x5a>
    return -1;
  }
  if (*pte & PTE_V) {
    80000850:	611c                	ld	a5,0(a0)
    80000852:	8b85                	andi	a5,a5,1
    80000854:	e795                	bnez	a5,80000880 <supermappages+0x4e>
    panic("supermappages: remap");
  }
  *pte = PA2PTE(pa) | perm | PTE_V;
    80000856:	00c4d613          	srli	a2,s1,0xc
    8000085a:	062a                	slli	a2,a2,0xa
    8000085c:	01266633          	or	a2,a2,s2
    80000860:	00166613          	ori	a2,a2,1
    80000864:	e110                	sd	a2,0(a0)
  return 0;
    80000866:	4501                	li	a0,0
}
    80000868:	60e2                	ld	ra,24(sp)
    8000086a:	6442                	ld	s0,16(sp)
    8000086c:	64a2                	ld	s1,8(sp)
    8000086e:	6902                	ld	s2,0(sp)
    80000870:	6105                	addi	sp,sp,32
    80000872:	8082                	ret
    panic("supermappages: va not aligned");
    80000874:	00007517          	auipc	a0,0x7
    80000878:	8e450513          	addi	a0,a0,-1820 # 80007158 <etext+0x158>
    8000087c:	5f7040ef          	jal	ra,80005672 <panic>
    panic("supermappages: remap");
    80000880:	00007517          	auipc	a0,0x7
    80000884:	8f850513          	addi	a0,a0,-1800 # 80007178 <etext+0x178>
    80000888:	5eb040ef          	jal	ra,80005672 <panic>
    return -1;
    8000088c:	557d                	li	a0,-1
    8000088e:	bfe9                	j	80000868 <supermappages+0x36>

0000000080000890 <uvmunmap>:

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000890:	715d                	addi	sp,sp,-80
    80000892:	e486                	sd	ra,72(sp)
    80000894:	e0a2                	sd	s0,64(sp)
    80000896:	fc26                	sd	s1,56(sp)
    80000898:	f84a                	sd	s2,48(sp)
    8000089a:	f44e                	sd	s3,40(sp)
    8000089c:	f052                	sd	s4,32(sp)
    8000089e:	ec56                	sd	s5,24(sp)
    800008a0:	e85a                	sd	s6,16(sp)
    800008a2:	e45e                	sd	s7,8(sp)
    800008a4:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;
  int sz;

  if ((va % PGSIZE) != 0)
    800008a6:	03459793          	slli	a5,a1,0x34
    800008aa:	e795                	bnez	a5,800008d6 <uvmunmap+0x46>
    800008ac:	8a2a                	mv	s4,a0
    800008ae:	892e                	mv	s2,a1
    800008b0:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += sz)
    800008b2:	0632                	slli	a2,a2,0xc
    800008b4:	00b609b3          	add	s3,a2,a1
    if ((*pte & PTE_V) == 0)
    {
      printf("va=%ld pte=%ld\n", a, *pte);
      panic("uvmunmap: not mapped");
    }
    if (PTE_FLAGS(*pte) == PTE_V)
    800008b8:	4b85                	li	s7,1
  for (a = va; a < va + npages * PGSIZE; a += sz)
    800008ba:	6b05                	lui	s6,0x1
    800008bc:	0735e163          	bltu	a1,s3,8000091e <uvmunmap+0x8e>
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
  }
}
    800008c0:	60a6                	ld	ra,72(sp)
    800008c2:	6406                	ld	s0,64(sp)
    800008c4:	74e2                	ld	s1,56(sp)
    800008c6:	7942                	ld	s2,48(sp)
    800008c8:	79a2                	ld	s3,40(sp)
    800008ca:	7a02                	ld	s4,32(sp)
    800008cc:	6ae2                	ld	s5,24(sp)
    800008ce:	6b42                	ld	s6,16(sp)
    800008d0:	6ba2                	ld	s7,8(sp)
    800008d2:	6161                	addi	sp,sp,80
    800008d4:	8082                	ret
    panic("uvmunmap: not aligned");
    800008d6:	00007517          	auipc	a0,0x7
    800008da:	8ba50513          	addi	a0,a0,-1862 # 80007190 <etext+0x190>
    800008de:	595040ef          	jal	ra,80005672 <panic>
      panic("uvmunmap: walk");
    800008e2:	00007517          	auipc	a0,0x7
    800008e6:	8c650513          	addi	a0,a0,-1850 # 800071a8 <etext+0x1a8>
    800008ea:	589040ef          	jal	ra,80005672 <panic>
      printf("va=%ld pte=%ld\n", a, *pte);
    800008ee:	85ca                	mv	a1,s2
    800008f0:	00007517          	auipc	a0,0x7
    800008f4:	8c850513          	addi	a0,a0,-1848 # 800071b8 <etext+0x1b8>
    800008f8:	2c7040ef          	jal	ra,800053be <printf>
      panic("uvmunmap: not mapped");
    800008fc:	00007517          	auipc	a0,0x7
    80000900:	8cc50513          	addi	a0,a0,-1844 # 800071c8 <etext+0x1c8>
    80000904:	56f040ef          	jal	ra,80005672 <panic>
      panic("uvmunmap: not a leaf");
    80000908:	00007517          	auipc	a0,0x7
    8000090c:	8d850513          	addi	a0,a0,-1832 # 800071e0 <etext+0x1e0>
    80000910:	563040ef          	jal	ra,80005672 <panic>
    *pte = 0;
    80000914:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += sz)
    80000918:	995a                	add	s2,s2,s6
    8000091a:	fb3973e3          	bgeu	s2,s3,800008c0 <uvmunmap+0x30>
    if ((pte = walk(pagetable, a, 0)) == 0)
    8000091e:	4601                	li	a2,0
    80000920:	85ca                	mv	a1,s2
    80000922:	8552                	mv	a0,s4
    80000924:	c0bff0ef          	jal	ra,8000052e <walk>
    80000928:	84aa                	mv	s1,a0
    8000092a:	dd45                	beqz	a0,800008e2 <uvmunmap+0x52>
    if ((*pte & PTE_V) == 0)
    8000092c:	6110                	ld	a2,0(a0)
    8000092e:	00167793          	andi	a5,a2,1
    80000932:	dfd5                	beqz	a5,800008ee <uvmunmap+0x5e>
    if (PTE_FLAGS(*pte) == PTE_V)
    80000934:	3ff67793          	andi	a5,a2,1023
    80000938:	fd7788e3          	beq	a5,s7,80000908 <uvmunmap+0x78>
    if (do_free)
    8000093c:	fc0a8ce3          	beqz	s5,80000914 <uvmunmap+0x84>
      uint64 pa = PTE2PA(*pte);
    80000940:	8229                	srli	a2,a2,0xa
      kfree((void *)pa);
    80000942:	00c61513          	slli	a0,a2,0xc
    80000946:	f2aff0ef          	jal	ra,80000070 <kfree>
    8000094a:	b7e9                	j	80000914 <uvmunmap+0x84>

000000008000094c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000094c:	1101                	addi	sp,sp,-32
    8000094e:	ec06                	sd	ra,24(sp)
    80000950:	e822                	sd	s0,16(sp)
    80000952:	e426                	sd	s1,8(sp)
    80000954:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80000956:	80fff0ef          	jal	ra,80000164 <kalloc>
    8000095a:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000095c:	c509                	beqz	a0,80000966 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000095e:	6605                	lui	a2,0x1
    80000960:	4581                	li	a1,0
    80000962:	951ff0ef          	jal	ra,800002b2 <memset>
  return pagetable;
}
    80000966:	8526                	mv	a0,s1
    80000968:	60e2                	ld	ra,24(sp)
    8000096a:	6442                	ld	s0,16(sp)
    8000096c:	64a2                	ld	s1,8(sp)
    8000096e:	6105                	addi	sp,sp,32
    80000970:	8082                	ret

0000000080000972 <uvmfirst>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80000972:	7179                	addi	sp,sp,-48
    80000974:	f406                	sd	ra,40(sp)
    80000976:	f022                	sd	s0,32(sp)
    80000978:	ec26                	sd	s1,24(sp)
    8000097a:	e84a                	sd	s2,16(sp)
    8000097c:	e44e                	sd	s3,8(sp)
    8000097e:	e052                	sd	s4,0(sp)
    80000980:	1800                	addi	s0,sp,48
  char *mem;

  if (sz >= PGSIZE)
    80000982:	6785                	lui	a5,0x1
    80000984:	04f67063          	bgeu	a2,a5,800009c4 <uvmfirst+0x52>
    80000988:	8a2a                	mv	s4,a0
    8000098a:	89ae                	mv	s3,a1
    8000098c:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000098e:	fd6ff0ef          	jal	ra,80000164 <kalloc>
    80000992:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000994:	6605                	lui	a2,0x1
    80000996:	4581                	li	a1,0
    80000998:	91bff0ef          	jal	ra,800002b2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    8000099c:	4779                	li	a4,30
    8000099e:	86ca                	mv	a3,s2
    800009a0:	6605                	lui	a2,0x1
    800009a2:	4581                	li	a1,0
    800009a4:	8552                	mv	a0,s4
    800009a6:	ce7ff0ef          	jal	ra,8000068c <mappages>
  memmove(mem, src, sz);
    800009aa:	8626                	mv	a2,s1
    800009ac:	85ce                	mv	a1,s3
    800009ae:	854a                	mv	a0,s2
    800009b0:	95fff0ef          	jal	ra,8000030e <memmove>
}
    800009b4:	70a2                	ld	ra,40(sp)
    800009b6:	7402                	ld	s0,32(sp)
    800009b8:	64e2                	ld	s1,24(sp)
    800009ba:	6942                	ld	s2,16(sp)
    800009bc:	69a2                	ld	s3,8(sp)
    800009be:	6a02                	ld	s4,0(sp)
    800009c0:	6145                	addi	sp,sp,48
    800009c2:	8082                	ret
    panic("uvmfirst: more than a page");
    800009c4:	00007517          	auipc	a0,0x7
    800009c8:	83450513          	addi	a0,a0,-1996 # 800071f8 <etext+0x1f8>
    800009cc:	4a7040ef          	jal	ra,80005672 <panic>

00000000800009d0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800009d0:	1101                	addi	sp,sp,-32
    800009d2:	ec06                	sd	ra,24(sp)
    800009d4:	e822                	sd	s0,16(sp)
    800009d6:	e426                	sd	s1,8(sp)
    800009d8:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    800009da:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800009dc:	00b67d63          	bgeu	a2,a1,800009f6 <uvmdealloc+0x26>
    800009e0:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    800009e2:	6785                	lui	a5,0x1
    800009e4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800009e6:	00f60733          	add	a4,a2,a5
    800009ea:	76fd                	lui	a3,0xfffff
    800009ec:	8f75                	and	a4,a4,a3
    800009ee:	97ae                	add	a5,a5,a1
    800009f0:	8ff5                	and	a5,a5,a3
    800009f2:	00f76863          	bltu	a4,a5,80000a02 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800009f6:	8526                	mv	a0,s1
    800009f8:	60e2                	ld	ra,24(sp)
    800009fa:	6442                	ld	s0,16(sp)
    800009fc:	64a2                	ld	s1,8(sp)
    800009fe:	6105                	addi	sp,sp,32
    80000a00:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80000a02:	8f99                	sub	a5,a5,a4
    80000a04:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80000a06:	4685                	li	a3,1
    80000a08:	0007861b          	sext.w	a2,a5
    80000a0c:	85ba                	mv	a1,a4
    80000a0e:	e83ff0ef          	jal	ra,80000890 <uvmunmap>
    80000a12:	b7d5                	j	800009f6 <uvmdealloc+0x26>

0000000080000a14 <uvmalloc>:
{
    80000a14:	711d                	addi	sp,sp,-96
    80000a16:	ec86                	sd	ra,88(sp)
    80000a18:	e8a2                	sd	s0,80(sp)
    80000a1a:	e4a6                	sd	s1,72(sp)
    80000a1c:	e0ca                	sd	s2,64(sp)
    80000a1e:	fc4e                	sd	s3,56(sp)
    80000a20:	f852                	sd	s4,48(sp)
    80000a22:	f456                	sd	s5,40(sp)
    80000a24:	f05a                	sd	s6,32(sp)
    80000a26:	ec5e                	sd	s7,24(sp)
    80000a28:	e862                	sd	s8,16(sp)
    80000a2a:	e466                	sd	s9,8(sp)
    80000a2c:	e06a                	sd	s10,0(sp)
    80000a2e:	1080                	addi	s0,sp,96
    return oldsz;
    80000a30:	892e                	mv	s2,a1
  if (newsz < oldsz)
    80000a32:	0cb66363          	bltu	a2,a1,80000af8 <uvmalloc+0xe4>
    80000a36:	8a2a                	mv	s4,a0
    80000a38:	89b2                	mv	s3,a2
  oldsz = PGROUNDUP(oldsz);
    80000a3a:	6785                	lui	a5,0x1
    80000a3c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000a3e:	95be                	add	a1,a1,a5
    80000a40:	7cfd                	lui	s9,0xfffff
    80000a42:	0195fcb3          	and	s9,a1,s9
  for (a = oldsz; a < newsz; a += sz)
    80000a46:	0cccf863          	bgeu	s9,a2,80000b16 <uvmalloc+0x102>
    80000a4a:	84e6                	mv	s1,s9
    if (a % SUPERPGSIZE == 0 && newsz - a >= SUPERPGSIZE) { //superpage
    80000a4c:	00200ab7          	lui	s5,0x200
    80000a50:	fffa8b13          	addi	s6,s5,-1 # 1fffff <_entry-0x7fe00001>
      if (mappages(pagetable, a, sz, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80000a54:	0126eb93          	ori	s7,a3,18
      if (supermappages(pagetable, a, (uint64)mem, PTE_R | PTE_W | PTE_U | xperm) != 0) {
    80000a58:	0166ec13          	ori	s8,a3,22
    80000a5c:	a0a1                	j	80000aa4 <uvmalloc+0x90>
        uvmdealloc(pagetable, a, oldsz);
    80000a5e:	8666                	mv	a2,s9
    80000a60:	85a6                	mv	a1,s1
    80000a62:	8552                	mv	a0,s4
    80000a64:	f6dff0ef          	jal	ra,800009d0 <uvmdealloc>
        return 0;
    80000a68:	a841                	j	80000af8 <uvmalloc+0xe4>
        superfree(mem);
    80000a6a:	856a                	mv	a0,s10
    80000a6c:	fb2ff0ef          	jal	ra,8000021e <superfree>
        uvmdealloc(pagetable, a, oldsz);
    80000a70:	8666                	mv	a2,s9
    80000a72:	85a6                	mv	a1,s1
    80000a74:	8552                	mv	a0,s4
    80000a76:	f5bff0ef          	jal	ra,800009d0 <uvmdealloc>
        return 0;
    80000a7a:	a8bd                	j	80000af8 <uvmalloc+0xe4>
      mem = kalloc();
    80000a7c:	ee8ff0ef          	jal	ra,80000164 <kalloc>
    80000a80:	892a                	mv	s2,a0
      if (mem == 0)
    80000a82:	c931                	beqz	a0,80000ad6 <uvmalloc+0xc2>
      memset(mem, 0, sz);
    80000a84:	6605                	lui	a2,0x1
    80000a86:	4581                	li	a1,0
    80000a88:	82bff0ef          	jal	ra,800002b2 <memset>
      if (mappages(pagetable, a, sz, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80000a8c:	875e                	mv	a4,s7
    80000a8e:	86ca                	mv	a3,s2
    80000a90:	6605                	lui	a2,0x1
    80000a92:	85a6                	mv	a1,s1
    80000a94:	8552                	mv	a0,s4
    80000a96:	bf7ff0ef          	jal	ra,8000068c <mappages>
    80000a9a:	e521                	bnez	a0,80000ae2 <uvmalloc+0xce>
      sz = PGSIZE;
    80000a9c:	6785                	lui	a5,0x1
  for (a = oldsz; a < newsz; a += sz)
    80000a9e:	94be                	add	s1,s1,a5
    80000aa0:	0534fb63          	bgeu	s1,s3,80000af6 <uvmalloc+0xe2>
    if (a % SUPERPGSIZE == 0 && newsz - a >= SUPERPGSIZE) { //superpage
    80000aa4:	0164f933          	and	s2,s1,s6
    80000aa8:	fc091ae3          	bnez	s2,80000a7c <uvmalloc+0x68>
    80000aac:	409987b3          	sub	a5,s3,s1
    80000ab0:	fd57e6e3          	bltu	a5,s5,80000a7c <uvmalloc+0x68>
      mem = superalloc();
    80000ab4:	f0aff0ef          	jal	ra,800001be <superalloc>
    80000ab8:	8d2a                	mv	s10,a0
      if (mem == 0) {
    80000aba:	d155                	beqz	a0,80000a5e <uvmalloc+0x4a>
      memset(mem, 0, sz);
    80000abc:	8656                	mv	a2,s5
    80000abe:	4581                	li	a1,0
    80000ac0:	ff2ff0ef          	jal	ra,800002b2 <memset>
      if (supermappages(pagetable, a, (uint64)mem, PTE_R | PTE_W | PTE_U | xperm) != 0) {
    80000ac4:	86e2                	mv	a3,s8
    80000ac6:	866a                	mv	a2,s10
    80000ac8:	85a6                	mv	a1,s1
    80000aca:	8552                	mv	a0,s4
    80000acc:	d67ff0ef          	jal	ra,80000832 <supermappages>
    80000ad0:	fd49                	bnez	a0,80000a6a <uvmalloc+0x56>
      sz = SUPERPGSIZE;
    80000ad2:	87d6                	mv	a5,s5
    80000ad4:	b7e9                	j	80000a9e <uvmalloc+0x8a>
        uvmdealloc(pagetable, a, oldsz);
    80000ad6:	8666                	mv	a2,s9
    80000ad8:	85a6                	mv	a1,s1
    80000ada:	8552                	mv	a0,s4
    80000adc:	ef5ff0ef          	jal	ra,800009d0 <uvmdealloc>
        return 0;
    80000ae0:	a821                	j	80000af8 <uvmalloc+0xe4>
        kfree(mem);
    80000ae2:	854a                	mv	a0,s2
    80000ae4:	d8cff0ef          	jal	ra,80000070 <kfree>
        uvmdealloc(pagetable, a, oldsz);
    80000ae8:	8666                	mv	a2,s9
    80000aea:	85a6                	mv	a1,s1
    80000aec:	8552                	mv	a0,s4
    80000aee:	ee3ff0ef          	jal	ra,800009d0 <uvmdealloc>
        return 0;
    80000af2:	4901                	li	s2,0
    80000af4:	a011                	j	80000af8 <uvmalloc+0xe4>
  return newsz;
    80000af6:	894e                	mv	s2,s3
}
    80000af8:	854a                	mv	a0,s2
    80000afa:	60e6                	ld	ra,88(sp)
    80000afc:	6446                	ld	s0,80(sp)
    80000afe:	64a6                	ld	s1,72(sp)
    80000b00:	6906                	ld	s2,64(sp)
    80000b02:	79e2                	ld	s3,56(sp)
    80000b04:	7a42                	ld	s4,48(sp)
    80000b06:	7aa2                	ld	s5,40(sp)
    80000b08:	7b02                	ld	s6,32(sp)
    80000b0a:	6be2                	ld	s7,24(sp)
    80000b0c:	6c42                	ld	s8,16(sp)
    80000b0e:	6ca2                	ld	s9,8(sp)
    80000b10:	6d02                	ld	s10,0(sp)
    80000b12:	6125                	addi	sp,sp,96
    80000b14:	8082                	ret
  return newsz;
    80000b16:	8932                	mv	s2,a2
    80000b18:	b7c5                	j	80000af8 <uvmalloc+0xe4>

0000000080000b1a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    80000b1a:	7179                	addi	sp,sp,-48
    80000b1c:	f406                	sd	ra,40(sp)
    80000b1e:	f022                	sd	s0,32(sp)
    80000b20:	ec26                	sd	s1,24(sp)
    80000b22:	e84a                	sd	s2,16(sp)
    80000b24:	e44e                	sd	s3,8(sp)
    80000b26:	e052                	sd	s4,0(sp)
    80000b28:	1800                	addi	s0,sp,48
    80000b2a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++)
    80000b2c:	84aa                	mv	s1,a0
    80000b2e:	6905                	lui	s2,0x1
    80000b30:	992a                	add	s2,s2,a0
  {
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000b32:	4985                	li	s3,1
    80000b34:	a819                	j	80000b4a <freewalk+0x30>
    {
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000b36:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80000b38:	00c79513          	slli	a0,a5,0xc
    80000b3c:	fdfff0ef          	jal	ra,80000b1a <freewalk>
      pagetable[i] = 0;
    80000b40:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++)
    80000b44:	04a1                	addi	s1,s1,8
    80000b46:	01248f63          	beq	s1,s2,80000b64 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80000b4a:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000b4c:	00f7f713          	andi	a4,a5,15
    80000b50:	ff3703e3          	beq	a4,s3,80000b36 <freewalk+0x1c>
    }
    else if (pte & PTE_V)
    80000b54:	8b85                	andi	a5,a5,1
    80000b56:	d7fd                	beqz	a5,80000b44 <freewalk+0x2a>
    {
      panic("freewalk: leaf");
    80000b58:	00006517          	auipc	a0,0x6
    80000b5c:	6c050513          	addi	a0,a0,1728 # 80007218 <etext+0x218>
    80000b60:	313040ef          	jal	ra,80005672 <panic>
    }
  }
  kfree((void *)pagetable);
    80000b64:	8552                	mv	a0,s4
    80000b66:	d0aff0ef          	jal	ra,80000070 <kfree>
}
    80000b6a:	70a2                	ld	ra,40(sp)
    80000b6c:	7402                	ld	s0,32(sp)
    80000b6e:	64e2                	ld	s1,24(sp)
    80000b70:	6942                	ld	s2,16(sp)
    80000b72:	69a2                	ld	s3,8(sp)
    80000b74:	6a02                	ld	s4,0(sp)
    80000b76:	6145                	addi	sp,sp,48
    80000b78:	8082                	ret

0000000080000b7a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000b7a:	1101                	addi	sp,sp,-32
    80000b7c:	ec06                	sd	ra,24(sp)
    80000b7e:	e822                	sd	s0,16(sp)
    80000b80:	e426                	sd	s1,8(sp)
    80000b82:	1000                	addi	s0,sp,32
    80000b84:	84aa                	mv	s1,a0
  if (sz > 0)
    80000b86:	e989                	bnez	a1,80000b98 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80000b88:	8526                	mv	a0,s1
    80000b8a:	f91ff0ef          	jal	ra,80000b1a <freewalk>
}
    80000b8e:	60e2                	ld	ra,24(sp)
    80000b90:	6442                	ld	s0,16(sp)
    80000b92:	64a2                	ld	s1,8(sp)
    80000b94:	6105                	addi	sp,sp,32
    80000b96:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80000b98:	6785                	lui	a5,0x1
    80000b9a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000b9c:	95be                	add	a1,a1,a5
    80000b9e:	4685                	li	a3,1
    80000ba0:	00c5d613          	srli	a2,a1,0xc
    80000ba4:	4581                	li	a1,0
    80000ba6:	cebff0ef          	jal	ra,80000890 <uvmunmap>
    80000baa:	bff9                	j	80000b88 <uvmfree+0xe>

0000000080000bac <uvmcopy>:
  uint64 pa, i;
  uint flags;
  char *mem;
  int szinc;

  for (i = 0; i < sz; i += szinc)
    80000bac:	c65d                	beqz	a2,80000c5a <uvmcopy+0xae>
{
    80000bae:	715d                	addi	sp,sp,-80
    80000bb0:	e486                	sd	ra,72(sp)
    80000bb2:	e0a2                	sd	s0,64(sp)
    80000bb4:	fc26                	sd	s1,56(sp)
    80000bb6:	f84a                	sd	s2,48(sp)
    80000bb8:	f44e                	sd	s3,40(sp)
    80000bba:	f052                	sd	s4,32(sp)
    80000bbc:	ec56                	sd	s5,24(sp)
    80000bbe:	e85a                	sd	s6,16(sp)
    80000bc0:	e45e                	sd	s7,8(sp)
    80000bc2:	0880                	addi	s0,sp,80
    80000bc4:	8b2a                	mv	s6,a0
    80000bc6:	8aae                	mv	s5,a1
    80000bc8:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += szinc)
    80000bca:	4981                	li	s3,0
  {
    szinc = PGSIZE;
    if ((pte = walk(old, i, 0)) == 0)
    80000bcc:	4601                	li	a2,0
    80000bce:	85ce                	mv	a1,s3
    80000bd0:	855a                	mv	a0,s6
    80000bd2:	95dff0ef          	jal	ra,8000052e <walk>
    80000bd6:	c121                	beqz	a0,80000c16 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if ((*pte & PTE_V) == 0)
    80000bd8:	6118                	ld	a4,0(a0)
    80000bda:	00177793          	andi	a5,a4,1
    80000bde:	c3b1                	beqz	a5,80000c22 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000be0:	00a75593          	srli	a1,a4,0xa
    80000be4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80000be8:	3ff77493          	andi	s1,a4,1023
    if ((mem = kalloc()) == 0)
    80000bec:	d78ff0ef          	jal	ra,80000164 <kalloc>
    80000bf0:	892a                	mv	s2,a0
    80000bf2:	c129                	beqz	a0,80000c34 <uvmcopy+0x88>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    80000bf4:	6605                	lui	a2,0x1
    80000bf6:	85de                	mv	a1,s7
    80000bf8:	f16ff0ef          	jal	ra,8000030e <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80000bfc:	8726                	mv	a4,s1
    80000bfe:	86ca                	mv	a3,s2
    80000c00:	6605                	lui	a2,0x1
    80000c02:	85ce                	mv	a1,s3
    80000c04:	8556                	mv	a0,s5
    80000c06:	a87ff0ef          	jal	ra,8000068c <mappages>
    80000c0a:	e115                	bnez	a0,80000c2e <uvmcopy+0x82>
  for (i = 0; i < sz; i += szinc)
    80000c0c:	6785                	lui	a5,0x1
    80000c0e:	99be                	add	s3,s3,a5
    80000c10:	fb49eee3          	bltu	s3,s4,80000bcc <uvmcopy+0x20>
    80000c14:	a805                	j	80000c44 <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    80000c16:	00006517          	auipc	a0,0x6
    80000c1a:	61250513          	addi	a0,a0,1554 # 80007228 <etext+0x228>
    80000c1e:	255040ef          	jal	ra,80005672 <panic>
      panic("uvmcopy: page not present");
    80000c22:	00006517          	auipc	a0,0x6
    80000c26:	62650513          	addi	a0,a0,1574 # 80007248 <etext+0x248>
    80000c2a:	249040ef          	jal	ra,80005672 <panic>
    {
      kfree(mem);
    80000c2e:	854a                	mv	a0,s2
    80000c30:	c40ff0ef          	jal	ra,80000070 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000c34:	4685                	li	a3,1
    80000c36:	00c9d613          	srli	a2,s3,0xc
    80000c3a:	4581                	li	a1,0
    80000c3c:	8556                	mv	a0,s5
    80000c3e:	c53ff0ef          	jal	ra,80000890 <uvmunmap>
  return -1;
    80000c42:	557d                	li	a0,-1
}
    80000c44:	60a6                	ld	ra,72(sp)
    80000c46:	6406                	ld	s0,64(sp)
    80000c48:	74e2                	ld	s1,56(sp)
    80000c4a:	7942                	ld	s2,48(sp)
    80000c4c:	79a2                	ld	s3,40(sp)
    80000c4e:	7a02                	ld	s4,32(sp)
    80000c50:	6ae2                	ld	s5,24(sp)
    80000c52:	6b42                	ld	s6,16(sp)
    80000c54:	6ba2                	ld	s7,8(sp)
    80000c56:	6161                	addi	sp,sp,80
    80000c58:	8082                	ret
  return 0;
    80000c5a:	4501                	li	a0,0
}
    80000c5c:	8082                	ret

0000000080000c5e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    80000c5e:	1141                	addi	sp,sp,-16
    80000c60:	e406                	sd	ra,8(sp)
    80000c62:	e022                	sd	s0,0(sp)
    80000c64:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80000c66:	4601                	li	a2,0
    80000c68:	8c7ff0ef          	jal	ra,8000052e <walk>
  if (pte == 0)
    80000c6c:	c901                	beqz	a0,80000c7c <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000c6e:	611c                	ld	a5,0(a0)
    80000c70:	9bbd                	andi	a5,a5,-17
    80000c72:	e11c                	sd	a5,0(a0)
}
    80000c74:	60a2                	ld	ra,8(sp)
    80000c76:	6402                	ld	s0,0(sp)
    80000c78:	0141                	addi	sp,sp,16
    80000c7a:	8082                	ret
    panic("uvmclear");
    80000c7c:	00006517          	auipc	a0,0x6
    80000c80:	5ec50513          	addi	a0,a0,1516 # 80007268 <etext+0x268>
    80000c84:	1ef040ef          	jal	ra,80005672 <panic>

0000000080000c88 <copyout>:
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while (len > 0)
    80000c88:	c6c1                	beqz	a3,80000d10 <copyout+0x88>
{
    80000c8a:	711d                	addi	sp,sp,-96
    80000c8c:	ec86                	sd	ra,88(sp)
    80000c8e:	e8a2                	sd	s0,80(sp)
    80000c90:	e4a6                	sd	s1,72(sp)
    80000c92:	e0ca                	sd	s2,64(sp)
    80000c94:	fc4e                	sd	s3,56(sp)
    80000c96:	f852                	sd	s4,48(sp)
    80000c98:	f456                	sd	s5,40(sp)
    80000c9a:	f05a                	sd	s6,32(sp)
    80000c9c:	ec5e                	sd	s7,24(sp)
    80000c9e:	e862                	sd	s8,16(sp)
    80000ca0:	e466                	sd	s9,8(sp)
    80000ca2:	1080                	addi	s0,sp,96
    80000ca4:	8b2a                	mv	s6,a0
    80000ca6:	8a2e                	mv	s4,a1
    80000ca8:	8ab2                	mv	s5,a2
    80000caa:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(dstva);
    80000cac:	74fd                	lui	s1,0xfffff
    80000cae:	8ced                	and	s1,s1,a1
    if (va0 >= MAXVA)
    80000cb0:	57fd                	li	a5,-1
    80000cb2:	83e9                	srli	a5,a5,0x1a
    80000cb4:	0697e063          	bltu	a5,s1,80000d14 <copyout+0x8c>
    80000cb8:	6c05                	lui	s8,0x1
    80000cba:	8bbe                	mv	s7,a5
    80000cbc:	a015                	j	80000ce0 <copyout+0x58>
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000cbe:	409a04b3          	sub	s1,s4,s1
    80000cc2:	0009061b          	sext.w	a2,s2
    80000cc6:	85d6                	mv	a1,s5
    80000cc8:	9526                	add	a0,a0,s1
    80000cca:	e44ff0ef          	jal	ra,8000030e <memmove>

    len -= n;
    80000cce:	412989b3          	sub	s3,s3,s2
    src += n;
    80000cd2:	9aca                	add	s5,s5,s2
  while (len > 0)
    80000cd4:	02098c63          	beqz	s3,80000d0c <copyout+0x84>
    if (va0 >= MAXVA)
    80000cd8:	059be063          	bltu	s7,s9,80000d18 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    80000cdc:	84e6                	mv	s1,s9
    dstva = va0 + PGSIZE;
    80000cde:	8a66                	mv	s4,s9
    if ((pte = walk(pagetable, va0, 0)) == 0)
    80000ce0:	4601                	li	a2,0
    80000ce2:	85a6                	mv	a1,s1
    80000ce4:	855a                	mv	a0,s6
    80000ce6:	849ff0ef          	jal	ra,8000052e <walk>
    80000cea:	c90d                	beqz	a0,80000d1c <copyout+0x94>
    if ((*pte & PTE_W) == 0)
    80000cec:	611c                	ld	a5,0(a0)
    80000cee:	8b91                	andi	a5,a5,4
    80000cf0:	c7a1                	beqz	a5,80000d38 <copyout+0xb0>
    pa0 = walkaddr(pagetable, va0);
    80000cf2:	85a6                	mv	a1,s1
    80000cf4:	855a                	mv	a0,s6
    80000cf6:	959ff0ef          	jal	ra,8000064e <walkaddr>
    if (pa0 == 0)
    80000cfa:	c129                	beqz	a0,80000d3c <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    80000cfc:	01848cb3          	add	s9,s1,s8
    80000d00:	414c8933          	sub	s2,s9,s4
    80000d04:	fb29fde3          	bgeu	s3,s2,80000cbe <copyout+0x36>
    80000d08:	894e                	mv	s2,s3
    80000d0a:	bf55                	j	80000cbe <copyout+0x36>
  }
  return 0;
    80000d0c:	4501                	li	a0,0
    80000d0e:	a801                	j	80000d1e <copyout+0x96>
    80000d10:	4501                	li	a0,0
}
    80000d12:	8082                	ret
      return -1;
    80000d14:	557d                	li	a0,-1
    80000d16:	a021                	j	80000d1e <copyout+0x96>
    80000d18:	557d                	li	a0,-1
    80000d1a:	a011                	j	80000d1e <copyout+0x96>
      return -1;
    80000d1c:	557d                	li	a0,-1
}
    80000d1e:	60e6                	ld	ra,88(sp)
    80000d20:	6446                	ld	s0,80(sp)
    80000d22:	64a6                	ld	s1,72(sp)
    80000d24:	6906                	ld	s2,64(sp)
    80000d26:	79e2                	ld	s3,56(sp)
    80000d28:	7a42                	ld	s4,48(sp)
    80000d2a:	7aa2                	ld	s5,40(sp)
    80000d2c:	7b02                	ld	s6,32(sp)
    80000d2e:	6be2                	ld	s7,24(sp)
    80000d30:	6c42                	ld	s8,16(sp)
    80000d32:	6ca2                	ld	s9,8(sp)
    80000d34:	6125                	addi	sp,sp,96
    80000d36:	8082                	ret
      return -1;
    80000d38:	557d                	li	a0,-1
    80000d3a:	b7d5                	j	80000d1e <copyout+0x96>
      return -1;
    80000d3c:	557d                	li	a0,-1
    80000d3e:	b7c5                	j	80000d1e <copyout+0x96>

0000000080000d40 <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    80000d40:	c6a5                	beqz	a3,80000da8 <copyin+0x68>
{
    80000d42:	715d                	addi	sp,sp,-80
    80000d44:	e486                	sd	ra,72(sp)
    80000d46:	e0a2                	sd	s0,64(sp)
    80000d48:	fc26                	sd	s1,56(sp)
    80000d4a:	f84a                	sd	s2,48(sp)
    80000d4c:	f44e                	sd	s3,40(sp)
    80000d4e:	f052                	sd	s4,32(sp)
    80000d50:	ec56                	sd	s5,24(sp)
    80000d52:	e85a                	sd	s6,16(sp)
    80000d54:	e45e                	sd	s7,8(sp)
    80000d56:	e062                	sd	s8,0(sp)
    80000d58:	0880                	addi	s0,sp,80
    80000d5a:	8b2a                	mv	s6,a0
    80000d5c:	8a2e                	mv	s4,a1
    80000d5e:	8c32                	mv	s8,a2
    80000d60:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80000d62:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000d64:	6a85                	lui	s5,0x1
    80000d66:	a00d                	j	80000d88 <copyin+0x48>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000d68:	018505b3          	add	a1,a0,s8
    80000d6c:	0004861b          	sext.w	a2,s1
    80000d70:	412585b3          	sub	a1,a1,s2
    80000d74:	8552                	mv	a0,s4
    80000d76:	d98ff0ef          	jal	ra,8000030e <memmove>

    len -= n;
    80000d7a:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000d7e:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000d80:	01590c33          	add	s8,s2,s5
  while (len > 0)
    80000d84:	02098063          	beqz	s3,80000da4 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80000d88:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000d8c:	85ca                	mv	a1,s2
    80000d8e:	855a                	mv	a0,s6
    80000d90:	8bfff0ef          	jal	ra,8000064e <walkaddr>
    if (pa0 == 0)
    80000d94:	cd01                	beqz	a0,80000dac <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80000d96:	418904b3          	sub	s1,s2,s8
    80000d9a:	94d6                	add	s1,s1,s5
    80000d9c:	fc99f6e3          	bgeu	s3,s1,80000d68 <copyin+0x28>
    80000da0:	84ce                	mv	s1,s3
    80000da2:	b7d9                	j	80000d68 <copyin+0x28>
  }
  return 0;
    80000da4:	4501                	li	a0,0
    80000da6:	a021                	j	80000dae <copyin+0x6e>
    80000da8:	4501                	li	a0,0
}
    80000daa:	8082                	ret
      return -1;
    80000dac:	557d                	li	a0,-1
}
    80000dae:	60a6                	ld	ra,72(sp)
    80000db0:	6406                	ld	s0,64(sp)
    80000db2:	74e2                	ld	s1,56(sp)
    80000db4:	7942                	ld	s2,48(sp)
    80000db6:	79a2                	ld	s3,40(sp)
    80000db8:	7a02                	ld	s4,32(sp)
    80000dba:	6ae2                	ld	s5,24(sp)
    80000dbc:	6b42                	ld	s6,16(sp)
    80000dbe:	6ba2                	ld	s7,8(sp)
    80000dc0:	6c02                	ld	s8,0(sp)
    80000dc2:	6161                	addi	sp,sp,80
    80000dc4:	8082                	ret

0000000080000dc6 <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    80000dc6:	c2cd                	beqz	a3,80000e68 <copyinstr+0xa2>
{
    80000dc8:	715d                	addi	sp,sp,-80
    80000dca:	e486                	sd	ra,72(sp)
    80000dcc:	e0a2                	sd	s0,64(sp)
    80000dce:	fc26                	sd	s1,56(sp)
    80000dd0:	f84a                	sd	s2,48(sp)
    80000dd2:	f44e                	sd	s3,40(sp)
    80000dd4:	f052                	sd	s4,32(sp)
    80000dd6:	ec56                	sd	s5,24(sp)
    80000dd8:	e85a                	sd	s6,16(sp)
    80000dda:	e45e                	sd	s7,8(sp)
    80000ddc:	0880                	addi	s0,sp,80
    80000dde:	8a2a                	mv	s4,a0
    80000de0:	8b2e                	mv	s6,a1
    80000de2:	8bb2                	mv	s7,a2
    80000de4:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80000de6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000de8:	6985                	lui	s3,0x1
    80000dea:	a02d                	j	80000e14 <copyinstr+0x4e>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    80000dec:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000df0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    80000df2:	37fd                	addiw	a5,a5,-1
    80000df4:	0007851b          	sext.w	a0,a5
  }
  else
  {
    return -1;
  }
}
    80000df8:	60a6                	ld	ra,72(sp)
    80000dfa:	6406                	ld	s0,64(sp)
    80000dfc:	74e2                	ld	s1,56(sp)
    80000dfe:	7942                	ld	s2,48(sp)
    80000e00:	79a2                	ld	s3,40(sp)
    80000e02:	7a02                	ld	s4,32(sp)
    80000e04:	6ae2                	ld	s5,24(sp)
    80000e06:	6b42                	ld	s6,16(sp)
    80000e08:	6ba2                	ld	s7,8(sp)
    80000e0a:	6161                	addi	sp,sp,80
    80000e0c:	8082                	ret
    srcva = va0 + PGSIZE;
    80000e0e:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    80000e12:	c4b9                	beqz	s1,80000e60 <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    80000e14:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000e18:	85ca                	mv	a1,s2
    80000e1a:	8552                	mv	a0,s4
    80000e1c:	833ff0ef          	jal	ra,8000064e <walkaddr>
    if (pa0 == 0)
    80000e20:	c131                	beqz	a0,80000e64 <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    80000e22:	417906b3          	sub	a3,s2,s7
    80000e26:	96ce                	add	a3,a3,s3
    80000e28:	00d4f363          	bgeu	s1,a3,80000e2e <copyinstr+0x68>
    80000e2c:	86a6                	mv	a3,s1
    char *p = (char *)(pa0 + (srcva - va0));
    80000e2e:	955e                	add	a0,a0,s7
    80000e30:	41250533          	sub	a0,a0,s2
    while (n > 0)
    80000e34:	dee9                	beqz	a3,80000e0e <copyinstr+0x48>
    80000e36:	87da                	mv	a5,s6
      if (*p == '\0')
    80000e38:	41650633          	sub	a2,a0,s6
    80000e3c:	fff48593          	addi	a1,s1,-1 # ffffffffffffefff <end+0xffffffff7ffde02f>
    80000e40:	95da                	add	a1,a1,s6
    while (n > 0)
    80000e42:	96da                	add	a3,a3,s6
      if (*p == '\0')
    80000e44:	00f60733          	add	a4,a2,a5
    80000e48:	00074703          	lbu	a4,0(a4)
    80000e4c:	d345                	beqz	a4,80000dec <copyinstr+0x26>
        *dst = *p;
    80000e4e:	00e78023          	sb	a4,0(a5)
      --max;
    80000e52:	40f584b3          	sub	s1,a1,a5
      dst++;
    80000e56:	0785                	addi	a5,a5,1
    while (n > 0)
    80000e58:	fed796e3          	bne	a5,a3,80000e44 <copyinstr+0x7e>
      dst++;
    80000e5c:	8b3e                	mv	s6,a5
    80000e5e:	bf45                	j	80000e0e <copyinstr+0x48>
    80000e60:	4781                	li	a5,0
    80000e62:	bf41                	j	80000df2 <copyinstr+0x2c>
      return -1;
    80000e64:	557d                	li	a0,-1
    80000e66:	bf49                	j	80000df8 <copyinstr+0x32>
  int got_null = 0;
    80000e68:	4781                	li	a5,0
  if (got_null)
    80000e6a:	37fd                	addiw	a5,a5,-1
    80000e6c:	0007851b          	sext.w	a0,a5
}
    80000e70:	8082                	ret

0000000080000e72 <vmprint_recurse>:
  vmprint_recurse(pagetable, 0, 0); // start the recursion with depth 0
}
#endif

void vmprint_recurse(pagetable_t pagetable, int depth, uint64 va_recursive)
{ // seperate function so we can keep track of depth using a parameter
    80000e72:	7119                	addi	sp,sp,-128
    80000e74:	fc86                	sd	ra,120(sp)
    80000e76:	f8a2                	sd	s0,112(sp)
    80000e78:	f4a6                	sd	s1,104(sp)
    80000e7a:	f0ca                	sd	s2,96(sp)
    80000e7c:	ecce                	sd	s3,88(sp)
    80000e7e:	e8d2                	sd	s4,80(sp)
    80000e80:	e4d6                	sd	s5,72(sp)
    80000e82:	e0da                	sd	s6,64(sp)
    80000e84:	fc5e                	sd	s7,56(sp)
    80000e86:	f862                	sd	s8,48(sp)
    80000e88:	f466                	sd	s9,40(sp)
    80000e8a:	f06a                	sd	s10,32(sp)
    80000e8c:	ec6e                	sd	s11,24(sp)
    80000e8e:	0100                	addi	s0,sp,128
    80000e90:	8aae                	mv	s5,a1
    80000e92:	8d32                	mv	s10,a2
    { // skip the pte if it's not valid per lab spec
      continue;
    }

    // reconstruct va using i, px shift, and the previous va
    uint64 va = va_recursive | ((uint64)i << PXSHIFT(2 - depth));
    80000e94:	4789                	li	a5,2
    80000e96:	9f8d                	subw	a5,a5,a1
    80000e98:	00379c9b          	slliw	s9,a5,0x3
    80000e9c:	00fc8cbb          	addw	s9,s9,a5
    80000ea0:	2cb1                	addiw	s9,s9,12 # fffffffffffff00c <end+0xffffffff7ffde03c>
    80000ea2:	8a2a                	mv	s4,a0
    80000ea4:	4981                	li	s3,0
      printf(".. ");
    }
    printf("..%p: pte %p pa %p\n", (void *)va, (void *)pte, (void *)PTE2PA(pte));

    // recursive block
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000ea6:	4d85                	li	s11,1
    {
      uint64 child_pa = PTE2PA(pte); // get child pa to convert to a pagetable
      vmprint_recurse((pagetable_t)child_pa, depth + 1, va);
    80000ea8:	0015879b          	addiw	a5,a1,1
    80000eac:	f8f43423          	sd	a5,-120(s0)
      printf(".. ");
    80000eb0:	00006b17          	auipc	s6,0x6
    80000eb4:	3d0b0b13          	addi	s6,s6,976 # 80007280 <etext+0x280>
  for (int i = 0; i < 512; i++)
    80000eb8:	20000c13          	li	s8,512
    80000ebc:	a029                	j	80000ec6 <vmprint_recurse+0x54>
    80000ebe:	0985                	addi	s3,s3,1 # 1001 <_entry-0x7fffefff>
    80000ec0:	0a21                	addi	s4,s4,8
    80000ec2:	07898163          	beq	s3,s8,80000f24 <vmprint_recurse+0xb2>
    pte_t pte = pagetable[i]; // store pte from page table
    80000ec6:	000a3903          	ld	s2,0(s4)
    if (!(pte & PTE_V))
    80000eca:	00197793          	andi	a5,s2,1
    80000ece:	dbe5                	beqz	a5,80000ebe <vmprint_recurse+0x4c>
    uint64 va = va_recursive | ((uint64)i << PXSHIFT(2 - depth));
    80000ed0:	01999bb3          	sll	s7,s3,s9
    80000ed4:	01abebb3          	or	s7,s7,s10
    printf(" ");
    80000ed8:	00006517          	auipc	a0,0x6
    80000edc:	3a050513          	addi	a0,a0,928 # 80007278 <etext+0x278>
    80000ee0:	4de040ef          	jal	ra,800053be <printf>
    for (int j = 0; j < depth; j++)
    80000ee4:	01505963          	blez	s5,80000ef6 <vmprint_recurse+0x84>
    80000ee8:	4481                	li	s1,0
      printf(".. ");
    80000eea:	855a                	mv	a0,s6
    80000eec:	4d2040ef          	jal	ra,800053be <printf>
    for (int j = 0; j < depth; j++)
    80000ef0:	2485                	addiw	s1,s1,1
    80000ef2:	fe9a9ce3          	bne	s5,s1,80000eea <vmprint_recurse+0x78>
    printf("..%p: pte %p pa %p\n", (void *)va, (void *)pte, (void *)PTE2PA(pte));
    80000ef6:	00a95493          	srli	s1,s2,0xa
    80000efa:	04b2                	slli	s1,s1,0xc
    80000efc:	86a6                	mv	a3,s1
    80000efe:	864a                	mv	a2,s2
    80000f00:	85de                	mv	a1,s7
    80000f02:	00006517          	auipc	a0,0x6
    80000f06:	38650513          	addi	a0,a0,902 # 80007288 <etext+0x288>
    80000f0a:	4b4040ef          	jal	ra,800053be <printf>
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000f0e:	00f97913          	andi	s2,s2,15
    80000f12:	fbb916e3          	bne	s2,s11,80000ebe <vmprint_recurse+0x4c>
      vmprint_recurse((pagetable_t)child_pa, depth + 1, va);
    80000f16:	865e                	mv	a2,s7
    80000f18:	f8843583          	ld	a1,-120(s0)
    80000f1c:	8526                	mv	a0,s1
    80000f1e:	f55ff0ef          	jal	ra,80000e72 <vmprint_recurse>
    80000f22:	bf71                	j	80000ebe <vmprint_recurse+0x4c>
    }
  }
}
    80000f24:	70e6                	ld	ra,120(sp)
    80000f26:	7446                	ld	s0,112(sp)
    80000f28:	74a6                	ld	s1,104(sp)
    80000f2a:	7906                	ld	s2,96(sp)
    80000f2c:	69e6                	ld	s3,88(sp)
    80000f2e:	6a46                	ld	s4,80(sp)
    80000f30:	6aa6                	ld	s5,72(sp)
    80000f32:	6b06                	ld	s6,64(sp)
    80000f34:	7be2                	ld	s7,56(sp)
    80000f36:	7c42                	ld	s8,48(sp)
    80000f38:	7ca2                	ld	s9,40(sp)
    80000f3a:	7d02                	ld	s10,32(sp)
    80000f3c:	6de2                	ld	s11,24(sp)
    80000f3e:	6109                	addi	sp,sp,128
    80000f40:	8082                	ret

0000000080000f42 <vmprint>:
{
    80000f42:	1101                	addi	sp,sp,-32
    80000f44:	ec06                	sd	ra,24(sp)
    80000f46:	e822                	sd	s0,16(sp)
    80000f48:	e426                	sd	s1,8(sp)
    80000f4a:	1000                	addi	s0,sp,32
    80000f4c:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    80000f4e:	85aa                	mv	a1,a0
    80000f50:	00006517          	auipc	a0,0x6
    80000f54:	35050513          	addi	a0,a0,848 # 800072a0 <etext+0x2a0>
    80000f58:	466040ef          	jal	ra,800053be <printf>
  vmprint_recurse(pagetable, 0, 0); // start the recursion with depth 0
    80000f5c:	4601                	li	a2,0
    80000f5e:	4581                	li	a1,0
    80000f60:	8526                	mv	a0,s1
    80000f62:	f11ff0ef          	jal	ra,80000e72 <vmprint_recurse>
}
    80000f66:	60e2                	ld	ra,24(sp)
    80000f68:	6442                	ld	s0,16(sp)
    80000f6a:	64a2                	ld	s1,8(sp)
    80000f6c:	6105                	addi	sp,sp,32
    80000f6e:	8082                	ret

0000000080000f70 <pgpte>:

#ifdef LAB_PGTBL
pte_t *
pgpte(pagetable_t pagetable, uint64 va)
{
    80000f70:	1141                	addi	sp,sp,-16
    80000f72:	e406                	sd	ra,8(sp)
    80000f74:	e022                	sd	s0,0(sp)
    80000f76:	0800                	addi	s0,sp,16
  return walk(pagetable, va, 0);
    80000f78:	4601                	li	a2,0
    80000f7a:	db4ff0ef          	jal	ra,8000052e <walk>
}
    80000f7e:	60a2                	ld	ra,8(sp)
    80000f80:	6402                	ld	s0,0(sp)
    80000f82:	0141                	addi	sp,sp,16
    80000f84:	8082                	ret

0000000080000f86 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000f86:	7139                	addi	sp,sp,-64
    80000f88:	fc06                	sd	ra,56(sp)
    80000f8a:	f822                	sd	s0,48(sp)
    80000f8c:	f426                	sd	s1,40(sp)
    80000f8e:	f04a                	sd	s2,32(sp)
    80000f90:	ec4e                	sd	s3,24(sp)
    80000f92:	e852                	sd	s4,16(sp)
    80000f94:	e456                	sd	s5,8(sp)
    80000f96:	e05a                	sd	s6,0(sp)
    80000f98:	0080                	addi	s0,sp,64
    80000f9a:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80000f9c:	00007497          	auipc	s1,0x7
    80000fa0:	15448493          	addi	s1,s1,340 # 800080f0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000fa4:	8b26                	mv	s6,s1
    80000fa6:	00006a97          	auipc	s5,0x6
    80000faa:	05aa8a93          	addi	s5,s5,90 # 80007000 <etext>
    80000fae:	04000937          	lui	s2,0x4000
    80000fb2:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000fb4:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fb6:	0000da17          	auipc	s4,0xd
    80000fba:	b3aa0a13          	addi	s4,s4,-1222 # 8000daf0 <tickslock>
    char *pa = kalloc();
    80000fbe:	9a6ff0ef          	jal	ra,80000164 <kalloc>
    80000fc2:	862a                	mv	a2,a0
    if(pa == 0)
    80000fc4:	c121                	beqz	a0,80001004 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80000fc6:	416485b3          	sub	a1,s1,s6
    80000fca:	858d                	srai	a1,a1,0x3
    80000fcc:	000ab783          	ld	a5,0(s5)
    80000fd0:	02f585b3          	mul	a1,a1,a5
    80000fd4:	2585                	addiw	a1,a1,1
    80000fd6:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000fda:	4719                	li	a4,6
    80000fdc:	6685                	lui	a3,0x1
    80000fde:	40b905b3          	sub	a1,s2,a1
    80000fe2:	854e                	mv	a0,s3
    80000fe4:	f58ff0ef          	jal	ra,8000073c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fe8:	16848493          	addi	s1,s1,360
    80000fec:	fd4499e3          	bne	s1,s4,80000fbe <proc_mapstacks+0x38>
  }
}
    80000ff0:	70e2                	ld	ra,56(sp)
    80000ff2:	7442                	ld	s0,48(sp)
    80000ff4:	74a2                	ld	s1,40(sp)
    80000ff6:	7902                	ld	s2,32(sp)
    80000ff8:	69e2                	ld	s3,24(sp)
    80000ffa:	6a42                	ld	s4,16(sp)
    80000ffc:	6aa2                	ld	s5,8(sp)
    80000ffe:	6b02                	ld	s6,0(sp)
    80001000:	6121                	addi	sp,sp,64
    80001002:	8082                	ret
      panic("kalloc");
    80001004:	00006517          	auipc	a0,0x6
    80001008:	2ac50513          	addi	a0,a0,684 # 800072b0 <etext+0x2b0>
    8000100c:	666040ef          	jal	ra,80005672 <panic>

0000000080001010 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001010:	7139                	addi	sp,sp,-64
    80001012:	fc06                	sd	ra,56(sp)
    80001014:	f822                	sd	s0,48(sp)
    80001016:	f426                	sd	s1,40(sp)
    80001018:	f04a                	sd	s2,32(sp)
    8000101a:	ec4e                	sd	s3,24(sp)
    8000101c:	e852                	sd	s4,16(sp)
    8000101e:	e456                	sd	s5,8(sp)
    80001020:	e05a                	sd	s6,0(sp)
    80001022:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001024:	00006597          	auipc	a1,0x6
    80001028:	29458593          	addi	a1,a1,660 # 800072b8 <etext+0x2b8>
    8000102c:	00007517          	auipc	a0,0x7
    80001030:	c9450513          	addi	a0,a0,-876 # 80007cc0 <pid_lock>
    80001034:	0cf040ef          	jal	ra,80005902 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001038:	00006597          	auipc	a1,0x6
    8000103c:	28858593          	addi	a1,a1,648 # 800072c0 <etext+0x2c0>
    80001040:	00007517          	auipc	a0,0x7
    80001044:	c9850513          	addi	a0,a0,-872 # 80007cd8 <wait_lock>
    80001048:	0bb040ef          	jal	ra,80005902 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000104c:	00007497          	auipc	s1,0x7
    80001050:	0a448493          	addi	s1,s1,164 # 800080f0 <proc>
      initlock(&p->lock, "proc");
    80001054:	00006b17          	auipc	s6,0x6
    80001058:	27cb0b13          	addi	s6,s6,636 # 800072d0 <etext+0x2d0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000105c:	8aa6                	mv	s5,s1
    8000105e:	00006a17          	auipc	s4,0x6
    80001062:	fa2a0a13          	addi	s4,s4,-94 # 80007000 <etext>
    80001066:	04000937          	lui	s2,0x4000
    8000106a:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000106c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000106e:	0000d997          	auipc	s3,0xd
    80001072:	a8298993          	addi	s3,s3,-1406 # 8000daf0 <tickslock>
      initlock(&p->lock, "proc");
    80001076:	85da                	mv	a1,s6
    80001078:	8526                	mv	a0,s1
    8000107a:	089040ef          	jal	ra,80005902 <initlock>
      p->state = UNUSED;
    8000107e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001082:	415487b3          	sub	a5,s1,s5
    80001086:	878d                	srai	a5,a5,0x3
    80001088:	000a3703          	ld	a4,0(s4)
    8000108c:	02e787b3          	mul	a5,a5,a4
    80001090:	2785                	addiw	a5,a5,1
    80001092:	00d7979b          	slliw	a5,a5,0xd
    80001096:	40f907b3          	sub	a5,s2,a5
    8000109a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000109c:	16848493          	addi	s1,s1,360
    800010a0:	fd349be3          	bne	s1,s3,80001076 <procinit+0x66>
  }
}
    800010a4:	70e2                	ld	ra,56(sp)
    800010a6:	7442                	ld	s0,48(sp)
    800010a8:	74a2                	ld	s1,40(sp)
    800010aa:	7902                	ld	s2,32(sp)
    800010ac:	69e2                	ld	s3,24(sp)
    800010ae:	6a42                	ld	s4,16(sp)
    800010b0:	6aa2                	ld	s5,8(sp)
    800010b2:	6b02                	ld	s6,0(sp)
    800010b4:	6121                	addi	sp,sp,64
    800010b6:	8082                	ret

00000000800010b8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800010b8:	1141                	addi	sp,sp,-16
    800010ba:	e422                	sd	s0,8(sp)
    800010bc:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800010be:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800010c0:	2501                	sext.w	a0,a0
    800010c2:	6422                	ld	s0,8(sp)
    800010c4:	0141                	addi	sp,sp,16
    800010c6:	8082                	ret

00000000800010c8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800010c8:	1141                	addi	sp,sp,-16
    800010ca:	e422                	sd	s0,8(sp)
    800010cc:	0800                	addi	s0,sp,16
    800010ce:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800010d0:	2781                	sext.w	a5,a5
    800010d2:	079e                	slli	a5,a5,0x7
  return c;
}
    800010d4:	00007517          	auipc	a0,0x7
    800010d8:	c1c50513          	addi	a0,a0,-996 # 80007cf0 <cpus>
    800010dc:	953e                	add	a0,a0,a5
    800010de:	6422                	ld	s0,8(sp)
    800010e0:	0141                	addi	sp,sp,16
    800010e2:	8082                	ret

00000000800010e4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800010e4:	1101                	addi	sp,sp,-32
    800010e6:	ec06                	sd	ra,24(sp)
    800010e8:	e822                	sd	s0,16(sp)
    800010ea:	e426                	sd	s1,8(sp)
    800010ec:	1000                	addi	s0,sp,32
  push_off();
    800010ee:	055040ef          	jal	ra,80005942 <push_off>
    800010f2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800010f4:	2781                	sext.w	a5,a5
    800010f6:	079e                	slli	a5,a5,0x7
    800010f8:	00007717          	auipc	a4,0x7
    800010fc:	bc870713          	addi	a4,a4,-1080 # 80007cc0 <pid_lock>
    80001100:	97ba                	add	a5,a5,a4
    80001102:	7b84                	ld	s1,48(a5)
  pop_off();
    80001104:	0c3040ef          	jal	ra,800059c6 <pop_off>
  return p;
}
    80001108:	8526                	mv	a0,s1
    8000110a:	60e2                	ld	ra,24(sp)
    8000110c:	6442                	ld	s0,16(sp)
    8000110e:	64a2                	ld	s1,8(sp)
    80001110:	6105                	addi	sp,sp,32
    80001112:	8082                	ret

0000000080001114 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001114:	1141                	addi	sp,sp,-16
    80001116:	e406                	sd	ra,8(sp)
    80001118:	e022                	sd	s0,0(sp)
    8000111a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000111c:	fc9ff0ef          	jal	ra,800010e4 <myproc>
    80001120:	0fb040ef          	jal	ra,80005a1a <release>

  if (first) {
    80001124:	00007797          	auipc	a5,0x7
    80001128:	8dc7a783          	lw	a5,-1828(a5) # 80007a00 <first.1>
    8000112c:	e799                	bnez	a5,8000113a <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000112e:	2bd000ef          	jal	ra,80001bea <usertrapret>
}
    80001132:	60a2                	ld	ra,8(sp)
    80001134:	6402                	ld	s0,0(sp)
    80001136:	0141                	addi	sp,sp,16
    80001138:	8082                	ret
    fsinit(ROOTDEV);
    8000113a:	4505                	li	a0,1
    8000113c:	688010ef          	jal	ra,800027c4 <fsinit>
    first = 0;
    80001140:	00007797          	auipc	a5,0x7
    80001144:	8c07a023          	sw	zero,-1856(a5) # 80007a00 <first.1>
    __sync_synchronize();
    80001148:	0ff0000f          	fence
    8000114c:	b7cd                	j	8000112e <forkret+0x1a>

000000008000114e <allocpid>:
{
    8000114e:	1101                	addi	sp,sp,-32
    80001150:	ec06                	sd	ra,24(sp)
    80001152:	e822                	sd	s0,16(sp)
    80001154:	e426                	sd	s1,8(sp)
    80001156:	e04a                	sd	s2,0(sp)
    80001158:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    8000115a:	00007917          	auipc	s2,0x7
    8000115e:	b6690913          	addi	s2,s2,-1178 # 80007cc0 <pid_lock>
    80001162:	854a                	mv	a0,s2
    80001164:	01f040ef          	jal	ra,80005982 <acquire>
  pid = nextpid;
    80001168:	00007797          	auipc	a5,0x7
    8000116c:	89c78793          	addi	a5,a5,-1892 # 80007a04 <nextpid>
    80001170:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001172:	0014871b          	addiw	a4,s1,1
    80001176:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001178:	854a                	mv	a0,s2
    8000117a:	0a1040ef          	jal	ra,80005a1a <release>
}
    8000117e:	8526                	mv	a0,s1
    80001180:	60e2                	ld	ra,24(sp)
    80001182:	6442                	ld	s0,16(sp)
    80001184:	64a2                	ld	s1,8(sp)
    80001186:	6902                	ld	s2,0(sp)
    80001188:	6105                	addi	sp,sp,32
    8000118a:	8082                	ret

000000008000118c <proc_pagetable>:
{
    8000118c:	1101                	addi	sp,sp,-32
    8000118e:	ec06                	sd	ra,24(sp)
    80001190:	e822                	sd	s0,16(sp)
    80001192:	e426                	sd	s1,8(sp)
    80001194:	e04a                	sd	s2,0(sp)
    80001196:	1000                	addi	s0,sp,32
    80001198:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    8000119a:	fb2ff0ef          	jal	ra,8000094c <uvmcreate>
    8000119e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011a0:	cd05                	beqz	a0,800011d8 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800011a2:	4729                	li	a4,10
    800011a4:	00005697          	auipc	a3,0x5
    800011a8:	e5c68693          	addi	a3,a3,-420 # 80006000 <_trampoline>
    800011ac:	6605                	lui	a2,0x1
    800011ae:	040005b7          	lui	a1,0x4000
    800011b2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011b4:	05b2                	slli	a1,a1,0xc
    800011b6:	cd6ff0ef          	jal	ra,8000068c <mappages>
    800011ba:	02054663          	bltz	a0,800011e6 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800011be:	4719                	li	a4,6
    800011c0:	05893683          	ld	a3,88(s2)
    800011c4:	6605                	lui	a2,0x1
    800011c6:	020005b7          	lui	a1,0x2000
    800011ca:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800011cc:	05b6                	slli	a1,a1,0xd
    800011ce:	8526                	mv	a0,s1
    800011d0:	cbcff0ef          	jal	ra,8000068c <mappages>
    800011d4:	00054f63          	bltz	a0,800011f2 <proc_pagetable+0x66>
}
    800011d8:	8526                	mv	a0,s1
    800011da:	60e2                	ld	ra,24(sp)
    800011dc:	6442                	ld	s0,16(sp)
    800011de:	64a2                	ld	s1,8(sp)
    800011e0:	6902                	ld	s2,0(sp)
    800011e2:	6105                	addi	sp,sp,32
    800011e4:	8082                	ret
    uvmfree(pagetable, 0);
    800011e6:	4581                	li	a1,0
    800011e8:	8526                	mv	a0,s1
    800011ea:	991ff0ef          	jal	ra,80000b7a <uvmfree>
    return 0;
    800011ee:	4481                	li	s1,0
    800011f0:	b7e5                	j	800011d8 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800011f2:	4681                	li	a3,0
    800011f4:	4605                	li	a2,1
    800011f6:	040005b7          	lui	a1,0x4000
    800011fa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011fc:	05b2                	slli	a1,a1,0xc
    800011fe:	8526                	mv	a0,s1
    80001200:	e90ff0ef          	jal	ra,80000890 <uvmunmap>
    uvmfree(pagetable, 0);
    80001204:	4581                	li	a1,0
    80001206:	8526                	mv	a0,s1
    80001208:	973ff0ef          	jal	ra,80000b7a <uvmfree>
    return 0;
    8000120c:	4481                	li	s1,0
    8000120e:	b7e9                	j	800011d8 <proc_pagetable+0x4c>

0000000080001210 <proc_freepagetable>:
{
    80001210:	1101                	addi	sp,sp,-32
    80001212:	ec06                	sd	ra,24(sp)
    80001214:	e822                	sd	s0,16(sp)
    80001216:	e426                	sd	s1,8(sp)
    80001218:	e04a                	sd	s2,0(sp)
    8000121a:	1000                	addi	s0,sp,32
    8000121c:	84aa                	mv	s1,a0
    8000121e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001220:	4681                	li	a3,0
    80001222:	4605                	li	a2,1
    80001224:	040005b7          	lui	a1,0x4000
    80001228:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000122a:	05b2                	slli	a1,a1,0xc
    8000122c:	e64ff0ef          	jal	ra,80000890 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001230:	4681                	li	a3,0
    80001232:	4605                	li	a2,1
    80001234:	020005b7          	lui	a1,0x2000
    80001238:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    8000123a:	05b6                	slli	a1,a1,0xd
    8000123c:	8526                	mv	a0,s1
    8000123e:	e52ff0ef          	jal	ra,80000890 <uvmunmap>
  uvmfree(pagetable, sz);
    80001242:	85ca                	mv	a1,s2
    80001244:	8526                	mv	a0,s1
    80001246:	935ff0ef          	jal	ra,80000b7a <uvmfree>
}
    8000124a:	60e2                	ld	ra,24(sp)
    8000124c:	6442                	ld	s0,16(sp)
    8000124e:	64a2                	ld	s1,8(sp)
    80001250:	6902                	ld	s2,0(sp)
    80001252:	6105                	addi	sp,sp,32
    80001254:	8082                	ret

0000000080001256 <freeproc>:
{
    80001256:	1101                	addi	sp,sp,-32
    80001258:	ec06                	sd	ra,24(sp)
    8000125a:	e822                	sd	s0,16(sp)
    8000125c:	e426                	sd	s1,8(sp)
    8000125e:	1000                	addi	s0,sp,32
    80001260:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001262:	6d28                	ld	a0,88(a0)
    80001264:	c119                	beqz	a0,8000126a <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001266:	e0bfe0ef          	jal	ra,80000070 <kfree>
  p->trapframe = 0;
    8000126a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    8000126e:	68a8                	ld	a0,80(s1)
    80001270:	c501                	beqz	a0,80001278 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001272:	64ac                	ld	a1,72(s1)
    80001274:	f9dff0ef          	jal	ra,80001210 <proc_freepagetable>
  p->pagetable = 0;
    80001278:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    8000127c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001280:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001284:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001288:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    8000128c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001290:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001294:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001298:	0004ac23          	sw	zero,24(s1)
}
    8000129c:	60e2                	ld	ra,24(sp)
    8000129e:	6442                	ld	s0,16(sp)
    800012a0:	64a2                	ld	s1,8(sp)
    800012a2:	6105                	addi	sp,sp,32
    800012a4:	8082                	ret

00000000800012a6 <allocproc>:
{
    800012a6:	1101                	addi	sp,sp,-32
    800012a8:	ec06                	sd	ra,24(sp)
    800012aa:	e822                	sd	s0,16(sp)
    800012ac:	e426                	sd	s1,8(sp)
    800012ae:	e04a                	sd	s2,0(sp)
    800012b0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    800012b2:	00007497          	auipc	s1,0x7
    800012b6:	e3e48493          	addi	s1,s1,-450 # 800080f0 <proc>
    800012ba:	0000d917          	auipc	s2,0xd
    800012be:	83690913          	addi	s2,s2,-1994 # 8000daf0 <tickslock>
    acquire(&p->lock);
    800012c2:	8526                	mv	a0,s1
    800012c4:	6be040ef          	jal	ra,80005982 <acquire>
    if(p->state == UNUSED) {
    800012c8:	4c9c                	lw	a5,24(s1)
    800012ca:	cb91                	beqz	a5,800012de <allocproc+0x38>
      release(&p->lock);
    800012cc:	8526                	mv	a0,s1
    800012ce:	74c040ef          	jal	ra,80005a1a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800012d2:	16848493          	addi	s1,s1,360
    800012d6:	ff2496e3          	bne	s1,s2,800012c2 <allocproc+0x1c>
  return 0;
    800012da:	4481                	li	s1,0
    800012dc:	a089                	j	8000131e <allocproc+0x78>
  p->pid = allocpid();
    800012de:	e71ff0ef          	jal	ra,8000114e <allocpid>
    800012e2:	d888                	sw	a0,48(s1)
  p->state = USED;
    800012e4:	4785                	li	a5,1
    800012e6:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800012e8:	e7dfe0ef          	jal	ra,80000164 <kalloc>
    800012ec:	892a                	mv	s2,a0
    800012ee:	eca8                	sd	a0,88(s1)
    800012f0:	cd15                	beqz	a0,8000132c <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    800012f2:	8526                	mv	a0,s1
    800012f4:	e99ff0ef          	jal	ra,8000118c <proc_pagetable>
    800012f8:	892a                	mv	s2,a0
    800012fa:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800012fc:	c121                	beqz	a0,8000133c <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    800012fe:	07000613          	li	a2,112
    80001302:	4581                	li	a1,0
    80001304:	06048513          	addi	a0,s1,96
    80001308:	fabfe0ef          	jal	ra,800002b2 <memset>
  p->context.ra = (uint64)forkret;
    8000130c:	00000797          	auipc	a5,0x0
    80001310:	e0878793          	addi	a5,a5,-504 # 80001114 <forkret>
    80001314:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001316:	60bc                	ld	a5,64(s1)
    80001318:	6705                	lui	a4,0x1
    8000131a:	97ba                	add	a5,a5,a4
    8000131c:	f4bc                	sd	a5,104(s1)
}
    8000131e:	8526                	mv	a0,s1
    80001320:	60e2                	ld	ra,24(sp)
    80001322:	6442                	ld	s0,16(sp)
    80001324:	64a2                	ld	s1,8(sp)
    80001326:	6902                	ld	s2,0(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    freeproc(p);
    8000132c:	8526                	mv	a0,s1
    8000132e:	f29ff0ef          	jal	ra,80001256 <freeproc>
    release(&p->lock);
    80001332:	8526                	mv	a0,s1
    80001334:	6e6040ef          	jal	ra,80005a1a <release>
    return 0;
    80001338:	84ca                	mv	s1,s2
    8000133a:	b7d5                	j	8000131e <allocproc+0x78>
    freeproc(p);
    8000133c:	8526                	mv	a0,s1
    8000133e:	f19ff0ef          	jal	ra,80001256 <freeproc>
    release(&p->lock);
    80001342:	8526                	mv	a0,s1
    80001344:	6d6040ef          	jal	ra,80005a1a <release>
    return 0;
    80001348:	84ca                	mv	s1,s2
    8000134a:	bfd1                	j	8000131e <allocproc+0x78>

000000008000134c <userinit>:
{
    8000134c:	1101                	addi	sp,sp,-32
    8000134e:	ec06                	sd	ra,24(sp)
    80001350:	e822                	sd	s0,16(sp)
    80001352:	e426                	sd	s1,8(sp)
    80001354:	1000                	addi	s0,sp,32
  p = allocproc();
    80001356:	f51ff0ef          	jal	ra,800012a6 <allocproc>
    8000135a:	84aa                	mv	s1,a0
  initproc = p;
    8000135c:	00006797          	auipc	a5,0x6
    80001360:	72a7b223          	sd	a0,1828(a5) # 80007a80 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001364:	03400613          	li	a2,52
    80001368:	00006597          	auipc	a1,0x6
    8000136c:	6a858593          	addi	a1,a1,1704 # 80007a10 <initcode>
    80001370:	6928                	ld	a0,80(a0)
    80001372:	e00ff0ef          	jal	ra,80000972 <uvmfirst>
  p->sz = PGSIZE;
    80001376:	6785                	lui	a5,0x1
    80001378:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    8000137a:	6cb8                	ld	a4,88(s1)
    8000137c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001380:	6cb8                	ld	a4,88(s1)
    80001382:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001384:	4641                	li	a2,16
    80001386:	00006597          	auipc	a1,0x6
    8000138a:	f5258593          	addi	a1,a1,-174 # 800072d8 <etext+0x2d8>
    8000138e:	15848513          	addi	a0,s1,344
    80001392:	866ff0ef          	jal	ra,800003f8 <safestrcpy>
  p->cwd = namei("/");
    80001396:	00006517          	auipc	a0,0x6
    8000139a:	f5250513          	addi	a0,a0,-174 # 800072e8 <etext+0x2e8>
    8000139e:	50d010ef          	jal	ra,800030aa <namei>
    800013a2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800013a6:	478d                	li	a5,3
    800013a8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800013aa:	8526                	mv	a0,s1
    800013ac:	66e040ef          	jal	ra,80005a1a <release>
}
    800013b0:	60e2                	ld	ra,24(sp)
    800013b2:	6442                	ld	s0,16(sp)
    800013b4:	64a2                	ld	s1,8(sp)
    800013b6:	6105                	addi	sp,sp,32
    800013b8:	8082                	ret

00000000800013ba <growproc>:
{
    800013ba:	1101                	addi	sp,sp,-32
    800013bc:	ec06                	sd	ra,24(sp)
    800013be:	e822                	sd	s0,16(sp)
    800013c0:	e426                	sd	s1,8(sp)
    800013c2:	e04a                	sd	s2,0(sp)
    800013c4:	1000                	addi	s0,sp,32
    800013c6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800013c8:	d1dff0ef          	jal	ra,800010e4 <myproc>
    800013cc:	84aa                	mv	s1,a0
  sz = p->sz;
    800013ce:	652c                	ld	a1,72(a0)
  if(n > 0){
    800013d0:	01204c63          	bgtz	s2,800013e8 <growproc+0x2e>
  } else if(n < 0){
    800013d4:	02094463          	bltz	s2,800013fc <growproc+0x42>
  p->sz = sz;
    800013d8:	e4ac                	sd	a1,72(s1)
  return 0;
    800013da:	4501                	li	a0,0
}
    800013dc:	60e2                	ld	ra,24(sp)
    800013de:	6442                	ld	s0,16(sp)
    800013e0:	64a2                	ld	s1,8(sp)
    800013e2:	6902                	ld	s2,0(sp)
    800013e4:	6105                	addi	sp,sp,32
    800013e6:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800013e8:	4691                	li	a3,4
    800013ea:	00b90633          	add	a2,s2,a1
    800013ee:	6928                	ld	a0,80(a0)
    800013f0:	e24ff0ef          	jal	ra,80000a14 <uvmalloc>
    800013f4:	85aa                	mv	a1,a0
    800013f6:	f16d                	bnez	a0,800013d8 <growproc+0x1e>
      return -1;
    800013f8:	557d                	li	a0,-1
    800013fa:	b7cd                	j	800013dc <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800013fc:	00b90633          	add	a2,s2,a1
    80001400:	6928                	ld	a0,80(a0)
    80001402:	dceff0ef          	jal	ra,800009d0 <uvmdealloc>
    80001406:	85aa                	mv	a1,a0
    80001408:	bfc1                	j	800013d8 <growproc+0x1e>

000000008000140a <fork>:
{
    8000140a:	7139                	addi	sp,sp,-64
    8000140c:	fc06                	sd	ra,56(sp)
    8000140e:	f822                	sd	s0,48(sp)
    80001410:	f426                	sd	s1,40(sp)
    80001412:	f04a                	sd	s2,32(sp)
    80001414:	ec4e                	sd	s3,24(sp)
    80001416:	e852                	sd	s4,16(sp)
    80001418:	e456                	sd	s5,8(sp)
    8000141a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000141c:	cc9ff0ef          	jal	ra,800010e4 <myproc>
    80001420:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001422:	e85ff0ef          	jal	ra,800012a6 <allocproc>
    80001426:	0e050663          	beqz	a0,80001512 <fork+0x108>
    8000142a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000142c:	048ab603          	ld	a2,72(s5)
    80001430:	692c                	ld	a1,80(a0)
    80001432:	050ab503          	ld	a0,80(s5)
    80001436:	f76ff0ef          	jal	ra,80000bac <uvmcopy>
    8000143a:	04054863          	bltz	a0,8000148a <fork+0x80>
  np->sz = p->sz;
    8000143e:	048ab783          	ld	a5,72(s5)
    80001442:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001446:	058ab683          	ld	a3,88(s5)
    8000144a:	87b6                	mv	a5,a3
    8000144c:	058a3703          	ld	a4,88(s4)
    80001450:	12068693          	addi	a3,a3,288
    80001454:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001458:	6788                	ld	a0,8(a5)
    8000145a:	6b8c                	ld	a1,16(a5)
    8000145c:	6f90                	ld	a2,24(a5)
    8000145e:	01073023          	sd	a6,0(a4)
    80001462:	e708                	sd	a0,8(a4)
    80001464:	eb0c                	sd	a1,16(a4)
    80001466:	ef10                	sd	a2,24(a4)
    80001468:	02078793          	addi	a5,a5,32
    8000146c:	02070713          	addi	a4,a4,32
    80001470:	fed792e3          	bne	a5,a3,80001454 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001474:	058a3783          	ld	a5,88(s4)
    80001478:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    8000147c:	0d0a8493          	addi	s1,s5,208
    80001480:	0d0a0913          	addi	s2,s4,208
    80001484:	150a8993          	addi	s3,s5,336
    80001488:	a829                	j	800014a2 <fork+0x98>
    freeproc(np);
    8000148a:	8552                	mv	a0,s4
    8000148c:	dcbff0ef          	jal	ra,80001256 <freeproc>
    release(&np->lock);
    80001490:	8552                	mv	a0,s4
    80001492:	588040ef          	jal	ra,80005a1a <release>
    return -1;
    80001496:	597d                	li	s2,-1
    80001498:	a09d                	j	800014fe <fork+0xf4>
  for(i = 0; i < NOFILE; i++)
    8000149a:	04a1                	addi	s1,s1,8
    8000149c:	0921                	addi	s2,s2,8
    8000149e:	01348963          	beq	s1,s3,800014b0 <fork+0xa6>
    if(p->ofile[i])
    800014a2:	6088                	ld	a0,0(s1)
    800014a4:	d97d                	beqz	a0,8000149a <fork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    800014a6:	1b2020ef          	jal	ra,80003658 <filedup>
    800014aa:	00a93023          	sd	a0,0(s2)
    800014ae:	b7f5                	j	8000149a <fork+0x90>
  np->cwd = idup(p->cwd);
    800014b0:	150ab503          	ld	a0,336(s5)
    800014b4:	508010ef          	jal	ra,800029bc <idup>
    800014b8:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800014bc:	4641                	li	a2,16
    800014be:	158a8593          	addi	a1,s5,344
    800014c2:	158a0513          	addi	a0,s4,344
    800014c6:	f33fe0ef          	jal	ra,800003f8 <safestrcpy>
  pid = np->pid;
    800014ca:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    800014ce:	8552                	mv	a0,s4
    800014d0:	54a040ef          	jal	ra,80005a1a <release>
  acquire(&wait_lock);
    800014d4:	00007497          	auipc	s1,0x7
    800014d8:	80448493          	addi	s1,s1,-2044 # 80007cd8 <wait_lock>
    800014dc:	8526                	mv	a0,s1
    800014de:	4a4040ef          	jal	ra,80005982 <acquire>
  np->parent = p;
    800014e2:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    800014e6:	8526                	mv	a0,s1
    800014e8:	532040ef          	jal	ra,80005a1a <release>
  acquire(&np->lock);
    800014ec:	8552                	mv	a0,s4
    800014ee:	494040ef          	jal	ra,80005982 <acquire>
  np->state = RUNNABLE;
    800014f2:	478d                	li	a5,3
    800014f4:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    800014f8:	8552                	mv	a0,s4
    800014fa:	520040ef          	jal	ra,80005a1a <release>
}
    800014fe:	854a                	mv	a0,s2
    80001500:	70e2                	ld	ra,56(sp)
    80001502:	7442                	ld	s0,48(sp)
    80001504:	74a2                	ld	s1,40(sp)
    80001506:	7902                	ld	s2,32(sp)
    80001508:	69e2                	ld	s3,24(sp)
    8000150a:	6a42                	ld	s4,16(sp)
    8000150c:	6aa2                	ld	s5,8(sp)
    8000150e:	6121                	addi	sp,sp,64
    80001510:	8082                	ret
    return -1;
    80001512:	597d                	li	s2,-1
    80001514:	b7ed                	j	800014fe <fork+0xf4>

0000000080001516 <scheduler>:
{
    80001516:	715d                	addi	sp,sp,-80
    80001518:	e486                	sd	ra,72(sp)
    8000151a:	e0a2                	sd	s0,64(sp)
    8000151c:	fc26                	sd	s1,56(sp)
    8000151e:	f84a                	sd	s2,48(sp)
    80001520:	f44e                	sd	s3,40(sp)
    80001522:	f052                	sd	s4,32(sp)
    80001524:	ec56                	sd	s5,24(sp)
    80001526:	e85a                	sd	s6,16(sp)
    80001528:	e45e                	sd	s7,8(sp)
    8000152a:	e062                	sd	s8,0(sp)
    8000152c:	0880                	addi	s0,sp,80
    8000152e:	8792                	mv	a5,tp
  int id = r_tp();
    80001530:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001532:	00779b13          	slli	s6,a5,0x7
    80001536:	00006717          	auipc	a4,0x6
    8000153a:	78a70713          	addi	a4,a4,1930 # 80007cc0 <pid_lock>
    8000153e:	975a                	add	a4,a4,s6
    80001540:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001544:	00006717          	auipc	a4,0x6
    80001548:	7b470713          	addi	a4,a4,1972 # 80007cf8 <cpus+0x8>
    8000154c:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    8000154e:	4c11                	li	s8,4
        c->proc = p;
    80001550:	079e                	slli	a5,a5,0x7
    80001552:	00006a17          	auipc	s4,0x6
    80001556:	76ea0a13          	addi	s4,s4,1902 # 80007cc0 <pid_lock>
    8000155a:	9a3e                	add	s4,s4,a5
        found = 1;
    8000155c:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    8000155e:	0000c997          	auipc	s3,0xc
    80001562:	59298993          	addi	s3,s3,1426 # 8000daf0 <tickslock>
    80001566:	a0a9                	j	800015b0 <scheduler+0x9a>
      release(&p->lock);
    80001568:	8526                	mv	a0,s1
    8000156a:	4b0040ef          	jal	ra,80005a1a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000156e:	16848493          	addi	s1,s1,360
    80001572:	03348563          	beq	s1,s3,8000159c <scheduler+0x86>
      acquire(&p->lock);
    80001576:	8526                	mv	a0,s1
    80001578:	40a040ef          	jal	ra,80005982 <acquire>
      if(p->state == RUNNABLE) {
    8000157c:	4c9c                	lw	a5,24(s1)
    8000157e:	ff2795e3          	bne	a5,s2,80001568 <scheduler+0x52>
        p->state = RUNNING;
    80001582:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001586:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000158a:	06048593          	addi	a1,s1,96
    8000158e:	855a                	mv	a0,s6
    80001590:	5b4000ef          	jal	ra,80001b44 <swtch>
        c->proc = 0;
    80001594:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001598:	8ade                	mv	s5,s7
    8000159a:	b7f9                	j	80001568 <scheduler+0x52>
    if(found == 0) {
    8000159c:	000a9a63          	bnez	s5,800015b0 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800015a0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800015a4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800015a8:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800015ac:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800015b0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800015b4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800015b8:	10079073          	csrw	sstatus,a5
    int found = 0;
    800015bc:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800015be:	00007497          	auipc	s1,0x7
    800015c2:	b3248493          	addi	s1,s1,-1230 # 800080f0 <proc>
      if(p->state == RUNNABLE) {
    800015c6:	490d                	li	s2,3
    800015c8:	b77d                	j	80001576 <scheduler+0x60>

00000000800015ca <sched>:
{
    800015ca:	7179                	addi	sp,sp,-48
    800015cc:	f406                	sd	ra,40(sp)
    800015ce:	f022                	sd	s0,32(sp)
    800015d0:	ec26                	sd	s1,24(sp)
    800015d2:	e84a                	sd	s2,16(sp)
    800015d4:	e44e                	sd	s3,8(sp)
    800015d6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800015d8:	b0dff0ef          	jal	ra,800010e4 <myproc>
    800015dc:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800015de:	33a040ef          	jal	ra,80005918 <holding>
    800015e2:	c92d                	beqz	a0,80001654 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800015e4:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800015e6:	2781                	sext.w	a5,a5
    800015e8:	079e                	slli	a5,a5,0x7
    800015ea:	00006717          	auipc	a4,0x6
    800015ee:	6d670713          	addi	a4,a4,1750 # 80007cc0 <pid_lock>
    800015f2:	97ba                	add	a5,a5,a4
    800015f4:	0a87a703          	lw	a4,168(a5)
    800015f8:	4785                	li	a5,1
    800015fa:	06f71363          	bne	a4,a5,80001660 <sched+0x96>
  if(p->state == RUNNING)
    800015fe:	4c98                	lw	a4,24(s1)
    80001600:	4791                	li	a5,4
    80001602:	06f70563          	beq	a4,a5,8000166c <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001606:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000160a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000160c:	e7b5                	bnez	a5,80001678 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000160e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001610:	00006917          	auipc	s2,0x6
    80001614:	6b090913          	addi	s2,s2,1712 # 80007cc0 <pid_lock>
    80001618:	2781                	sext.w	a5,a5
    8000161a:	079e                	slli	a5,a5,0x7
    8000161c:	97ca                	add	a5,a5,s2
    8000161e:	0ac7a983          	lw	s3,172(a5)
    80001622:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001624:	2781                	sext.w	a5,a5
    80001626:	079e                	slli	a5,a5,0x7
    80001628:	00006597          	auipc	a1,0x6
    8000162c:	6d058593          	addi	a1,a1,1744 # 80007cf8 <cpus+0x8>
    80001630:	95be                	add	a1,a1,a5
    80001632:	06048513          	addi	a0,s1,96
    80001636:	50e000ef          	jal	ra,80001b44 <swtch>
    8000163a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000163c:	2781                	sext.w	a5,a5
    8000163e:	079e                	slli	a5,a5,0x7
    80001640:	993e                	add	s2,s2,a5
    80001642:	0b392623          	sw	s3,172(s2)
}
    80001646:	70a2                	ld	ra,40(sp)
    80001648:	7402                	ld	s0,32(sp)
    8000164a:	64e2                	ld	s1,24(sp)
    8000164c:	6942                	ld	s2,16(sp)
    8000164e:	69a2                	ld	s3,8(sp)
    80001650:	6145                	addi	sp,sp,48
    80001652:	8082                	ret
    panic("sched p->lock");
    80001654:	00006517          	auipc	a0,0x6
    80001658:	c9c50513          	addi	a0,a0,-868 # 800072f0 <etext+0x2f0>
    8000165c:	016040ef          	jal	ra,80005672 <panic>
    panic("sched locks");
    80001660:	00006517          	auipc	a0,0x6
    80001664:	ca050513          	addi	a0,a0,-864 # 80007300 <etext+0x300>
    80001668:	00a040ef          	jal	ra,80005672 <panic>
    panic("sched running");
    8000166c:	00006517          	auipc	a0,0x6
    80001670:	ca450513          	addi	a0,a0,-860 # 80007310 <etext+0x310>
    80001674:	7ff030ef          	jal	ra,80005672 <panic>
    panic("sched interruptible");
    80001678:	00006517          	auipc	a0,0x6
    8000167c:	ca850513          	addi	a0,a0,-856 # 80007320 <etext+0x320>
    80001680:	7f3030ef          	jal	ra,80005672 <panic>

0000000080001684 <yield>:
{
    80001684:	1101                	addi	sp,sp,-32
    80001686:	ec06                	sd	ra,24(sp)
    80001688:	e822                	sd	s0,16(sp)
    8000168a:	e426                	sd	s1,8(sp)
    8000168c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000168e:	a57ff0ef          	jal	ra,800010e4 <myproc>
    80001692:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001694:	2ee040ef          	jal	ra,80005982 <acquire>
  p->state = RUNNABLE;
    80001698:	478d                	li	a5,3
    8000169a:	cc9c                	sw	a5,24(s1)
  sched();
    8000169c:	f2fff0ef          	jal	ra,800015ca <sched>
  release(&p->lock);
    800016a0:	8526                	mv	a0,s1
    800016a2:	378040ef          	jal	ra,80005a1a <release>
}
    800016a6:	60e2                	ld	ra,24(sp)
    800016a8:	6442                	ld	s0,16(sp)
    800016aa:	64a2                	ld	s1,8(sp)
    800016ac:	6105                	addi	sp,sp,32
    800016ae:	8082                	ret

00000000800016b0 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800016b0:	7179                	addi	sp,sp,-48
    800016b2:	f406                	sd	ra,40(sp)
    800016b4:	f022                	sd	s0,32(sp)
    800016b6:	ec26                	sd	s1,24(sp)
    800016b8:	e84a                	sd	s2,16(sp)
    800016ba:	e44e                	sd	s3,8(sp)
    800016bc:	1800                	addi	s0,sp,48
    800016be:	89aa                	mv	s3,a0
    800016c0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800016c2:	a23ff0ef          	jal	ra,800010e4 <myproc>
    800016c6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800016c8:	2ba040ef          	jal	ra,80005982 <acquire>
  release(lk);
    800016cc:	854a                	mv	a0,s2
    800016ce:	34c040ef          	jal	ra,80005a1a <release>

  // Go to sleep.
  p->chan = chan;
    800016d2:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800016d6:	4789                	li	a5,2
    800016d8:	cc9c                	sw	a5,24(s1)

  sched();
    800016da:	ef1ff0ef          	jal	ra,800015ca <sched>

  // Tidy up.
  p->chan = 0;
    800016de:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800016e2:	8526                	mv	a0,s1
    800016e4:	336040ef          	jal	ra,80005a1a <release>
  acquire(lk);
    800016e8:	854a                	mv	a0,s2
    800016ea:	298040ef          	jal	ra,80005982 <acquire>
}
    800016ee:	70a2                	ld	ra,40(sp)
    800016f0:	7402                	ld	s0,32(sp)
    800016f2:	64e2                	ld	s1,24(sp)
    800016f4:	6942                	ld	s2,16(sp)
    800016f6:	69a2                	ld	s3,8(sp)
    800016f8:	6145                	addi	sp,sp,48
    800016fa:	8082                	ret

00000000800016fc <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800016fc:	7139                	addi	sp,sp,-64
    800016fe:	fc06                	sd	ra,56(sp)
    80001700:	f822                	sd	s0,48(sp)
    80001702:	f426                	sd	s1,40(sp)
    80001704:	f04a                	sd	s2,32(sp)
    80001706:	ec4e                	sd	s3,24(sp)
    80001708:	e852                	sd	s4,16(sp)
    8000170a:	e456                	sd	s5,8(sp)
    8000170c:	0080                	addi	s0,sp,64
    8000170e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001710:	00007497          	auipc	s1,0x7
    80001714:	9e048493          	addi	s1,s1,-1568 # 800080f0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001718:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000171a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000171c:	0000c917          	auipc	s2,0xc
    80001720:	3d490913          	addi	s2,s2,980 # 8000daf0 <tickslock>
    80001724:	a801                	j	80001734 <wakeup+0x38>
      }
      release(&p->lock);
    80001726:	8526                	mv	a0,s1
    80001728:	2f2040ef          	jal	ra,80005a1a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000172c:	16848493          	addi	s1,s1,360
    80001730:	03248263          	beq	s1,s2,80001754 <wakeup+0x58>
    if(p != myproc()){
    80001734:	9b1ff0ef          	jal	ra,800010e4 <myproc>
    80001738:	fea48ae3          	beq	s1,a0,8000172c <wakeup+0x30>
      acquire(&p->lock);
    8000173c:	8526                	mv	a0,s1
    8000173e:	244040ef          	jal	ra,80005982 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001742:	4c9c                	lw	a5,24(s1)
    80001744:	ff3791e3          	bne	a5,s3,80001726 <wakeup+0x2a>
    80001748:	709c                	ld	a5,32(s1)
    8000174a:	fd479ee3          	bne	a5,s4,80001726 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000174e:	0154ac23          	sw	s5,24(s1)
    80001752:	bfd1                	j	80001726 <wakeup+0x2a>
    }
  }
}
    80001754:	70e2                	ld	ra,56(sp)
    80001756:	7442                	ld	s0,48(sp)
    80001758:	74a2                	ld	s1,40(sp)
    8000175a:	7902                	ld	s2,32(sp)
    8000175c:	69e2                	ld	s3,24(sp)
    8000175e:	6a42                	ld	s4,16(sp)
    80001760:	6aa2                	ld	s5,8(sp)
    80001762:	6121                	addi	sp,sp,64
    80001764:	8082                	ret

0000000080001766 <reparent>:
{
    80001766:	7179                	addi	sp,sp,-48
    80001768:	f406                	sd	ra,40(sp)
    8000176a:	f022                	sd	s0,32(sp)
    8000176c:	ec26                	sd	s1,24(sp)
    8000176e:	e84a                	sd	s2,16(sp)
    80001770:	e44e                	sd	s3,8(sp)
    80001772:	e052                	sd	s4,0(sp)
    80001774:	1800                	addi	s0,sp,48
    80001776:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001778:	00007497          	auipc	s1,0x7
    8000177c:	97848493          	addi	s1,s1,-1672 # 800080f0 <proc>
      pp->parent = initproc;
    80001780:	00006a17          	auipc	s4,0x6
    80001784:	300a0a13          	addi	s4,s4,768 # 80007a80 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001788:	0000c997          	auipc	s3,0xc
    8000178c:	36898993          	addi	s3,s3,872 # 8000daf0 <tickslock>
    80001790:	a029                	j	8000179a <reparent+0x34>
    80001792:	16848493          	addi	s1,s1,360
    80001796:	01348b63          	beq	s1,s3,800017ac <reparent+0x46>
    if(pp->parent == p){
    8000179a:	7c9c                	ld	a5,56(s1)
    8000179c:	ff279be3          	bne	a5,s2,80001792 <reparent+0x2c>
      pp->parent = initproc;
    800017a0:	000a3503          	ld	a0,0(s4)
    800017a4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800017a6:	f57ff0ef          	jal	ra,800016fc <wakeup>
    800017aa:	b7e5                	j	80001792 <reparent+0x2c>
}
    800017ac:	70a2                	ld	ra,40(sp)
    800017ae:	7402                	ld	s0,32(sp)
    800017b0:	64e2                	ld	s1,24(sp)
    800017b2:	6942                	ld	s2,16(sp)
    800017b4:	69a2                	ld	s3,8(sp)
    800017b6:	6a02                	ld	s4,0(sp)
    800017b8:	6145                	addi	sp,sp,48
    800017ba:	8082                	ret

00000000800017bc <exit>:
{
    800017bc:	7179                	addi	sp,sp,-48
    800017be:	f406                	sd	ra,40(sp)
    800017c0:	f022                	sd	s0,32(sp)
    800017c2:	ec26                	sd	s1,24(sp)
    800017c4:	e84a                	sd	s2,16(sp)
    800017c6:	e44e                	sd	s3,8(sp)
    800017c8:	e052                	sd	s4,0(sp)
    800017ca:	1800                	addi	s0,sp,48
    800017cc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800017ce:	917ff0ef          	jal	ra,800010e4 <myproc>
    800017d2:	89aa                	mv	s3,a0
  if(p == initproc)
    800017d4:	00006797          	auipc	a5,0x6
    800017d8:	2ac7b783          	ld	a5,684(a5) # 80007a80 <initproc>
    800017dc:	0d050493          	addi	s1,a0,208
    800017e0:	15050913          	addi	s2,a0,336
    800017e4:	00a79f63          	bne	a5,a0,80001802 <exit+0x46>
    panic("init exiting");
    800017e8:	00006517          	auipc	a0,0x6
    800017ec:	b5050513          	addi	a0,a0,-1200 # 80007338 <etext+0x338>
    800017f0:	683030ef          	jal	ra,80005672 <panic>
      fileclose(f);
    800017f4:	6ab010ef          	jal	ra,8000369e <fileclose>
      p->ofile[fd] = 0;
    800017f8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800017fc:	04a1                	addi	s1,s1,8
    800017fe:	01248563          	beq	s1,s2,80001808 <exit+0x4c>
    if(p->ofile[fd]){
    80001802:	6088                	ld	a0,0(s1)
    80001804:	f965                	bnez	a0,800017f4 <exit+0x38>
    80001806:	bfdd                	j	800017fc <exit+0x40>
  begin_op();
    80001808:	27f010ef          	jal	ra,80003286 <begin_op>
  iput(p->cwd);
    8000180c:	1509b503          	ld	a0,336(s3)
    80001810:	360010ef          	jal	ra,80002b70 <iput>
  end_op();
    80001814:	2e1010ef          	jal	ra,800032f4 <end_op>
  p->cwd = 0;
    80001818:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000181c:	00006497          	auipc	s1,0x6
    80001820:	4bc48493          	addi	s1,s1,1212 # 80007cd8 <wait_lock>
    80001824:	8526                	mv	a0,s1
    80001826:	15c040ef          	jal	ra,80005982 <acquire>
  reparent(p);
    8000182a:	854e                	mv	a0,s3
    8000182c:	f3bff0ef          	jal	ra,80001766 <reparent>
  wakeup(p->parent);
    80001830:	0389b503          	ld	a0,56(s3)
    80001834:	ec9ff0ef          	jal	ra,800016fc <wakeup>
  acquire(&p->lock);
    80001838:	854e                	mv	a0,s3
    8000183a:	148040ef          	jal	ra,80005982 <acquire>
  p->xstate = status;
    8000183e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001842:	4795                	li	a5,5
    80001844:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001848:	8526                	mv	a0,s1
    8000184a:	1d0040ef          	jal	ra,80005a1a <release>
  sched();
    8000184e:	d7dff0ef          	jal	ra,800015ca <sched>
  panic("zombie exit");
    80001852:	00006517          	auipc	a0,0x6
    80001856:	af650513          	addi	a0,a0,-1290 # 80007348 <etext+0x348>
    8000185a:	619030ef          	jal	ra,80005672 <panic>

000000008000185e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000185e:	7179                	addi	sp,sp,-48
    80001860:	f406                	sd	ra,40(sp)
    80001862:	f022                	sd	s0,32(sp)
    80001864:	ec26                	sd	s1,24(sp)
    80001866:	e84a                	sd	s2,16(sp)
    80001868:	e44e                	sd	s3,8(sp)
    8000186a:	1800                	addi	s0,sp,48
    8000186c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000186e:	00007497          	auipc	s1,0x7
    80001872:	88248493          	addi	s1,s1,-1918 # 800080f0 <proc>
    80001876:	0000c997          	auipc	s3,0xc
    8000187a:	27a98993          	addi	s3,s3,634 # 8000daf0 <tickslock>
    acquire(&p->lock);
    8000187e:	8526                	mv	a0,s1
    80001880:	102040ef          	jal	ra,80005982 <acquire>
    if(p->pid == pid){
    80001884:	589c                	lw	a5,48(s1)
    80001886:	01278b63          	beq	a5,s2,8000189c <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000188a:	8526                	mv	a0,s1
    8000188c:	18e040ef          	jal	ra,80005a1a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001890:	16848493          	addi	s1,s1,360
    80001894:	ff3495e3          	bne	s1,s3,8000187e <kill+0x20>
  }
  return -1;
    80001898:	557d                	li	a0,-1
    8000189a:	a819                	j	800018b0 <kill+0x52>
      p->killed = 1;
    8000189c:	4785                	li	a5,1
    8000189e:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800018a0:	4c98                	lw	a4,24(s1)
    800018a2:	4789                	li	a5,2
    800018a4:	00f70d63          	beq	a4,a5,800018be <kill+0x60>
      release(&p->lock);
    800018a8:	8526                	mv	a0,s1
    800018aa:	170040ef          	jal	ra,80005a1a <release>
      return 0;
    800018ae:	4501                	li	a0,0
}
    800018b0:	70a2                	ld	ra,40(sp)
    800018b2:	7402                	ld	s0,32(sp)
    800018b4:	64e2                	ld	s1,24(sp)
    800018b6:	6942                	ld	s2,16(sp)
    800018b8:	69a2                	ld	s3,8(sp)
    800018ba:	6145                	addi	sp,sp,48
    800018bc:	8082                	ret
        p->state = RUNNABLE;
    800018be:	478d                	li	a5,3
    800018c0:	cc9c                	sw	a5,24(s1)
    800018c2:	b7dd                	j	800018a8 <kill+0x4a>

00000000800018c4 <setkilled>:

void
setkilled(struct proc *p)
{
    800018c4:	1101                	addi	sp,sp,-32
    800018c6:	ec06                	sd	ra,24(sp)
    800018c8:	e822                	sd	s0,16(sp)
    800018ca:	e426                	sd	s1,8(sp)
    800018cc:	1000                	addi	s0,sp,32
    800018ce:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800018d0:	0b2040ef          	jal	ra,80005982 <acquire>
  p->killed = 1;
    800018d4:	4785                	li	a5,1
    800018d6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800018d8:	8526                	mv	a0,s1
    800018da:	140040ef          	jal	ra,80005a1a <release>
}
    800018de:	60e2                	ld	ra,24(sp)
    800018e0:	6442                	ld	s0,16(sp)
    800018e2:	64a2                	ld	s1,8(sp)
    800018e4:	6105                	addi	sp,sp,32
    800018e6:	8082                	ret

00000000800018e8 <killed>:

int
killed(struct proc *p)
{
    800018e8:	1101                	addi	sp,sp,-32
    800018ea:	ec06                	sd	ra,24(sp)
    800018ec:	e822                	sd	s0,16(sp)
    800018ee:	e426                	sd	s1,8(sp)
    800018f0:	e04a                	sd	s2,0(sp)
    800018f2:	1000                	addi	s0,sp,32
    800018f4:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800018f6:	08c040ef          	jal	ra,80005982 <acquire>
  k = p->killed;
    800018fa:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800018fe:	8526                	mv	a0,s1
    80001900:	11a040ef          	jal	ra,80005a1a <release>
  return k;
}
    80001904:	854a                	mv	a0,s2
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6902                	ld	s2,0(sp)
    8000190e:	6105                	addi	sp,sp,32
    80001910:	8082                	ret

0000000080001912 <wait>:
{
    80001912:	715d                	addi	sp,sp,-80
    80001914:	e486                	sd	ra,72(sp)
    80001916:	e0a2                	sd	s0,64(sp)
    80001918:	fc26                	sd	s1,56(sp)
    8000191a:	f84a                	sd	s2,48(sp)
    8000191c:	f44e                	sd	s3,40(sp)
    8000191e:	f052                	sd	s4,32(sp)
    80001920:	ec56                	sd	s5,24(sp)
    80001922:	e85a                	sd	s6,16(sp)
    80001924:	e45e                	sd	s7,8(sp)
    80001926:	e062                	sd	s8,0(sp)
    80001928:	0880                	addi	s0,sp,80
    8000192a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000192c:	fb8ff0ef          	jal	ra,800010e4 <myproc>
    80001930:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001932:	00006517          	auipc	a0,0x6
    80001936:	3a650513          	addi	a0,a0,934 # 80007cd8 <wait_lock>
    8000193a:	048040ef          	jal	ra,80005982 <acquire>
    havekids = 0;
    8000193e:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001940:	4a15                	li	s4,5
        havekids = 1;
    80001942:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001944:	0000c997          	auipc	s3,0xc
    80001948:	1ac98993          	addi	s3,s3,428 # 8000daf0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000194c:	00006c17          	auipc	s8,0x6
    80001950:	38cc0c13          	addi	s8,s8,908 # 80007cd8 <wait_lock>
    havekids = 0;
    80001954:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001956:	00006497          	auipc	s1,0x6
    8000195a:	79a48493          	addi	s1,s1,1946 # 800080f0 <proc>
    8000195e:	a899                	j	800019b4 <wait+0xa2>
          pid = pp->pid;
    80001960:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001964:	000b0c63          	beqz	s6,8000197c <wait+0x6a>
    80001968:	4691                	li	a3,4
    8000196a:	02c48613          	addi	a2,s1,44
    8000196e:	85da                	mv	a1,s6
    80001970:	05093503          	ld	a0,80(s2)
    80001974:	b14ff0ef          	jal	ra,80000c88 <copyout>
    80001978:	00054f63          	bltz	a0,80001996 <wait+0x84>
          freeproc(pp);
    8000197c:	8526                	mv	a0,s1
    8000197e:	8d9ff0ef          	jal	ra,80001256 <freeproc>
          release(&pp->lock);
    80001982:	8526                	mv	a0,s1
    80001984:	096040ef          	jal	ra,80005a1a <release>
          release(&wait_lock);
    80001988:	00006517          	auipc	a0,0x6
    8000198c:	35050513          	addi	a0,a0,848 # 80007cd8 <wait_lock>
    80001990:	08a040ef          	jal	ra,80005a1a <release>
          return pid;
    80001994:	a891                	j	800019e8 <wait+0xd6>
            release(&pp->lock);
    80001996:	8526                	mv	a0,s1
    80001998:	082040ef          	jal	ra,80005a1a <release>
            release(&wait_lock);
    8000199c:	00006517          	auipc	a0,0x6
    800019a0:	33c50513          	addi	a0,a0,828 # 80007cd8 <wait_lock>
    800019a4:	076040ef          	jal	ra,80005a1a <release>
            return -1;
    800019a8:	59fd                	li	s3,-1
    800019aa:	a83d                	j	800019e8 <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800019ac:	16848493          	addi	s1,s1,360
    800019b0:	03348063          	beq	s1,s3,800019d0 <wait+0xbe>
      if(pp->parent == p){
    800019b4:	7c9c                	ld	a5,56(s1)
    800019b6:	ff279be3          	bne	a5,s2,800019ac <wait+0x9a>
        acquire(&pp->lock);
    800019ba:	8526                	mv	a0,s1
    800019bc:	7c7030ef          	jal	ra,80005982 <acquire>
        if(pp->state == ZOMBIE){
    800019c0:	4c9c                	lw	a5,24(s1)
    800019c2:	f9478fe3          	beq	a5,s4,80001960 <wait+0x4e>
        release(&pp->lock);
    800019c6:	8526                	mv	a0,s1
    800019c8:	052040ef          	jal	ra,80005a1a <release>
        havekids = 1;
    800019cc:	8756                	mv	a4,s5
    800019ce:	bff9                	j	800019ac <wait+0x9a>
    if(!havekids || killed(p)){
    800019d0:	c709                	beqz	a4,800019da <wait+0xc8>
    800019d2:	854a                	mv	a0,s2
    800019d4:	f15ff0ef          	jal	ra,800018e8 <killed>
    800019d8:	c50d                	beqz	a0,80001a02 <wait+0xf0>
      release(&wait_lock);
    800019da:	00006517          	auipc	a0,0x6
    800019de:	2fe50513          	addi	a0,a0,766 # 80007cd8 <wait_lock>
    800019e2:	038040ef          	jal	ra,80005a1a <release>
      return -1;
    800019e6:	59fd                	li	s3,-1
}
    800019e8:	854e                	mv	a0,s3
    800019ea:	60a6                	ld	ra,72(sp)
    800019ec:	6406                	ld	s0,64(sp)
    800019ee:	74e2                	ld	s1,56(sp)
    800019f0:	7942                	ld	s2,48(sp)
    800019f2:	79a2                	ld	s3,40(sp)
    800019f4:	7a02                	ld	s4,32(sp)
    800019f6:	6ae2                	ld	s5,24(sp)
    800019f8:	6b42                	ld	s6,16(sp)
    800019fa:	6ba2                	ld	s7,8(sp)
    800019fc:	6c02                	ld	s8,0(sp)
    800019fe:	6161                	addi	sp,sp,80
    80001a00:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001a02:	85e2                	mv	a1,s8
    80001a04:	854a                	mv	a0,s2
    80001a06:	cabff0ef          	jal	ra,800016b0 <sleep>
    havekids = 0;
    80001a0a:	b7a9                	j	80001954 <wait+0x42>

0000000080001a0c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001a0c:	7179                	addi	sp,sp,-48
    80001a0e:	f406                	sd	ra,40(sp)
    80001a10:	f022                	sd	s0,32(sp)
    80001a12:	ec26                	sd	s1,24(sp)
    80001a14:	e84a                	sd	s2,16(sp)
    80001a16:	e44e                	sd	s3,8(sp)
    80001a18:	e052                	sd	s4,0(sp)
    80001a1a:	1800                	addi	s0,sp,48
    80001a1c:	84aa                	mv	s1,a0
    80001a1e:	892e                	mv	s2,a1
    80001a20:	89b2                	mv	s3,a2
    80001a22:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001a24:	ec0ff0ef          	jal	ra,800010e4 <myproc>
  if(user_dst){
    80001a28:	cc99                	beqz	s1,80001a46 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80001a2a:	86d2                	mv	a3,s4
    80001a2c:	864e                	mv	a2,s3
    80001a2e:	85ca                	mv	a1,s2
    80001a30:	6928                	ld	a0,80(a0)
    80001a32:	a56ff0ef          	jal	ra,80000c88 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001a36:	70a2                	ld	ra,40(sp)
    80001a38:	7402                	ld	s0,32(sp)
    80001a3a:	64e2                	ld	s1,24(sp)
    80001a3c:	6942                	ld	s2,16(sp)
    80001a3e:	69a2                	ld	s3,8(sp)
    80001a40:	6a02                	ld	s4,0(sp)
    80001a42:	6145                	addi	sp,sp,48
    80001a44:	8082                	ret
    memmove((char *)dst, src, len);
    80001a46:	000a061b          	sext.w	a2,s4
    80001a4a:	85ce                	mv	a1,s3
    80001a4c:	854a                	mv	a0,s2
    80001a4e:	8c1fe0ef          	jal	ra,8000030e <memmove>
    return 0;
    80001a52:	8526                	mv	a0,s1
    80001a54:	b7cd                	j	80001a36 <either_copyout+0x2a>

0000000080001a56 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001a56:	7179                	addi	sp,sp,-48
    80001a58:	f406                	sd	ra,40(sp)
    80001a5a:	f022                	sd	s0,32(sp)
    80001a5c:	ec26                	sd	s1,24(sp)
    80001a5e:	e84a                	sd	s2,16(sp)
    80001a60:	e44e                	sd	s3,8(sp)
    80001a62:	e052                	sd	s4,0(sp)
    80001a64:	1800                	addi	s0,sp,48
    80001a66:	892a                	mv	s2,a0
    80001a68:	84ae                	mv	s1,a1
    80001a6a:	89b2                	mv	s3,a2
    80001a6c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001a6e:	e76ff0ef          	jal	ra,800010e4 <myproc>
  if(user_src){
    80001a72:	cc99                	beqz	s1,80001a90 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80001a74:	86d2                	mv	a3,s4
    80001a76:	864e                	mv	a2,s3
    80001a78:	85ca                	mv	a1,s2
    80001a7a:	6928                	ld	a0,80(a0)
    80001a7c:	ac4ff0ef          	jal	ra,80000d40 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001a80:	70a2                	ld	ra,40(sp)
    80001a82:	7402                	ld	s0,32(sp)
    80001a84:	64e2                	ld	s1,24(sp)
    80001a86:	6942                	ld	s2,16(sp)
    80001a88:	69a2                	ld	s3,8(sp)
    80001a8a:	6a02                	ld	s4,0(sp)
    80001a8c:	6145                	addi	sp,sp,48
    80001a8e:	8082                	ret
    memmove(dst, (char*)src, len);
    80001a90:	000a061b          	sext.w	a2,s4
    80001a94:	85ce                	mv	a1,s3
    80001a96:	854a                	mv	a0,s2
    80001a98:	877fe0ef          	jal	ra,8000030e <memmove>
    return 0;
    80001a9c:	8526                	mv	a0,s1
    80001a9e:	b7cd                	j	80001a80 <either_copyin+0x2a>

0000000080001aa0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001aa0:	715d                	addi	sp,sp,-80
    80001aa2:	e486                	sd	ra,72(sp)
    80001aa4:	e0a2                	sd	s0,64(sp)
    80001aa6:	fc26                	sd	s1,56(sp)
    80001aa8:	f84a                	sd	s2,48(sp)
    80001aaa:	f44e                	sd	s3,40(sp)
    80001aac:	f052                	sd	s4,32(sp)
    80001aae:	ec56                	sd	s5,24(sp)
    80001ab0:	e85a                	sd	s6,16(sp)
    80001ab2:	e45e                	sd	s7,8(sp)
    80001ab4:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001ab6:	00005517          	auipc	a0,0x5
    80001aba:	61a50513          	addi	a0,a0,1562 # 800070d0 <etext+0xd0>
    80001abe:	101030ef          	jal	ra,800053be <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001ac2:	00006497          	auipc	s1,0x6
    80001ac6:	78648493          	addi	s1,s1,1926 # 80008248 <proc+0x158>
    80001aca:	0000c917          	auipc	s2,0xc
    80001ace:	17e90913          	addi	s2,s2,382 # 8000dc48 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001ad2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001ad4:	00006997          	auipc	s3,0x6
    80001ad8:	88498993          	addi	s3,s3,-1916 # 80007358 <etext+0x358>
    printf("%d %s %s", p->pid, state, p->name);
    80001adc:	00006a97          	auipc	s5,0x6
    80001ae0:	884a8a93          	addi	s5,s5,-1916 # 80007360 <etext+0x360>
    printf("\n");
    80001ae4:	00005a17          	auipc	s4,0x5
    80001ae8:	5eca0a13          	addi	s4,s4,1516 # 800070d0 <etext+0xd0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001aec:	00006b97          	auipc	s7,0x6
    80001af0:	8b4b8b93          	addi	s7,s7,-1868 # 800073a0 <states.0>
    80001af4:	a829                	j	80001b0e <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80001af6:	ed86a583          	lw	a1,-296(a3)
    80001afa:	8556                	mv	a0,s5
    80001afc:	0c3030ef          	jal	ra,800053be <printf>
    printf("\n");
    80001b00:	8552                	mv	a0,s4
    80001b02:	0bd030ef          	jal	ra,800053be <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001b06:	16848493          	addi	s1,s1,360
    80001b0a:	03248263          	beq	s1,s2,80001b2e <procdump+0x8e>
    if(p->state == UNUSED)
    80001b0e:	86a6                	mv	a3,s1
    80001b10:	ec04a783          	lw	a5,-320(s1)
    80001b14:	dbed                	beqz	a5,80001b06 <procdump+0x66>
      state = "???";
    80001b16:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001b18:	fcfb6fe3          	bltu	s6,a5,80001af6 <procdump+0x56>
    80001b1c:	02079713          	slli	a4,a5,0x20
    80001b20:	01d75793          	srli	a5,a4,0x1d
    80001b24:	97de                	add	a5,a5,s7
    80001b26:	6390                	ld	a2,0(a5)
    80001b28:	f679                	bnez	a2,80001af6 <procdump+0x56>
      state = "???";
    80001b2a:	864e                	mv	a2,s3
    80001b2c:	b7e9                	j	80001af6 <procdump+0x56>
  }
}
    80001b2e:	60a6                	ld	ra,72(sp)
    80001b30:	6406                	ld	s0,64(sp)
    80001b32:	74e2                	ld	s1,56(sp)
    80001b34:	7942                	ld	s2,48(sp)
    80001b36:	79a2                	ld	s3,40(sp)
    80001b38:	7a02                	ld	s4,32(sp)
    80001b3a:	6ae2                	ld	s5,24(sp)
    80001b3c:	6b42                	ld	s6,16(sp)
    80001b3e:	6ba2                	ld	s7,8(sp)
    80001b40:	6161                	addi	sp,sp,80
    80001b42:	8082                	ret

0000000080001b44 <swtch>:
    80001b44:	00153023          	sd	ra,0(a0)
    80001b48:	00253423          	sd	sp,8(a0)
    80001b4c:	e900                	sd	s0,16(a0)
    80001b4e:	ed04                	sd	s1,24(a0)
    80001b50:	03253023          	sd	s2,32(a0)
    80001b54:	03353423          	sd	s3,40(a0)
    80001b58:	03453823          	sd	s4,48(a0)
    80001b5c:	03553c23          	sd	s5,56(a0)
    80001b60:	05653023          	sd	s6,64(a0)
    80001b64:	05753423          	sd	s7,72(a0)
    80001b68:	05853823          	sd	s8,80(a0)
    80001b6c:	05953c23          	sd	s9,88(a0)
    80001b70:	07a53023          	sd	s10,96(a0)
    80001b74:	07b53423          	sd	s11,104(a0)
    80001b78:	0005b083          	ld	ra,0(a1)
    80001b7c:	0085b103          	ld	sp,8(a1)
    80001b80:	6980                	ld	s0,16(a1)
    80001b82:	6d84                	ld	s1,24(a1)
    80001b84:	0205b903          	ld	s2,32(a1)
    80001b88:	0285b983          	ld	s3,40(a1)
    80001b8c:	0305ba03          	ld	s4,48(a1)
    80001b90:	0385ba83          	ld	s5,56(a1)
    80001b94:	0405bb03          	ld	s6,64(a1)
    80001b98:	0485bb83          	ld	s7,72(a1)
    80001b9c:	0505bc03          	ld	s8,80(a1)
    80001ba0:	0585bc83          	ld	s9,88(a1)
    80001ba4:	0605bd03          	ld	s10,96(a1)
    80001ba8:	0685bd83          	ld	s11,104(a1)
    80001bac:	8082                	ret

0000000080001bae <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001bae:	1141                	addi	sp,sp,-16
    80001bb0:	e406                	sd	ra,8(sp)
    80001bb2:	e022                	sd	s0,0(sp)
    80001bb4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001bb6:	00006597          	auipc	a1,0x6
    80001bba:	81a58593          	addi	a1,a1,-2022 # 800073d0 <states.0+0x30>
    80001bbe:	0000c517          	auipc	a0,0xc
    80001bc2:	f3250513          	addi	a0,a0,-206 # 8000daf0 <tickslock>
    80001bc6:	53d030ef          	jal	ra,80005902 <initlock>
}
    80001bca:	60a2                	ld	ra,8(sp)
    80001bcc:	6402                	ld	s0,0(sp)
    80001bce:	0141                	addi	sp,sp,16
    80001bd0:	8082                	ret

0000000080001bd2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001bd2:	1141                	addi	sp,sp,-16
    80001bd4:	e422                	sd	s0,8(sp)
    80001bd6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001bd8:	00003797          	auipc	a5,0x3
    80001bdc:	d8878793          	addi	a5,a5,-632 # 80004960 <kernelvec>
    80001be0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001be4:	6422                	ld	s0,8(sp)
    80001be6:	0141                	addi	sp,sp,16
    80001be8:	8082                	ret

0000000080001bea <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001bea:	1141                	addi	sp,sp,-16
    80001bec:	e406                	sd	ra,8(sp)
    80001bee:	e022                	sd	s0,0(sp)
    80001bf0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001bf2:	cf2ff0ef          	jal	ra,800010e4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001bf6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001bfa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001bfc:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001c00:	00004697          	auipc	a3,0x4
    80001c04:	40068693          	addi	a3,a3,1024 # 80006000 <_trampoline>
    80001c08:	00004717          	auipc	a4,0x4
    80001c0c:	3f870713          	addi	a4,a4,1016 # 80006000 <_trampoline>
    80001c10:	8f15                	sub	a4,a4,a3
    80001c12:	040007b7          	lui	a5,0x4000
    80001c16:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001c18:	07b2                	slli	a5,a5,0xc
    80001c1a:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001c1c:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001c20:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001c22:	18002673          	csrr	a2,satp
    80001c26:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001c28:	6d30                	ld	a2,88(a0)
    80001c2a:	6138                	ld	a4,64(a0)
    80001c2c:	6585                	lui	a1,0x1
    80001c2e:	972e                	add	a4,a4,a1
    80001c30:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001c32:	6d38                	ld	a4,88(a0)
    80001c34:	00000617          	auipc	a2,0x0
    80001c38:	10c60613          	addi	a2,a2,268 # 80001d40 <usertrap>
    80001c3c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001c3e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c40:	8612                	mv	a2,tp
    80001c42:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c44:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001c48:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001c4c:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c50:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001c54:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001c56:	6f18                	ld	a4,24(a4)
    80001c58:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001c5c:	6928                	ld	a0,80(a0)
    80001c5e:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001c60:	00004717          	auipc	a4,0x4
    80001c64:	43c70713          	addi	a4,a4,1084 # 8000609c <userret>
    80001c68:	8f15                	sub	a4,a4,a3
    80001c6a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001c6c:	577d                	li	a4,-1
    80001c6e:	177e                	slli	a4,a4,0x3f
    80001c70:	8d59                	or	a0,a0,a4
    80001c72:	9782                	jalr	a5
}
    80001c74:	60a2                	ld	ra,8(sp)
    80001c76:	6402                	ld	s0,0(sp)
    80001c78:	0141                	addi	sp,sp,16
    80001c7a:	8082                	ret

0000000080001c7c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001c7c:	1101                	addi	sp,sp,-32
    80001c7e:	ec06                	sd	ra,24(sp)
    80001c80:	e822                	sd	s0,16(sp)
    80001c82:	e426                	sd	s1,8(sp)
    80001c84:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001c86:	c32ff0ef          	jal	ra,800010b8 <cpuid>
    80001c8a:	cd19                	beqz	a0,80001ca8 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001c8c:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001c90:	000f4737          	lui	a4,0xf4
    80001c94:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001c98:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001c9a:	14d79073          	csrw	0x14d,a5
}
    80001c9e:	60e2                	ld	ra,24(sp)
    80001ca0:	6442                	ld	s0,16(sp)
    80001ca2:	64a2                	ld	s1,8(sp)
    80001ca4:	6105                	addi	sp,sp,32
    80001ca6:	8082                	ret
    acquire(&tickslock);
    80001ca8:	0000c497          	auipc	s1,0xc
    80001cac:	e4848493          	addi	s1,s1,-440 # 8000daf0 <tickslock>
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	4d1030ef          	jal	ra,80005982 <acquire>
    ticks++;
    80001cb6:	00006517          	auipc	a0,0x6
    80001cba:	dd250513          	addi	a0,a0,-558 # 80007a88 <ticks>
    80001cbe:	411c                	lw	a5,0(a0)
    80001cc0:	2785                	addiw	a5,a5,1
    80001cc2:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001cc4:	a39ff0ef          	jal	ra,800016fc <wakeup>
    release(&tickslock);
    80001cc8:	8526                	mv	a0,s1
    80001cca:	551030ef          	jal	ra,80005a1a <release>
    80001cce:	bf7d                	j	80001c8c <clockintr+0x10>

0000000080001cd0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001cd0:	1101                	addi	sp,sp,-32
    80001cd2:	ec06                	sd	ra,24(sp)
    80001cd4:	e822                	sd	s0,16(sp)
    80001cd6:	e426                	sd	s1,8(sp)
    80001cd8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001cda:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001cde:	57fd                	li	a5,-1
    80001ce0:	17fe                	slli	a5,a5,0x3f
    80001ce2:	07a5                	addi	a5,a5,9
    80001ce4:	00f70d63          	beq	a4,a5,80001cfe <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001ce8:	57fd                	li	a5,-1
    80001cea:	17fe                	slli	a5,a5,0x3f
    80001cec:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001cee:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001cf0:	04f70463          	beq	a4,a5,80001d38 <devintr+0x68>
  }
}
    80001cf4:	60e2                	ld	ra,24(sp)
    80001cf6:	6442                	ld	s0,16(sp)
    80001cf8:	64a2                	ld	s1,8(sp)
    80001cfa:	6105                	addi	sp,sp,32
    80001cfc:	8082                	ret
    int irq = plic_claim();
    80001cfe:	50b020ef          	jal	ra,80004a08 <plic_claim>
    80001d02:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001d04:	47a9                	li	a5,10
    80001d06:	02f50363          	beq	a0,a5,80001d2c <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80001d0a:	4785                	li	a5,1
    80001d0c:	02f50363          	beq	a0,a5,80001d32 <devintr+0x62>
    return 1;
    80001d10:	4505                	li	a0,1
    } else if(irq){
    80001d12:	d0ed                	beqz	s1,80001cf4 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80001d14:	85a6                	mv	a1,s1
    80001d16:	00005517          	auipc	a0,0x5
    80001d1a:	6c250513          	addi	a0,a0,1730 # 800073d8 <states.0+0x38>
    80001d1e:	6a0030ef          	jal	ra,800053be <printf>
      plic_complete(irq);
    80001d22:	8526                	mv	a0,s1
    80001d24:	505020ef          	jal	ra,80004a28 <plic_complete>
    return 1;
    80001d28:	4505                	li	a0,1
    80001d2a:	b7e9                	j	80001cf4 <devintr+0x24>
      uartintr();
    80001d2c:	39b030ef          	jal	ra,800058c6 <uartintr>
    80001d30:	bfcd                	j	80001d22 <devintr+0x52>
      virtio_disk_intr();
    80001d32:	162030ef          	jal	ra,80004e94 <virtio_disk_intr>
    80001d36:	b7f5                	j	80001d22 <devintr+0x52>
    clockintr();
    80001d38:	f45ff0ef          	jal	ra,80001c7c <clockintr>
    return 2;
    80001d3c:	4509                	li	a0,2
    80001d3e:	bf5d                	j	80001cf4 <devintr+0x24>

0000000080001d40 <usertrap>:
{
    80001d40:	1101                	addi	sp,sp,-32
    80001d42:	ec06                	sd	ra,24(sp)
    80001d44:	e822                	sd	s0,16(sp)
    80001d46:	e426                	sd	s1,8(sp)
    80001d48:	e04a                	sd	s2,0(sp)
    80001d4a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d4c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001d50:	1007f793          	andi	a5,a5,256
    80001d54:	ef85                	bnez	a5,80001d8c <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001d56:	00003797          	auipc	a5,0x3
    80001d5a:	c0a78793          	addi	a5,a5,-1014 # 80004960 <kernelvec>
    80001d5e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001d62:	b82ff0ef          	jal	ra,800010e4 <myproc>
    80001d66:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001d68:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d6a:	14102773          	csrr	a4,sepc
    80001d6e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d70:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001d74:	47a1                	li	a5,8
    80001d76:	02f70163          	beq	a4,a5,80001d98 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001d7a:	f57ff0ef          	jal	ra,80001cd0 <devintr>
    80001d7e:	892a                	mv	s2,a0
    80001d80:	c135                	beqz	a0,80001de4 <usertrap+0xa4>
  if(killed(p))
    80001d82:	8526                	mv	a0,s1
    80001d84:	b65ff0ef          	jal	ra,800018e8 <killed>
    80001d88:	cd1d                	beqz	a0,80001dc6 <usertrap+0x86>
    80001d8a:	a81d                	j	80001dc0 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001d8c:	00005517          	auipc	a0,0x5
    80001d90:	66c50513          	addi	a0,a0,1644 # 800073f8 <states.0+0x58>
    80001d94:	0df030ef          	jal	ra,80005672 <panic>
    if(killed(p))
    80001d98:	b51ff0ef          	jal	ra,800018e8 <killed>
    80001d9c:	e121                	bnez	a0,80001ddc <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001d9e:	6cb8                	ld	a4,88(s1)
    80001da0:	6f1c                	ld	a5,24(a4)
    80001da2:	0791                	addi	a5,a5,4
    80001da4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001da6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001daa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dae:	10079073          	csrw	sstatus,a5
    syscall();
    80001db2:	248000ef          	jal	ra,80001ffa <syscall>
  if(killed(p))
    80001db6:	8526                	mv	a0,s1
    80001db8:	b31ff0ef          	jal	ra,800018e8 <killed>
    80001dbc:	c901                	beqz	a0,80001dcc <usertrap+0x8c>
    80001dbe:	4901                	li	s2,0
    exit(-1);
    80001dc0:	557d                	li	a0,-1
    80001dc2:	9fbff0ef          	jal	ra,800017bc <exit>
  if(which_dev == 2)
    80001dc6:	4789                	li	a5,2
    80001dc8:	04f90563          	beq	s2,a5,80001e12 <usertrap+0xd2>
  usertrapret();
    80001dcc:	e1fff0ef          	jal	ra,80001bea <usertrapret>
}
    80001dd0:	60e2                	ld	ra,24(sp)
    80001dd2:	6442                	ld	s0,16(sp)
    80001dd4:	64a2                	ld	s1,8(sp)
    80001dd6:	6902                	ld	s2,0(sp)
    80001dd8:	6105                	addi	sp,sp,32
    80001dda:	8082                	ret
      exit(-1);
    80001ddc:	557d                	li	a0,-1
    80001dde:	9dfff0ef          	jal	ra,800017bc <exit>
    80001de2:	bf75                	j	80001d9e <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001de4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001de8:	5890                	lw	a2,48(s1)
    80001dea:	00005517          	auipc	a0,0x5
    80001dee:	62e50513          	addi	a0,a0,1582 # 80007418 <states.0+0x78>
    80001df2:	5cc030ef          	jal	ra,800053be <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001df6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001dfa:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001dfe:	00005517          	auipc	a0,0x5
    80001e02:	64a50513          	addi	a0,a0,1610 # 80007448 <states.0+0xa8>
    80001e06:	5b8030ef          	jal	ra,800053be <printf>
    setkilled(p);
    80001e0a:	8526                	mv	a0,s1
    80001e0c:	ab9ff0ef          	jal	ra,800018c4 <setkilled>
    80001e10:	b75d                	j	80001db6 <usertrap+0x76>
    yield();
    80001e12:	873ff0ef          	jal	ra,80001684 <yield>
    80001e16:	bf5d                	j	80001dcc <usertrap+0x8c>

0000000080001e18 <kerneltrap>:
{
    80001e18:	7179                	addi	sp,sp,-48
    80001e1a:	f406                	sd	ra,40(sp)
    80001e1c:	f022                	sd	s0,32(sp)
    80001e1e:	ec26                	sd	s1,24(sp)
    80001e20:	e84a                	sd	s2,16(sp)
    80001e22:	e44e                	sd	s3,8(sp)
    80001e24:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e26:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e2a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e2e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001e32:	1004f793          	andi	a5,s1,256
    80001e36:	c795                	beqz	a5,80001e62 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e38:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e3c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001e3e:	eb85                	bnez	a5,80001e6e <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001e40:	e91ff0ef          	jal	ra,80001cd0 <devintr>
    80001e44:	c91d                	beqz	a0,80001e7a <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001e46:	4789                	li	a5,2
    80001e48:	04f50a63          	beq	a0,a5,80001e9c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001e4c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e50:	10049073          	csrw	sstatus,s1
}
    80001e54:	70a2                	ld	ra,40(sp)
    80001e56:	7402                	ld	s0,32(sp)
    80001e58:	64e2                	ld	s1,24(sp)
    80001e5a:	6942                	ld	s2,16(sp)
    80001e5c:	69a2                	ld	s3,8(sp)
    80001e5e:	6145                	addi	sp,sp,48
    80001e60:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001e62:	00005517          	auipc	a0,0x5
    80001e66:	60e50513          	addi	a0,a0,1550 # 80007470 <states.0+0xd0>
    80001e6a:	009030ef          	jal	ra,80005672 <panic>
    panic("kerneltrap: interrupts enabled");
    80001e6e:	00005517          	auipc	a0,0x5
    80001e72:	62a50513          	addi	a0,a0,1578 # 80007498 <states.0+0xf8>
    80001e76:	7fc030ef          	jal	ra,80005672 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e7a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e7e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001e82:	85ce                	mv	a1,s3
    80001e84:	00005517          	auipc	a0,0x5
    80001e88:	63450513          	addi	a0,a0,1588 # 800074b8 <states.0+0x118>
    80001e8c:	532030ef          	jal	ra,800053be <printf>
    panic("kerneltrap");
    80001e90:	00005517          	auipc	a0,0x5
    80001e94:	65050513          	addi	a0,a0,1616 # 800074e0 <states.0+0x140>
    80001e98:	7da030ef          	jal	ra,80005672 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001e9c:	a48ff0ef          	jal	ra,800010e4 <myproc>
    80001ea0:	d555                	beqz	a0,80001e4c <kerneltrap+0x34>
    yield();
    80001ea2:	fe2ff0ef          	jal	ra,80001684 <yield>
    80001ea6:	b75d                	j	80001e4c <kerneltrap+0x34>

0000000080001ea8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001ea8:	1101                	addi	sp,sp,-32
    80001eaa:	ec06                	sd	ra,24(sp)
    80001eac:	e822                	sd	s0,16(sp)
    80001eae:	e426                	sd	s1,8(sp)
    80001eb0:	1000                	addi	s0,sp,32
    80001eb2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001eb4:	a30ff0ef          	jal	ra,800010e4 <myproc>
  switch (n) {
    80001eb8:	4795                	li	a5,5
    80001eba:	0497e163          	bltu	a5,s1,80001efc <argraw+0x54>
    80001ebe:	048a                	slli	s1,s1,0x2
    80001ec0:	00005717          	auipc	a4,0x5
    80001ec4:	65870713          	addi	a4,a4,1624 # 80007518 <states.0+0x178>
    80001ec8:	94ba                	add	s1,s1,a4
    80001eca:	409c                	lw	a5,0(s1)
    80001ecc:	97ba                	add	a5,a5,a4
    80001ece:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001ed0:	6d3c                	ld	a5,88(a0)
    80001ed2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001ed4:	60e2                	ld	ra,24(sp)
    80001ed6:	6442                	ld	s0,16(sp)
    80001ed8:	64a2                	ld	s1,8(sp)
    80001eda:	6105                	addi	sp,sp,32
    80001edc:	8082                	ret
    return p->trapframe->a1;
    80001ede:	6d3c                	ld	a5,88(a0)
    80001ee0:	7fa8                	ld	a0,120(a5)
    80001ee2:	bfcd                	j	80001ed4 <argraw+0x2c>
    return p->trapframe->a2;
    80001ee4:	6d3c                	ld	a5,88(a0)
    80001ee6:	63c8                	ld	a0,128(a5)
    80001ee8:	b7f5                	j	80001ed4 <argraw+0x2c>
    return p->trapframe->a3;
    80001eea:	6d3c                	ld	a5,88(a0)
    80001eec:	67c8                	ld	a0,136(a5)
    80001eee:	b7dd                	j	80001ed4 <argraw+0x2c>
    return p->trapframe->a4;
    80001ef0:	6d3c                	ld	a5,88(a0)
    80001ef2:	6bc8                	ld	a0,144(a5)
    80001ef4:	b7c5                	j	80001ed4 <argraw+0x2c>
    return p->trapframe->a5;
    80001ef6:	6d3c                	ld	a5,88(a0)
    80001ef8:	6fc8                	ld	a0,152(a5)
    80001efa:	bfe9                	j	80001ed4 <argraw+0x2c>
  panic("argraw");
    80001efc:	00005517          	auipc	a0,0x5
    80001f00:	5f450513          	addi	a0,a0,1524 # 800074f0 <states.0+0x150>
    80001f04:	76e030ef          	jal	ra,80005672 <panic>

0000000080001f08 <fetchaddr>:
{
    80001f08:	1101                	addi	sp,sp,-32
    80001f0a:	ec06                	sd	ra,24(sp)
    80001f0c:	e822                	sd	s0,16(sp)
    80001f0e:	e426                	sd	s1,8(sp)
    80001f10:	e04a                	sd	s2,0(sp)
    80001f12:	1000                	addi	s0,sp,32
    80001f14:	84aa                	mv	s1,a0
    80001f16:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f18:	9ccff0ef          	jal	ra,800010e4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001f1c:	653c                	ld	a5,72(a0)
    80001f1e:	02f4f663          	bgeu	s1,a5,80001f4a <fetchaddr+0x42>
    80001f22:	00848713          	addi	a4,s1,8
    80001f26:	02e7e463          	bltu	a5,a4,80001f4e <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001f2a:	46a1                	li	a3,8
    80001f2c:	8626                	mv	a2,s1
    80001f2e:	85ca                	mv	a1,s2
    80001f30:	6928                	ld	a0,80(a0)
    80001f32:	e0ffe0ef          	jal	ra,80000d40 <copyin>
    80001f36:	00a03533          	snez	a0,a0
    80001f3a:	40a00533          	neg	a0,a0
}
    80001f3e:	60e2                	ld	ra,24(sp)
    80001f40:	6442                	ld	s0,16(sp)
    80001f42:	64a2                	ld	s1,8(sp)
    80001f44:	6902                	ld	s2,0(sp)
    80001f46:	6105                	addi	sp,sp,32
    80001f48:	8082                	ret
    return -1;
    80001f4a:	557d                	li	a0,-1
    80001f4c:	bfcd                	j	80001f3e <fetchaddr+0x36>
    80001f4e:	557d                	li	a0,-1
    80001f50:	b7fd                	j	80001f3e <fetchaddr+0x36>

0000000080001f52 <fetchstr>:
{
    80001f52:	7179                	addi	sp,sp,-48
    80001f54:	f406                	sd	ra,40(sp)
    80001f56:	f022                	sd	s0,32(sp)
    80001f58:	ec26                	sd	s1,24(sp)
    80001f5a:	e84a                	sd	s2,16(sp)
    80001f5c:	e44e                	sd	s3,8(sp)
    80001f5e:	1800                	addi	s0,sp,48
    80001f60:	892a                	mv	s2,a0
    80001f62:	84ae                	mv	s1,a1
    80001f64:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001f66:	97eff0ef          	jal	ra,800010e4 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001f6a:	86ce                	mv	a3,s3
    80001f6c:	864a                	mv	a2,s2
    80001f6e:	85a6                	mv	a1,s1
    80001f70:	6928                	ld	a0,80(a0)
    80001f72:	e55fe0ef          	jal	ra,80000dc6 <copyinstr>
    80001f76:	00054c63          	bltz	a0,80001f8e <fetchstr+0x3c>
  return strlen(buf);
    80001f7a:	8526                	mv	a0,s1
    80001f7c:	caefe0ef          	jal	ra,8000042a <strlen>
}
    80001f80:	70a2                	ld	ra,40(sp)
    80001f82:	7402                	ld	s0,32(sp)
    80001f84:	64e2                	ld	s1,24(sp)
    80001f86:	6942                	ld	s2,16(sp)
    80001f88:	69a2                	ld	s3,8(sp)
    80001f8a:	6145                	addi	sp,sp,48
    80001f8c:	8082                	ret
    return -1;
    80001f8e:	557d                	li	a0,-1
    80001f90:	bfc5                	j	80001f80 <fetchstr+0x2e>

0000000080001f92 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001f92:	1101                	addi	sp,sp,-32
    80001f94:	ec06                	sd	ra,24(sp)
    80001f96:	e822                	sd	s0,16(sp)
    80001f98:	e426                	sd	s1,8(sp)
    80001f9a:	1000                	addi	s0,sp,32
    80001f9c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001f9e:	f0bff0ef          	jal	ra,80001ea8 <argraw>
    80001fa2:	c088                	sw	a0,0(s1)
}
    80001fa4:	60e2                	ld	ra,24(sp)
    80001fa6:	6442                	ld	s0,16(sp)
    80001fa8:	64a2                	ld	s1,8(sp)
    80001faa:	6105                	addi	sp,sp,32
    80001fac:	8082                	ret

0000000080001fae <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001fae:	1101                	addi	sp,sp,-32
    80001fb0:	ec06                	sd	ra,24(sp)
    80001fb2:	e822                	sd	s0,16(sp)
    80001fb4:	e426                	sd	s1,8(sp)
    80001fb6:	1000                	addi	s0,sp,32
    80001fb8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001fba:	eefff0ef          	jal	ra,80001ea8 <argraw>
    80001fbe:	e088                	sd	a0,0(s1)
}
    80001fc0:	60e2                	ld	ra,24(sp)
    80001fc2:	6442                	ld	s0,16(sp)
    80001fc4:	64a2                	ld	s1,8(sp)
    80001fc6:	6105                	addi	sp,sp,32
    80001fc8:	8082                	ret

0000000080001fca <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001fca:	7179                	addi	sp,sp,-48
    80001fcc:	f406                	sd	ra,40(sp)
    80001fce:	f022                	sd	s0,32(sp)
    80001fd0:	ec26                	sd	s1,24(sp)
    80001fd2:	e84a                	sd	s2,16(sp)
    80001fd4:	1800                	addi	s0,sp,48
    80001fd6:	84ae                	mv	s1,a1
    80001fd8:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001fda:	fd840593          	addi	a1,s0,-40
    80001fde:	fd1ff0ef          	jal	ra,80001fae <argaddr>
  return fetchstr(addr, buf, max);
    80001fe2:	864a                	mv	a2,s2
    80001fe4:	85a6                	mv	a1,s1
    80001fe6:	fd843503          	ld	a0,-40(s0)
    80001fea:	f69ff0ef          	jal	ra,80001f52 <fetchstr>
}
    80001fee:	70a2                	ld	ra,40(sp)
    80001ff0:	7402                	ld	s0,32(sp)
    80001ff2:	64e2                	ld	s1,24(sp)
    80001ff4:	6942                	ld	s2,16(sp)
    80001ff6:	6145                	addi	sp,sp,48
    80001ff8:	8082                	ret

0000000080001ffa <syscall>:
#endif
};

void
syscall(void)
{
    80001ffa:	1101                	addi	sp,sp,-32
    80001ffc:	ec06                	sd	ra,24(sp)
    80001ffe:	e822                	sd	s0,16(sp)
    80002000:	e426                	sd	s1,8(sp)
    80002002:	e04a                	sd	s2,0(sp)
    80002004:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002006:	8deff0ef          	jal	ra,800010e4 <myproc>
    8000200a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000200c:	05853903          	ld	s2,88(a0)
    80002010:	0a893783          	ld	a5,168(s2)
    80002014:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002018:	37fd                	addiw	a5,a5,-1
    8000201a:	02100713          	li	a4,33
    8000201e:	00f76f63          	bltu	a4,a5,8000203c <syscall+0x42>
    80002022:	00369713          	slli	a4,a3,0x3
    80002026:	00005797          	auipc	a5,0x5
    8000202a:	50a78793          	addi	a5,a5,1290 # 80007530 <syscalls>
    8000202e:	97ba                	add	a5,a5,a4
    80002030:	639c                	ld	a5,0(a5)
    80002032:	c789                	beqz	a5,8000203c <syscall+0x42>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002034:	9782                	jalr	a5
    80002036:	06a93823          	sd	a0,112(s2)
    8000203a:	a829                	j	80002054 <syscall+0x5a>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000203c:	15848613          	addi	a2,s1,344
    80002040:	588c                	lw	a1,48(s1)
    80002042:	00005517          	auipc	a0,0x5
    80002046:	4b650513          	addi	a0,a0,1206 # 800074f8 <states.0+0x158>
    8000204a:	374030ef          	jal	ra,800053be <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000204e:	6cbc                	ld	a5,88(s1)
    80002050:	577d                	li	a4,-1
    80002052:	fbb8                	sd	a4,112(a5)
  }
}
    80002054:	60e2                	ld	ra,24(sp)
    80002056:	6442                	ld	s0,16(sp)
    80002058:	64a2                	ld	s1,8(sp)
    8000205a:	6902                	ld	s2,0(sp)
    8000205c:	6105                	addi	sp,sp,32
    8000205e:	8082                	ret

0000000080002060 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002060:	1101                	addi	sp,sp,-32
    80002062:	ec06                	sd	ra,24(sp)
    80002064:	e822                	sd	s0,16(sp)
    80002066:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002068:	fec40593          	addi	a1,s0,-20
    8000206c:	4501                	li	a0,0
    8000206e:	f25ff0ef          	jal	ra,80001f92 <argint>
  exit(n);
    80002072:	fec42503          	lw	a0,-20(s0)
    80002076:	f46ff0ef          	jal	ra,800017bc <exit>
  return 0;  // not reached
}
    8000207a:	4501                	li	a0,0
    8000207c:	60e2                	ld	ra,24(sp)
    8000207e:	6442                	ld	s0,16(sp)
    80002080:	6105                	addi	sp,sp,32
    80002082:	8082                	ret

0000000080002084 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002084:	1141                	addi	sp,sp,-16
    80002086:	e406                	sd	ra,8(sp)
    80002088:	e022                	sd	s0,0(sp)
    8000208a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000208c:	858ff0ef          	jal	ra,800010e4 <myproc>
}
    80002090:	5908                	lw	a0,48(a0)
    80002092:	60a2                	ld	ra,8(sp)
    80002094:	6402                	ld	s0,0(sp)
    80002096:	0141                	addi	sp,sp,16
    80002098:	8082                	ret

000000008000209a <sys_fork>:

uint64
sys_fork(void)
{
    8000209a:	1141                	addi	sp,sp,-16
    8000209c:	e406                	sd	ra,8(sp)
    8000209e:	e022                	sd	s0,0(sp)
    800020a0:	0800                	addi	s0,sp,16
  return fork();
    800020a2:	b68ff0ef          	jal	ra,8000140a <fork>
}
    800020a6:	60a2                	ld	ra,8(sp)
    800020a8:	6402                	ld	s0,0(sp)
    800020aa:	0141                	addi	sp,sp,16
    800020ac:	8082                	ret

00000000800020ae <sys_wait>:

uint64
sys_wait(void)
{
    800020ae:	1101                	addi	sp,sp,-32
    800020b0:	ec06                	sd	ra,24(sp)
    800020b2:	e822                	sd	s0,16(sp)
    800020b4:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800020b6:	fe840593          	addi	a1,s0,-24
    800020ba:	4501                	li	a0,0
    800020bc:	ef3ff0ef          	jal	ra,80001fae <argaddr>
  return wait(p);
    800020c0:	fe843503          	ld	a0,-24(s0)
    800020c4:	84fff0ef          	jal	ra,80001912 <wait>
}
    800020c8:	60e2                	ld	ra,24(sp)
    800020ca:	6442                	ld	s0,16(sp)
    800020cc:	6105                	addi	sp,sp,32
    800020ce:	8082                	ret

00000000800020d0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800020d0:	7179                	addi	sp,sp,-48
    800020d2:	f406                	sd	ra,40(sp)
    800020d4:	f022                	sd	s0,32(sp)
    800020d6:	ec26                	sd	s1,24(sp)
    800020d8:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800020da:	fdc40593          	addi	a1,s0,-36
    800020de:	4501                	li	a0,0
    800020e0:	eb3ff0ef          	jal	ra,80001f92 <argint>
  addr = myproc()->sz;
    800020e4:	800ff0ef          	jal	ra,800010e4 <myproc>
    800020e8:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800020ea:	fdc42503          	lw	a0,-36(s0)
    800020ee:	accff0ef          	jal	ra,800013ba <growproc>
    800020f2:	00054863          	bltz	a0,80002102 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    800020f6:	8526                	mv	a0,s1
    800020f8:	70a2                	ld	ra,40(sp)
    800020fa:	7402                	ld	s0,32(sp)
    800020fc:	64e2                	ld	s1,24(sp)
    800020fe:	6145                	addi	sp,sp,48
    80002100:	8082                	ret
    return -1;
    80002102:	54fd                	li	s1,-1
    80002104:	bfcd                	j	800020f6 <sys_sbrk+0x26>

0000000080002106 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002106:	7139                	addi	sp,sp,-64
    80002108:	fc06                	sd	ra,56(sp)
    8000210a:	f822                	sd	s0,48(sp)
    8000210c:	f426                	sd	s1,40(sp)
    8000210e:	f04a                	sd	s2,32(sp)
    80002110:	ec4e                	sd	s3,24(sp)
    80002112:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002114:	fcc40593          	addi	a1,s0,-52
    80002118:	4501                	li	a0,0
    8000211a:	e79ff0ef          	jal	ra,80001f92 <argint>
  if(n < 0)
    8000211e:	fcc42783          	lw	a5,-52(s0)
    80002122:	0607c563          	bltz	a5,8000218c <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002126:	0000c517          	auipc	a0,0xc
    8000212a:	9ca50513          	addi	a0,a0,-1590 # 8000daf0 <tickslock>
    8000212e:	055030ef          	jal	ra,80005982 <acquire>
  ticks0 = ticks;
    80002132:	00006917          	auipc	s2,0x6
    80002136:	95692903          	lw	s2,-1706(s2) # 80007a88 <ticks>
  while(ticks - ticks0 < n){
    8000213a:	fcc42783          	lw	a5,-52(s0)
    8000213e:	cb8d                	beqz	a5,80002170 <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002140:	0000c997          	auipc	s3,0xc
    80002144:	9b098993          	addi	s3,s3,-1616 # 8000daf0 <tickslock>
    80002148:	00006497          	auipc	s1,0x6
    8000214c:	94048493          	addi	s1,s1,-1728 # 80007a88 <ticks>
    if(killed(myproc())){
    80002150:	f95fe0ef          	jal	ra,800010e4 <myproc>
    80002154:	f94ff0ef          	jal	ra,800018e8 <killed>
    80002158:	ed0d                	bnez	a0,80002192 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    8000215a:	85ce                	mv	a1,s3
    8000215c:	8526                	mv	a0,s1
    8000215e:	d52ff0ef          	jal	ra,800016b0 <sleep>
  while(ticks - ticks0 < n){
    80002162:	409c                	lw	a5,0(s1)
    80002164:	412787bb          	subw	a5,a5,s2
    80002168:	fcc42703          	lw	a4,-52(s0)
    8000216c:	fee7e2e3          	bltu	a5,a4,80002150 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002170:	0000c517          	auipc	a0,0xc
    80002174:	98050513          	addi	a0,a0,-1664 # 8000daf0 <tickslock>
    80002178:	0a3030ef          	jal	ra,80005a1a <release>
  return 0;
    8000217c:	4501                	li	a0,0
}
    8000217e:	70e2                	ld	ra,56(sp)
    80002180:	7442                	ld	s0,48(sp)
    80002182:	74a2                	ld	s1,40(sp)
    80002184:	7902                	ld	s2,32(sp)
    80002186:	69e2                	ld	s3,24(sp)
    80002188:	6121                	addi	sp,sp,64
    8000218a:	8082                	ret
    n = 0;
    8000218c:	fc042623          	sw	zero,-52(s0)
    80002190:	bf59                	j	80002126 <sys_sleep+0x20>
      release(&tickslock);
    80002192:	0000c517          	auipc	a0,0xc
    80002196:	95e50513          	addi	a0,a0,-1698 # 8000daf0 <tickslock>
    8000219a:	081030ef          	jal	ra,80005a1a <release>
      return -1;
    8000219e:	557d                	li	a0,-1
    800021a0:	bff9                	j	8000217e <sys_sleep+0x78>

00000000800021a2 <sys_pgpte>:


#ifdef LAB_PGTBL
int
sys_pgpte(void)
{
    800021a2:	7179                	addi	sp,sp,-48
    800021a4:	f406                	sd	ra,40(sp)
    800021a6:	f022                	sd	s0,32(sp)
    800021a8:	ec26                	sd	s1,24(sp)
    800021aa:	1800                	addi	s0,sp,48
  uint64 va;
  struct proc *p;

  p = myproc();
    800021ac:	f39fe0ef          	jal	ra,800010e4 <myproc>
    800021b0:	84aa                	mv	s1,a0
  argaddr(0, &va);
    800021b2:	fd840593          	addi	a1,s0,-40
    800021b6:	4501                	li	a0,0
    800021b8:	df7ff0ef          	jal	ra,80001fae <argaddr>
  pte_t *pte = pgpte(p->pagetable, va);
    800021bc:	fd843583          	ld	a1,-40(s0)
    800021c0:	68a8                	ld	a0,80(s1)
    800021c2:	daffe0ef          	jal	ra,80000f70 <pgpte>
    800021c6:	87aa                	mv	a5,a0
  if(pte != 0) {
      return (uint64) *pte;
  }
  return 0;
    800021c8:	4501                	li	a0,0
  if(pte != 0) {
    800021ca:	c391                	beqz	a5,800021ce <sys_pgpte+0x2c>
      return (uint64) *pte;
    800021cc:	4388                	lw	a0,0(a5)
}
    800021ce:	70a2                	ld	ra,40(sp)
    800021d0:	7402                	ld	s0,32(sp)
    800021d2:	64e2                	ld	s1,24(sp)
    800021d4:	6145                	addi	sp,sp,48
    800021d6:	8082                	ret

00000000800021d8 <sys_kpgtbl>:
#endif

#ifdef LAB_PGTBL
int
sys_kpgtbl(void)
{
    800021d8:	1141                	addi	sp,sp,-16
    800021da:	e406                	sd	ra,8(sp)
    800021dc:	e022                	sd	s0,0(sp)
    800021de:	0800                	addi	s0,sp,16
  struct proc *p;

  p = myproc();
    800021e0:	f05fe0ef          	jal	ra,800010e4 <myproc>
  vmprint(p->pagetable);
    800021e4:	6928                	ld	a0,80(a0)
    800021e6:	d5dfe0ef          	jal	ra,80000f42 <vmprint>
  return 0;
}
    800021ea:	4501                	li	a0,0
    800021ec:	60a2                	ld	ra,8(sp)
    800021ee:	6402                	ld	s0,0(sp)
    800021f0:	0141                	addi	sp,sp,16
    800021f2:	8082                	ret

00000000800021f4 <sys_kill>:
#endif


uint64
sys_kill(void)
{
    800021f4:	1101                	addi	sp,sp,-32
    800021f6:	ec06                	sd	ra,24(sp)
    800021f8:	e822                	sd	s0,16(sp)
    800021fa:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800021fc:	fec40593          	addi	a1,s0,-20
    80002200:	4501                	li	a0,0
    80002202:	d91ff0ef          	jal	ra,80001f92 <argint>
  return kill(pid);
    80002206:	fec42503          	lw	a0,-20(s0)
    8000220a:	e54ff0ef          	jal	ra,8000185e <kill>
}
    8000220e:	60e2                	ld	ra,24(sp)
    80002210:	6442                	ld	s0,16(sp)
    80002212:	6105                	addi	sp,sp,32
    80002214:	8082                	ret

0000000080002216 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002216:	1101                	addi	sp,sp,-32
    80002218:	ec06                	sd	ra,24(sp)
    8000221a:	e822                	sd	s0,16(sp)
    8000221c:	e426                	sd	s1,8(sp)
    8000221e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002220:	0000c517          	auipc	a0,0xc
    80002224:	8d050513          	addi	a0,a0,-1840 # 8000daf0 <tickslock>
    80002228:	75a030ef          	jal	ra,80005982 <acquire>
  xticks = ticks;
    8000222c:	00006497          	auipc	s1,0x6
    80002230:	85c4a483          	lw	s1,-1956(s1) # 80007a88 <ticks>
  release(&tickslock);
    80002234:	0000c517          	auipc	a0,0xc
    80002238:	8bc50513          	addi	a0,a0,-1860 # 8000daf0 <tickslock>
    8000223c:	7de030ef          	jal	ra,80005a1a <release>
  return xticks;
}
    80002240:	02049513          	slli	a0,s1,0x20
    80002244:	9101                	srli	a0,a0,0x20
    80002246:	60e2                	ld	ra,24(sp)
    80002248:	6442                	ld	s0,16(sp)
    8000224a:	64a2                	ld	s1,8(sp)
    8000224c:	6105                	addi	sp,sp,32
    8000224e:	8082                	ret

0000000080002250 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002250:	7179                	addi	sp,sp,-48
    80002252:	f406                	sd	ra,40(sp)
    80002254:	f022                	sd	s0,32(sp)
    80002256:	ec26                	sd	s1,24(sp)
    80002258:	e84a                	sd	s2,16(sp)
    8000225a:	e44e                	sd	s3,8(sp)
    8000225c:	e052                	sd	s4,0(sp)
    8000225e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002260:	00005597          	auipc	a1,0x5
    80002264:	3e858593          	addi	a1,a1,1000 # 80007648 <syscalls+0x118>
    80002268:	0000c517          	auipc	a0,0xc
    8000226c:	8a050513          	addi	a0,a0,-1888 # 8000db08 <bcache>
    80002270:	692030ef          	jal	ra,80005902 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002274:	00014797          	auipc	a5,0x14
    80002278:	89478793          	addi	a5,a5,-1900 # 80015b08 <bcache+0x8000>
    8000227c:	00014717          	auipc	a4,0x14
    80002280:	af470713          	addi	a4,a4,-1292 # 80015d70 <bcache+0x8268>
    80002284:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002288:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000228c:	0000c497          	auipc	s1,0xc
    80002290:	89448493          	addi	s1,s1,-1900 # 8000db20 <bcache+0x18>
    b->next = bcache.head.next;
    80002294:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002296:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002298:	00005a17          	auipc	s4,0x5
    8000229c:	3b8a0a13          	addi	s4,s4,952 # 80007650 <syscalls+0x120>
    b->next = bcache.head.next;
    800022a0:	2b893783          	ld	a5,696(s2)
    800022a4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800022a6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800022aa:	85d2                	mv	a1,s4
    800022ac:	01048513          	addi	a0,s1,16
    800022b0:	228010ef          	jal	ra,800034d8 <initsleeplock>
    bcache.head.next->prev = b;
    800022b4:	2b893783          	ld	a5,696(s2)
    800022b8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800022ba:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800022be:	45848493          	addi	s1,s1,1112
    800022c2:	fd349fe3          	bne	s1,s3,800022a0 <binit+0x50>
  }
}
    800022c6:	70a2                	ld	ra,40(sp)
    800022c8:	7402                	ld	s0,32(sp)
    800022ca:	64e2                	ld	s1,24(sp)
    800022cc:	6942                	ld	s2,16(sp)
    800022ce:	69a2                	ld	s3,8(sp)
    800022d0:	6a02                	ld	s4,0(sp)
    800022d2:	6145                	addi	sp,sp,48
    800022d4:	8082                	ret

00000000800022d6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800022d6:	7179                	addi	sp,sp,-48
    800022d8:	f406                	sd	ra,40(sp)
    800022da:	f022                	sd	s0,32(sp)
    800022dc:	ec26                	sd	s1,24(sp)
    800022de:	e84a                	sd	s2,16(sp)
    800022e0:	e44e                	sd	s3,8(sp)
    800022e2:	1800                	addi	s0,sp,48
    800022e4:	892a                	mv	s2,a0
    800022e6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800022e8:	0000c517          	auipc	a0,0xc
    800022ec:	82050513          	addi	a0,a0,-2016 # 8000db08 <bcache>
    800022f0:	692030ef          	jal	ra,80005982 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800022f4:	00014497          	auipc	s1,0x14
    800022f8:	acc4b483          	ld	s1,-1332(s1) # 80015dc0 <bcache+0x82b8>
    800022fc:	00014797          	auipc	a5,0x14
    80002300:	a7478793          	addi	a5,a5,-1420 # 80015d70 <bcache+0x8268>
    80002304:	02f48b63          	beq	s1,a5,8000233a <bread+0x64>
    80002308:	873e                	mv	a4,a5
    8000230a:	a021                	j	80002312 <bread+0x3c>
    8000230c:	68a4                	ld	s1,80(s1)
    8000230e:	02e48663          	beq	s1,a4,8000233a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002312:	449c                	lw	a5,8(s1)
    80002314:	ff279ce3          	bne	a5,s2,8000230c <bread+0x36>
    80002318:	44dc                	lw	a5,12(s1)
    8000231a:	ff3799e3          	bne	a5,s3,8000230c <bread+0x36>
      b->refcnt++;
    8000231e:	40bc                	lw	a5,64(s1)
    80002320:	2785                	addiw	a5,a5,1
    80002322:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002324:	0000b517          	auipc	a0,0xb
    80002328:	7e450513          	addi	a0,a0,2020 # 8000db08 <bcache>
    8000232c:	6ee030ef          	jal	ra,80005a1a <release>
      acquiresleep(&b->lock);
    80002330:	01048513          	addi	a0,s1,16
    80002334:	1da010ef          	jal	ra,8000350e <acquiresleep>
      return b;
    80002338:	a889                	j	8000238a <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000233a:	00014497          	auipc	s1,0x14
    8000233e:	a7e4b483          	ld	s1,-1410(s1) # 80015db8 <bcache+0x82b0>
    80002342:	00014797          	auipc	a5,0x14
    80002346:	a2e78793          	addi	a5,a5,-1490 # 80015d70 <bcache+0x8268>
    8000234a:	00f48863          	beq	s1,a5,8000235a <bread+0x84>
    8000234e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002350:	40bc                	lw	a5,64(s1)
    80002352:	cb91                	beqz	a5,80002366 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002354:	64a4                	ld	s1,72(s1)
    80002356:	fee49de3          	bne	s1,a4,80002350 <bread+0x7a>
  panic("bget: no buffers");
    8000235a:	00005517          	auipc	a0,0x5
    8000235e:	2fe50513          	addi	a0,a0,766 # 80007658 <syscalls+0x128>
    80002362:	310030ef          	jal	ra,80005672 <panic>
      b->dev = dev;
    80002366:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000236a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000236e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002372:	4785                	li	a5,1
    80002374:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002376:	0000b517          	auipc	a0,0xb
    8000237a:	79250513          	addi	a0,a0,1938 # 8000db08 <bcache>
    8000237e:	69c030ef          	jal	ra,80005a1a <release>
      acquiresleep(&b->lock);
    80002382:	01048513          	addi	a0,s1,16
    80002386:	188010ef          	jal	ra,8000350e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000238a:	409c                	lw	a5,0(s1)
    8000238c:	cb89                	beqz	a5,8000239e <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000238e:	8526                	mv	a0,s1
    80002390:	70a2                	ld	ra,40(sp)
    80002392:	7402                	ld	s0,32(sp)
    80002394:	64e2                	ld	s1,24(sp)
    80002396:	6942                	ld	s2,16(sp)
    80002398:	69a2                	ld	s3,8(sp)
    8000239a:	6145                	addi	sp,sp,48
    8000239c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000239e:	4581                	li	a1,0
    800023a0:	8526                	mv	a0,s1
    800023a2:	0d9020ef          	jal	ra,80004c7a <virtio_disk_rw>
    b->valid = 1;
    800023a6:	4785                	li	a5,1
    800023a8:	c09c                	sw	a5,0(s1)
  return b;
    800023aa:	b7d5                	j	8000238e <bread+0xb8>

00000000800023ac <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800023ac:	1101                	addi	sp,sp,-32
    800023ae:	ec06                	sd	ra,24(sp)
    800023b0:	e822                	sd	s0,16(sp)
    800023b2:	e426                	sd	s1,8(sp)
    800023b4:	1000                	addi	s0,sp,32
    800023b6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800023b8:	0541                	addi	a0,a0,16
    800023ba:	1d2010ef          	jal	ra,8000358c <holdingsleep>
    800023be:	c911                	beqz	a0,800023d2 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800023c0:	4585                	li	a1,1
    800023c2:	8526                	mv	a0,s1
    800023c4:	0b7020ef          	jal	ra,80004c7a <virtio_disk_rw>
}
    800023c8:	60e2                	ld	ra,24(sp)
    800023ca:	6442                	ld	s0,16(sp)
    800023cc:	64a2                	ld	s1,8(sp)
    800023ce:	6105                	addi	sp,sp,32
    800023d0:	8082                	ret
    panic("bwrite");
    800023d2:	00005517          	auipc	a0,0x5
    800023d6:	29e50513          	addi	a0,a0,670 # 80007670 <syscalls+0x140>
    800023da:	298030ef          	jal	ra,80005672 <panic>

00000000800023de <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800023de:	1101                	addi	sp,sp,-32
    800023e0:	ec06                	sd	ra,24(sp)
    800023e2:	e822                	sd	s0,16(sp)
    800023e4:	e426                	sd	s1,8(sp)
    800023e6:	e04a                	sd	s2,0(sp)
    800023e8:	1000                	addi	s0,sp,32
    800023ea:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800023ec:	01050913          	addi	s2,a0,16
    800023f0:	854a                	mv	a0,s2
    800023f2:	19a010ef          	jal	ra,8000358c <holdingsleep>
    800023f6:	c13d                	beqz	a0,8000245c <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    800023f8:	854a                	mv	a0,s2
    800023fa:	15a010ef          	jal	ra,80003554 <releasesleep>

  acquire(&bcache.lock);
    800023fe:	0000b517          	auipc	a0,0xb
    80002402:	70a50513          	addi	a0,a0,1802 # 8000db08 <bcache>
    80002406:	57c030ef          	jal	ra,80005982 <acquire>
  b->refcnt--;
    8000240a:	40bc                	lw	a5,64(s1)
    8000240c:	37fd                	addiw	a5,a5,-1
    8000240e:	0007871b          	sext.w	a4,a5
    80002412:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002414:	eb05                	bnez	a4,80002444 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002416:	68bc                	ld	a5,80(s1)
    80002418:	64b8                	ld	a4,72(s1)
    8000241a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000241c:	64bc                	ld	a5,72(s1)
    8000241e:	68b8                	ld	a4,80(s1)
    80002420:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002422:	00013797          	auipc	a5,0x13
    80002426:	6e678793          	addi	a5,a5,1766 # 80015b08 <bcache+0x8000>
    8000242a:	2b87b703          	ld	a4,696(a5)
    8000242e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002430:	00014717          	auipc	a4,0x14
    80002434:	94070713          	addi	a4,a4,-1728 # 80015d70 <bcache+0x8268>
    80002438:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000243a:	2b87b703          	ld	a4,696(a5)
    8000243e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002440:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002444:	0000b517          	auipc	a0,0xb
    80002448:	6c450513          	addi	a0,a0,1732 # 8000db08 <bcache>
    8000244c:	5ce030ef          	jal	ra,80005a1a <release>
}
    80002450:	60e2                	ld	ra,24(sp)
    80002452:	6442                	ld	s0,16(sp)
    80002454:	64a2                	ld	s1,8(sp)
    80002456:	6902                	ld	s2,0(sp)
    80002458:	6105                	addi	sp,sp,32
    8000245a:	8082                	ret
    panic("brelse");
    8000245c:	00005517          	auipc	a0,0x5
    80002460:	21c50513          	addi	a0,a0,540 # 80007678 <syscalls+0x148>
    80002464:	20e030ef          	jal	ra,80005672 <panic>

0000000080002468 <bpin>:

void
bpin(struct buf *b) {
    80002468:	1101                	addi	sp,sp,-32
    8000246a:	ec06                	sd	ra,24(sp)
    8000246c:	e822                	sd	s0,16(sp)
    8000246e:	e426                	sd	s1,8(sp)
    80002470:	1000                	addi	s0,sp,32
    80002472:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002474:	0000b517          	auipc	a0,0xb
    80002478:	69450513          	addi	a0,a0,1684 # 8000db08 <bcache>
    8000247c:	506030ef          	jal	ra,80005982 <acquire>
  b->refcnt++;
    80002480:	40bc                	lw	a5,64(s1)
    80002482:	2785                	addiw	a5,a5,1
    80002484:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002486:	0000b517          	auipc	a0,0xb
    8000248a:	68250513          	addi	a0,a0,1666 # 8000db08 <bcache>
    8000248e:	58c030ef          	jal	ra,80005a1a <release>
}
    80002492:	60e2                	ld	ra,24(sp)
    80002494:	6442                	ld	s0,16(sp)
    80002496:	64a2                	ld	s1,8(sp)
    80002498:	6105                	addi	sp,sp,32
    8000249a:	8082                	ret

000000008000249c <bunpin>:

void
bunpin(struct buf *b) {
    8000249c:	1101                	addi	sp,sp,-32
    8000249e:	ec06                	sd	ra,24(sp)
    800024a0:	e822                	sd	s0,16(sp)
    800024a2:	e426                	sd	s1,8(sp)
    800024a4:	1000                	addi	s0,sp,32
    800024a6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800024a8:	0000b517          	auipc	a0,0xb
    800024ac:	66050513          	addi	a0,a0,1632 # 8000db08 <bcache>
    800024b0:	4d2030ef          	jal	ra,80005982 <acquire>
  b->refcnt--;
    800024b4:	40bc                	lw	a5,64(s1)
    800024b6:	37fd                	addiw	a5,a5,-1
    800024b8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800024ba:	0000b517          	auipc	a0,0xb
    800024be:	64e50513          	addi	a0,a0,1614 # 8000db08 <bcache>
    800024c2:	558030ef          	jal	ra,80005a1a <release>
}
    800024c6:	60e2                	ld	ra,24(sp)
    800024c8:	6442                	ld	s0,16(sp)
    800024ca:	64a2                	ld	s1,8(sp)
    800024cc:	6105                	addi	sp,sp,32
    800024ce:	8082                	ret

00000000800024d0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800024d0:	1101                	addi	sp,sp,-32
    800024d2:	ec06                	sd	ra,24(sp)
    800024d4:	e822                	sd	s0,16(sp)
    800024d6:	e426                	sd	s1,8(sp)
    800024d8:	e04a                	sd	s2,0(sp)
    800024da:	1000                	addi	s0,sp,32
    800024dc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800024de:	00d5d59b          	srliw	a1,a1,0xd
    800024e2:	00014797          	auipc	a5,0x14
    800024e6:	d027a783          	lw	a5,-766(a5) # 800161e4 <sb+0x1c>
    800024ea:	9dbd                	addw	a1,a1,a5
    800024ec:	debff0ef          	jal	ra,800022d6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800024f0:	0074f713          	andi	a4,s1,7
    800024f4:	4785                	li	a5,1
    800024f6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800024fa:	14ce                	slli	s1,s1,0x33
    800024fc:	90d9                	srli	s1,s1,0x36
    800024fe:	00950733          	add	a4,a0,s1
    80002502:	05874703          	lbu	a4,88(a4)
    80002506:	00e7f6b3          	and	a3,a5,a4
    8000250a:	c29d                	beqz	a3,80002530 <bfree+0x60>
    8000250c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000250e:	94aa                	add	s1,s1,a0
    80002510:	fff7c793          	not	a5,a5
    80002514:	8f7d                	and	a4,a4,a5
    80002516:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000251a:	6ef000ef          	jal	ra,80003408 <log_write>
  brelse(bp);
    8000251e:	854a                	mv	a0,s2
    80002520:	ebfff0ef          	jal	ra,800023de <brelse>
}
    80002524:	60e2                	ld	ra,24(sp)
    80002526:	6442                	ld	s0,16(sp)
    80002528:	64a2                	ld	s1,8(sp)
    8000252a:	6902                	ld	s2,0(sp)
    8000252c:	6105                	addi	sp,sp,32
    8000252e:	8082                	ret
    panic("freeing free block");
    80002530:	00005517          	auipc	a0,0x5
    80002534:	15050513          	addi	a0,a0,336 # 80007680 <syscalls+0x150>
    80002538:	13a030ef          	jal	ra,80005672 <panic>

000000008000253c <balloc>:
{
    8000253c:	711d                	addi	sp,sp,-96
    8000253e:	ec86                	sd	ra,88(sp)
    80002540:	e8a2                	sd	s0,80(sp)
    80002542:	e4a6                	sd	s1,72(sp)
    80002544:	e0ca                	sd	s2,64(sp)
    80002546:	fc4e                	sd	s3,56(sp)
    80002548:	f852                	sd	s4,48(sp)
    8000254a:	f456                	sd	s5,40(sp)
    8000254c:	f05a                	sd	s6,32(sp)
    8000254e:	ec5e                	sd	s7,24(sp)
    80002550:	e862                	sd	s8,16(sp)
    80002552:	e466                	sd	s9,8(sp)
    80002554:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002556:	00014797          	auipc	a5,0x14
    8000255a:	c767a783          	lw	a5,-906(a5) # 800161cc <sb+0x4>
    8000255e:	cff1                	beqz	a5,8000263a <balloc+0xfe>
    80002560:	8baa                	mv	s7,a0
    80002562:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002564:	00014b17          	auipc	s6,0x14
    80002568:	c64b0b13          	addi	s6,s6,-924 # 800161c8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000256c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000256e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002570:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002572:	6c89                	lui	s9,0x2
    80002574:	a0b5                	j	800025e0 <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002576:	97ca                	add	a5,a5,s2
    80002578:	8e55                	or	a2,a2,a3
    8000257a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000257e:	854a                	mv	a0,s2
    80002580:	689000ef          	jal	ra,80003408 <log_write>
        brelse(bp);
    80002584:	854a                	mv	a0,s2
    80002586:	e59ff0ef          	jal	ra,800023de <brelse>
  bp = bread(dev, bno);
    8000258a:	85a6                	mv	a1,s1
    8000258c:	855e                	mv	a0,s7
    8000258e:	d49ff0ef          	jal	ra,800022d6 <bread>
    80002592:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002594:	40000613          	li	a2,1024
    80002598:	4581                	li	a1,0
    8000259a:	05850513          	addi	a0,a0,88
    8000259e:	d15fd0ef          	jal	ra,800002b2 <memset>
  log_write(bp);
    800025a2:	854a                	mv	a0,s2
    800025a4:	665000ef          	jal	ra,80003408 <log_write>
  brelse(bp);
    800025a8:	854a                	mv	a0,s2
    800025aa:	e35ff0ef          	jal	ra,800023de <brelse>
}
    800025ae:	8526                	mv	a0,s1
    800025b0:	60e6                	ld	ra,88(sp)
    800025b2:	6446                	ld	s0,80(sp)
    800025b4:	64a6                	ld	s1,72(sp)
    800025b6:	6906                	ld	s2,64(sp)
    800025b8:	79e2                	ld	s3,56(sp)
    800025ba:	7a42                	ld	s4,48(sp)
    800025bc:	7aa2                	ld	s5,40(sp)
    800025be:	7b02                	ld	s6,32(sp)
    800025c0:	6be2                	ld	s7,24(sp)
    800025c2:	6c42                	ld	s8,16(sp)
    800025c4:	6ca2                	ld	s9,8(sp)
    800025c6:	6125                	addi	sp,sp,96
    800025c8:	8082                	ret
    brelse(bp);
    800025ca:	854a                	mv	a0,s2
    800025cc:	e13ff0ef          	jal	ra,800023de <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800025d0:	015c87bb          	addw	a5,s9,s5
    800025d4:	00078a9b          	sext.w	s5,a5
    800025d8:	004b2703          	lw	a4,4(s6)
    800025dc:	04eaff63          	bgeu	s5,a4,8000263a <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    800025e0:	41fad79b          	sraiw	a5,s5,0x1f
    800025e4:	0137d79b          	srliw	a5,a5,0x13
    800025e8:	015787bb          	addw	a5,a5,s5
    800025ec:	40d7d79b          	sraiw	a5,a5,0xd
    800025f0:	01cb2583          	lw	a1,28(s6)
    800025f4:	9dbd                	addw	a1,a1,a5
    800025f6:	855e                	mv	a0,s7
    800025f8:	cdfff0ef          	jal	ra,800022d6 <bread>
    800025fc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800025fe:	004b2503          	lw	a0,4(s6)
    80002602:	000a849b          	sext.w	s1,s5
    80002606:	8762                	mv	a4,s8
    80002608:	fca4f1e3          	bgeu	s1,a0,800025ca <balloc+0x8e>
      m = 1 << (bi % 8);
    8000260c:	00777693          	andi	a3,a4,7
    80002610:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002614:	41f7579b          	sraiw	a5,a4,0x1f
    80002618:	01d7d79b          	srliw	a5,a5,0x1d
    8000261c:	9fb9                	addw	a5,a5,a4
    8000261e:	4037d79b          	sraiw	a5,a5,0x3
    80002622:	00f90633          	add	a2,s2,a5
    80002626:	05864603          	lbu	a2,88(a2)
    8000262a:	00c6f5b3          	and	a1,a3,a2
    8000262e:	d5a1                	beqz	a1,80002576 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002630:	2705                	addiw	a4,a4,1
    80002632:	2485                	addiw	s1,s1,1
    80002634:	fd471ae3          	bne	a4,s4,80002608 <balloc+0xcc>
    80002638:	bf49                	j	800025ca <balloc+0x8e>
  printf("balloc: out of blocks\n");
    8000263a:	00005517          	auipc	a0,0x5
    8000263e:	05e50513          	addi	a0,a0,94 # 80007698 <syscalls+0x168>
    80002642:	57d020ef          	jal	ra,800053be <printf>
  return 0;
    80002646:	4481                	li	s1,0
    80002648:	b79d                	j	800025ae <balloc+0x72>

000000008000264a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000264a:	7179                	addi	sp,sp,-48
    8000264c:	f406                	sd	ra,40(sp)
    8000264e:	f022                	sd	s0,32(sp)
    80002650:	ec26                	sd	s1,24(sp)
    80002652:	e84a                	sd	s2,16(sp)
    80002654:	e44e                	sd	s3,8(sp)
    80002656:	e052                	sd	s4,0(sp)
    80002658:	1800                	addi	s0,sp,48
    8000265a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000265c:	47ad                	li	a5,11
    8000265e:	02b7e663          	bltu	a5,a1,8000268a <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    80002662:	02059793          	slli	a5,a1,0x20
    80002666:	01e7d593          	srli	a1,a5,0x1e
    8000266a:	00b504b3          	add	s1,a0,a1
    8000266e:	0504a903          	lw	s2,80(s1)
    80002672:	06091663          	bnez	s2,800026de <bmap+0x94>
      addr = balloc(ip->dev);
    80002676:	4108                	lw	a0,0(a0)
    80002678:	ec5ff0ef          	jal	ra,8000253c <balloc>
    8000267c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002680:	04090f63          	beqz	s2,800026de <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    80002684:	0524a823          	sw	s2,80(s1)
    80002688:	a899                	j	800026de <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000268a:	ff45849b          	addiw	s1,a1,-12
    8000268e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002692:	0ff00793          	li	a5,255
    80002696:	06e7eb63          	bltu	a5,a4,8000270c <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000269a:	08052903          	lw	s2,128(a0)
    8000269e:	00091b63          	bnez	s2,800026b4 <bmap+0x6a>
      addr = balloc(ip->dev);
    800026a2:	4108                	lw	a0,0(a0)
    800026a4:	e99ff0ef          	jal	ra,8000253c <balloc>
    800026a8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800026ac:	02090963          	beqz	s2,800026de <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800026b0:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800026b4:	85ca                	mv	a1,s2
    800026b6:	0009a503          	lw	a0,0(s3)
    800026ba:	c1dff0ef          	jal	ra,800022d6 <bread>
    800026be:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800026c0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800026c4:	02049713          	slli	a4,s1,0x20
    800026c8:	01e75593          	srli	a1,a4,0x1e
    800026cc:	00b784b3          	add	s1,a5,a1
    800026d0:	0004a903          	lw	s2,0(s1)
    800026d4:	00090e63          	beqz	s2,800026f0 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800026d8:	8552                	mv	a0,s4
    800026da:	d05ff0ef          	jal	ra,800023de <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800026de:	854a                	mv	a0,s2
    800026e0:	70a2                	ld	ra,40(sp)
    800026e2:	7402                	ld	s0,32(sp)
    800026e4:	64e2                	ld	s1,24(sp)
    800026e6:	6942                	ld	s2,16(sp)
    800026e8:	69a2                	ld	s3,8(sp)
    800026ea:	6a02                	ld	s4,0(sp)
    800026ec:	6145                	addi	sp,sp,48
    800026ee:	8082                	ret
      addr = balloc(ip->dev);
    800026f0:	0009a503          	lw	a0,0(s3)
    800026f4:	e49ff0ef          	jal	ra,8000253c <balloc>
    800026f8:	0005091b          	sext.w	s2,a0
      if(addr){
    800026fc:	fc090ee3          	beqz	s2,800026d8 <bmap+0x8e>
        a[bn] = addr;
    80002700:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002704:	8552                	mv	a0,s4
    80002706:	503000ef          	jal	ra,80003408 <log_write>
    8000270a:	b7f9                	j	800026d8 <bmap+0x8e>
  panic("bmap: out of range");
    8000270c:	00005517          	auipc	a0,0x5
    80002710:	fa450513          	addi	a0,a0,-92 # 800076b0 <syscalls+0x180>
    80002714:	75f020ef          	jal	ra,80005672 <panic>

0000000080002718 <iget>:
{
    80002718:	7179                	addi	sp,sp,-48
    8000271a:	f406                	sd	ra,40(sp)
    8000271c:	f022                	sd	s0,32(sp)
    8000271e:	ec26                	sd	s1,24(sp)
    80002720:	e84a                	sd	s2,16(sp)
    80002722:	e44e                	sd	s3,8(sp)
    80002724:	e052                	sd	s4,0(sp)
    80002726:	1800                	addi	s0,sp,48
    80002728:	89aa                	mv	s3,a0
    8000272a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000272c:	00014517          	auipc	a0,0x14
    80002730:	abc50513          	addi	a0,a0,-1348 # 800161e8 <itable>
    80002734:	24e030ef          	jal	ra,80005982 <acquire>
  empty = 0;
    80002738:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000273a:	00014497          	auipc	s1,0x14
    8000273e:	ac648493          	addi	s1,s1,-1338 # 80016200 <itable+0x18>
    80002742:	00015697          	auipc	a3,0x15
    80002746:	54e68693          	addi	a3,a3,1358 # 80017c90 <log>
    8000274a:	a039                	j	80002758 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000274c:	02090963          	beqz	s2,8000277e <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002750:	08848493          	addi	s1,s1,136
    80002754:	02d48863          	beq	s1,a3,80002784 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002758:	449c                	lw	a5,8(s1)
    8000275a:	fef059e3          	blez	a5,8000274c <iget+0x34>
    8000275e:	4098                	lw	a4,0(s1)
    80002760:	ff3716e3          	bne	a4,s3,8000274c <iget+0x34>
    80002764:	40d8                	lw	a4,4(s1)
    80002766:	ff4713e3          	bne	a4,s4,8000274c <iget+0x34>
      ip->ref++;
    8000276a:	2785                	addiw	a5,a5,1
    8000276c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000276e:	00014517          	auipc	a0,0x14
    80002772:	a7a50513          	addi	a0,a0,-1414 # 800161e8 <itable>
    80002776:	2a4030ef          	jal	ra,80005a1a <release>
      return ip;
    8000277a:	8926                	mv	s2,s1
    8000277c:	a02d                	j	800027a6 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000277e:	fbe9                	bnez	a5,80002750 <iget+0x38>
    80002780:	8926                	mv	s2,s1
    80002782:	b7f9                	j	80002750 <iget+0x38>
  if(empty == 0)
    80002784:	02090a63          	beqz	s2,800027b8 <iget+0xa0>
  ip->dev = dev;
    80002788:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000278c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002790:	4785                	li	a5,1
    80002792:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002796:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000279a:	00014517          	auipc	a0,0x14
    8000279e:	a4e50513          	addi	a0,a0,-1458 # 800161e8 <itable>
    800027a2:	278030ef          	jal	ra,80005a1a <release>
}
    800027a6:	854a                	mv	a0,s2
    800027a8:	70a2                	ld	ra,40(sp)
    800027aa:	7402                	ld	s0,32(sp)
    800027ac:	64e2                	ld	s1,24(sp)
    800027ae:	6942                	ld	s2,16(sp)
    800027b0:	69a2                	ld	s3,8(sp)
    800027b2:	6a02                	ld	s4,0(sp)
    800027b4:	6145                	addi	sp,sp,48
    800027b6:	8082                	ret
    panic("iget: no inodes");
    800027b8:	00005517          	auipc	a0,0x5
    800027bc:	f1050513          	addi	a0,a0,-240 # 800076c8 <syscalls+0x198>
    800027c0:	6b3020ef          	jal	ra,80005672 <panic>

00000000800027c4 <fsinit>:
fsinit(int dev) {
    800027c4:	7179                	addi	sp,sp,-48
    800027c6:	f406                	sd	ra,40(sp)
    800027c8:	f022                	sd	s0,32(sp)
    800027ca:	ec26                	sd	s1,24(sp)
    800027cc:	e84a                	sd	s2,16(sp)
    800027ce:	e44e                	sd	s3,8(sp)
    800027d0:	1800                	addi	s0,sp,48
    800027d2:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800027d4:	4585                	li	a1,1
    800027d6:	b01ff0ef          	jal	ra,800022d6 <bread>
    800027da:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800027dc:	00014997          	auipc	s3,0x14
    800027e0:	9ec98993          	addi	s3,s3,-1556 # 800161c8 <sb>
    800027e4:	02000613          	li	a2,32
    800027e8:	05850593          	addi	a1,a0,88
    800027ec:	854e                	mv	a0,s3
    800027ee:	b21fd0ef          	jal	ra,8000030e <memmove>
  brelse(bp);
    800027f2:	8526                	mv	a0,s1
    800027f4:	bebff0ef          	jal	ra,800023de <brelse>
  if(sb.magic != FSMAGIC)
    800027f8:	0009a703          	lw	a4,0(s3)
    800027fc:	102037b7          	lui	a5,0x10203
    80002800:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002804:	02f71063          	bne	a4,a5,80002824 <fsinit+0x60>
  initlog(dev, &sb);
    80002808:	00014597          	auipc	a1,0x14
    8000280c:	9c058593          	addi	a1,a1,-1600 # 800161c8 <sb>
    80002810:	854a                	mv	a0,s2
    80002812:	1e3000ef          	jal	ra,800031f4 <initlog>
}
    80002816:	70a2                	ld	ra,40(sp)
    80002818:	7402                	ld	s0,32(sp)
    8000281a:	64e2                	ld	s1,24(sp)
    8000281c:	6942                	ld	s2,16(sp)
    8000281e:	69a2                	ld	s3,8(sp)
    80002820:	6145                	addi	sp,sp,48
    80002822:	8082                	ret
    panic("invalid file system");
    80002824:	00005517          	auipc	a0,0x5
    80002828:	eb450513          	addi	a0,a0,-332 # 800076d8 <syscalls+0x1a8>
    8000282c:	647020ef          	jal	ra,80005672 <panic>

0000000080002830 <iinit>:
{
    80002830:	7179                	addi	sp,sp,-48
    80002832:	f406                	sd	ra,40(sp)
    80002834:	f022                	sd	s0,32(sp)
    80002836:	ec26                	sd	s1,24(sp)
    80002838:	e84a                	sd	s2,16(sp)
    8000283a:	e44e                	sd	s3,8(sp)
    8000283c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000283e:	00005597          	auipc	a1,0x5
    80002842:	eb258593          	addi	a1,a1,-334 # 800076f0 <syscalls+0x1c0>
    80002846:	00014517          	auipc	a0,0x14
    8000284a:	9a250513          	addi	a0,a0,-1630 # 800161e8 <itable>
    8000284e:	0b4030ef          	jal	ra,80005902 <initlock>
  for(i = 0; i < NINODE; i++) {
    80002852:	00014497          	auipc	s1,0x14
    80002856:	9be48493          	addi	s1,s1,-1602 # 80016210 <itable+0x28>
    8000285a:	00015997          	auipc	s3,0x15
    8000285e:	44698993          	addi	s3,s3,1094 # 80017ca0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002862:	00005917          	auipc	s2,0x5
    80002866:	e9690913          	addi	s2,s2,-362 # 800076f8 <syscalls+0x1c8>
    8000286a:	85ca                	mv	a1,s2
    8000286c:	8526                	mv	a0,s1
    8000286e:	46b000ef          	jal	ra,800034d8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002872:	08848493          	addi	s1,s1,136
    80002876:	ff349ae3          	bne	s1,s3,8000286a <iinit+0x3a>
}
    8000287a:	70a2                	ld	ra,40(sp)
    8000287c:	7402                	ld	s0,32(sp)
    8000287e:	64e2                	ld	s1,24(sp)
    80002880:	6942                	ld	s2,16(sp)
    80002882:	69a2                	ld	s3,8(sp)
    80002884:	6145                	addi	sp,sp,48
    80002886:	8082                	ret

0000000080002888 <ialloc>:
{
    80002888:	715d                	addi	sp,sp,-80
    8000288a:	e486                	sd	ra,72(sp)
    8000288c:	e0a2                	sd	s0,64(sp)
    8000288e:	fc26                	sd	s1,56(sp)
    80002890:	f84a                	sd	s2,48(sp)
    80002892:	f44e                	sd	s3,40(sp)
    80002894:	f052                	sd	s4,32(sp)
    80002896:	ec56                	sd	s5,24(sp)
    80002898:	e85a                	sd	s6,16(sp)
    8000289a:	e45e                	sd	s7,8(sp)
    8000289c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000289e:	00014717          	auipc	a4,0x14
    800028a2:	93672703          	lw	a4,-1738(a4) # 800161d4 <sb+0xc>
    800028a6:	4785                	li	a5,1
    800028a8:	04e7f663          	bgeu	a5,a4,800028f4 <ialloc+0x6c>
    800028ac:	8aaa                	mv	s5,a0
    800028ae:	8bae                	mv	s7,a1
    800028b0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800028b2:	00014a17          	auipc	s4,0x14
    800028b6:	916a0a13          	addi	s4,s4,-1770 # 800161c8 <sb>
    800028ba:	00048b1b          	sext.w	s6,s1
    800028be:	0044d593          	srli	a1,s1,0x4
    800028c2:	018a2783          	lw	a5,24(s4)
    800028c6:	9dbd                	addw	a1,a1,a5
    800028c8:	8556                	mv	a0,s5
    800028ca:	a0dff0ef          	jal	ra,800022d6 <bread>
    800028ce:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800028d0:	05850993          	addi	s3,a0,88
    800028d4:	00f4f793          	andi	a5,s1,15
    800028d8:	079a                	slli	a5,a5,0x6
    800028da:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800028dc:	00099783          	lh	a5,0(s3)
    800028e0:	cf85                	beqz	a5,80002918 <ialloc+0x90>
    brelse(bp);
    800028e2:	afdff0ef          	jal	ra,800023de <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800028e6:	0485                	addi	s1,s1,1
    800028e8:	00ca2703          	lw	a4,12(s4)
    800028ec:	0004879b          	sext.w	a5,s1
    800028f0:	fce7e5e3          	bltu	a5,a4,800028ba <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800028f4:	00005517          	auipc	a0,0x5
    800028f8:	e0c50513          	addi	a0,a0,-500 # 80007700 <syscalls+0x1d0>
    800028fc:	2c3020ef          	jal	ra,800053be <printf>
  return 0;
    80002900:	4501                	li	a0,0
}
    80002902:	60a6                	ld	ra,72(sp)
    80002904:	6406                	ld	s0,64(sp)
    80002906:	74e2                	ld	s1,56(sp)
    80002908:	7942                	ld	s2,48(sp)
    8000290a:	79a2                	ld	s3,40(sp)
    8000290c:	7a02                	ld	s4,32(sp)
    8000290e:	6ae2                	ld	s5,24(sp)
    80002910:	6b42                	ld	s6,16(sp)
    80002912:	6ba2                	ld	s7,8(sp)
    80002914:	6161                	addi	sp,sp,80
    80002916:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002918:	04000613          	li	a2,64
    8000291c:	4581                	li	a1,0
    8000291e:	854e                	mv	a0,s3
    80002920:	993fd0ef          	jal	ra,800002b2 <memset>
      dip->type = type;
    80002924:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002928:	854a                	mv	a0,s2
    8000292a:	2df000ef          	jal	ra,80003408 <log_write>
      brelse(bp);
    8000292e:	854a                	mv	a0,s2
    80002930:	aafff0ef          	jal	ra,800023de <brelse>
      return iget(dev, inum);
    80002934:	85da                	mv	a1,s6
    80002936:	8556                	mv	a0,s5
    80002938:	de1ff0ef          	jal	ra,80002718 <iget>
    8000293c:	b7d9                	j	80002902 <ialloc+0x7a>

000000008000293e <iupdate>:
{
    8000293e:	1101                	addi	sp,sp,-32
    80002940:	ec06                	sd	ra,24(sp)
    80002942:	e822                	sd	s0,16(sp)
    80002944:	e426                	sd	s1,8(sp)
    80002946:	e04a                	sd	s2,0(sp)
    80002948:	1000                	addi	s0,sp,32
    8000294a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000294c:	415c                	lw	a5,4(a0)
    8000294e:	0047d79b          	srliw	a5,a5,0x4
    80002952:	00014597          	auipc	a1,0x14
    80002956:	88e5a583          	lw	a1,-1906(a1) # 800161e0 <sb+0x18>
    8000295a:	9dbd                	addw	a1,a1,a5
    8000295c:	4108                	lw	a0,0(a0)
    8000295e:	979ff0ef          	jal	ra,800022d6 <bread>
    80002962:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002964:	05850793          	addi	a5,a0,88
    80002968:	40d8                	lw	a4,4(s1)
    8000296a:	8b3d                	andi	a4,a4,15
    8000296c:	071a                	slli	a4,a4,0x6
    8000296e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002970:	04449703          	lh	a4,68(s1)
    80002974:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002978:	04649703          	lh	a4,70(s1)
    8000297c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002980:	04849703          	lh	a4,72(s1)
    80002984:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002988:	04a49703          	lh	a4,74(s1)
    8000298c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002990:	44f8                	lw	a4,76(s1)
    80002992:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002994:	03400613          	li	a2,52
    80002998:	05048593          	addi	a1,s1,80
    8000299c:	00c78513          	addi	a0,a5,12
    800029a0:	96ffd0ef          	jal	ra,8000030e <memmove>
  log_write(bp);
    800029a4:	854a                	mv	a0,s2
    800029a6:	263000ef          	jal	ra,80003408 <log_write>
  brelse(bp);
    800029aa:	854a                	mv	a0,s2
    800029ac:	a33ff0ef          	jal	ra,800023de <brelse>
}
    800029b0:	60e2                	ld	ra,24(sp)
    800029b2:	6442                	ld	s0,16(sp)
    800029b4:	64a2                	ld	s1,8(sp)
    800029b6:	6902                	ld	s2,0(sp)
    800029b8:	6105                	addi	sp,sp,32
    800029ba:	8082                	ret

00000000800029bc <idup>:
{
    800029bc:	1101                	addi	sp,sp,-32
    800029be:	ec06                	sd	ra,24(sp)
    800029c0:	e822                	sd	s0,16(sp)
    800029c2:	e426                	sd	s1,8(sp)
    800029c4:	1000                	addi	s0,sp,32
    800029c6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800029c8:	00014517          	auipc	a0,0x14
    800029cc:	82050513          	addi	a0,a0,-2016 # 800161e8 <itable>
    800029d0:	7b3020ef          	jal	ra,80005982 <acquire>
  ip->ref++;
    800029d4:	449c                	lw	a5,8(s1)
    800029d6:	2785                	addiw	a5,a5,1
    800029d8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800029da:	00014517          	auipc	a0,0x14
    800029de:	80e50513          	addi	a0,a0,-2034 # 800161e8 <itable>
    800029e2:	038030ef          	jal	ra,80005a1a <release>
}
    800029e6:	8526                	mv	a0,s1
    800029e8:	60e2                	ld	ra,24(sp)
    800029ea:	6442                	ld	s0,16(sp)
    800029ec:	64a2                	ld	s1,8(sp)
    800029ee:	6105                	addi	sp,sp,32
    800029f0:	8082                	ret

00000000800029f2 <ilock>:
{
    800029f2:	1101                	addi	sp,sp,-32
    800029f4:	ec06                	sd	ra,24(sp)
    800029f6:	e822                	sd	s0,16(sp)
    800029f8:	e426                	sd	s1,8(sp)
    800029fa:	e04a                	sd	s2,0(sp)
    800029fc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800029fe:	c105                	beqz	a0,80002a1e <ilock+0x2c>
    80002a00:	84aa                	mv	s1,a0
    80002a02:	451c                	lw	a5,8(a0)
    80002a04:	00f05d63          	blez	a5,80002a1e <ilock+0x2c>
  acquiresleep(&ip->lock);
    80002a08:	0541                	addi	a0,a0,16
    80002a0a:	305000ef          	jal	ra,8000350e <acquiresleep>
  if(ip->valid == 0){
    80002a0e:	40bc                	lw	a5,64(s1)
    80002a10:	cf89                	beqz	a5,80002a2a <ilock+0x38>
}
    80002a12:	60e2                	ld	ra,24(sp)
    80002a14:	6442                	ld	s0,16(sp)
    80002a16:	64a2                	ld	s1,8(sp)
    80002a18:	6902                	ld	s2,0(sp)
    80002a1a:	6105                	addi	sp,sp,32
    80002a1c:	8082                	ret
    panic("ilock");
    80002a1e:	00005517          	auipc	a0,0x5
    80002a22:	cfa50513          	addi	a0,a0,-774 # 80007718 <syscalls+0x1e8>
    80002a26:	44d020ef          	jal	ra,80005672 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002a2a:	40dc                	lw	a5,4(s1)
    80002a2c:	0047d79b          	srliw	a5,a5,0x4
    80002a30:	00013597          	auipc	a1,0x13
    80002a34:	7b05a583          	lw	a1,1968(a1) # 800161e0 <sb+0x18>
    80002a38:	9dbd                	addw	a1,a1,a5
    80002a3a:	4088                	lw	a0,0(s1)
    80002a3c:	89bff0ef          	jal	ra,800022d6 <bread>
    80002a40:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002a42:	05850593          	addi	a1,a0,88
    80002a46:	40dc                	lw	a5,4(s1)
    80002a48:	8bbd                	andi	a5,a5,15
    80002a4a:	079a                	slli	a5,a5,0x6
    80002a4c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002a4e:	00059783          	lh	a5,0(a1)
    80002a52:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002a56:	00259783          	lh	a5,2(a1)
    80002a5a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002a5e:	00459783          	lh	a5,4(a1)
    80002a62:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002a66:	00659783          	lh	a5,6(a1)
    80002a6a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002a6e:	459c                	lw	a5,8(a1)
    80002a70:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002a72:	03400613          	li	a2,52
    80002a76:	05b1                	addi	a1,a1,12
    80002a78:	05048513          	addi	a0,s1,80
    80002a7c:	893fd0ef          	jal	ra,8000030e <memmove>
    brelse(bp);
    80002a80:	854a                	mv	a0,s2
    80002a82:	95dff0ef          	jal	ra,800023de <brelse>
    ip->valid = 1;
    80002a86:	4785                	li	a5,1
    80002a88:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002a8a:	04449783          	lh	a5,68(s1)
    80002a8e:	f3d1                	bnez	a5,80002a12 <ilock+0x20>
      panic("ilock: no type");
    80002a90:	00005517          	auipc	a0,0x5
    80002a94:	c9050513          	addi	a0,a0,-880 # 80007720 <syscalls+0x1f0>
    80002a98:	3db020ef          	jal	ra,80005672 <panic>

0000000080002a9c <iunlock>:
{
    80002a9c:	1101                	addi	sp,sp,-32
    80002a9e:	ec06                	sd	ra,24(sp)
    80002aa0:	e822                	sd	s0,16(sp)
    80002aa2:	e426                	sd	s1,8(sp)
    80002aa4:	e04a                	sd	s2,0(sp)
    80002aa6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002aa8:	c505                	beqz	a0,80002ad0 <iunlock+0x34>
    80002aaa:	84aa                	mv	s1,a0
    80002aac:	01050913          	addi	s2,a0,16
    80002ab0:	854a                	mv	a0,s2
    80002ab2:	2db000ef          	jal	ra,8000358c <holdingsleep>
    80002ab6:	cd09                	beqz	a0,80002ad0 <iunlock+0x34>
    80002ab8:	449c                	lw	a5,8(s1)
    80002aba:	00f05b63          	blez	a5,80002ad0 <iunlock+0x34>
  releasesleep(&ip->lock);
    80002abe:	854a                	mv	a0,s2
    80002ac0:	295000ef          	jal	ra,80003554 <releasesleep>
}
    80002ac4:	60e2                	ld	ra,24(sp)
    80002ac6:	6442                	ld	s0,16(sp)
    80002ac8:	64a2                	ld	s1,8(sp)
    80002aca:	6902                	ld	s2,0(sp)
    80002acc:	6105                	addi	sp,sp,32
    80002ace:	8082                	ret
    panic("iunlock");
    80002ad0:	00005517          	auipc	a0,0x5
    80002ad4:	c6050513          	addi	a0,a0,-928 # 80007730 <syscalls+0x200>
    80002ad8:	39b020ef          	jal	ra,80005672 <panic>

0000000080002adc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002adc:	7179                	addi	sp,sp,-48
    80002ade:	f406                	sd	ra,40(sp)
    80002ae0:	f022                	sd	s0,32(sp)
    80002ae2:	ec26                	sd	s1,24(sp)
    80002ae4:	e84a                	sd	s2,16(sp)
    80002ae6:	e44e                	sd	s3,8(sp)
    80002ae8:	e052                	sd	s4,0(sp)
    80002aea:	1800                	addi	s0,sp,48
    80002aec:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002aee:	05050493          	addi	s1,a0,80
    80002af2:	08050913          	addi	s2,a0,128
    80002af6:	a021                	j	80002afe <itrunc+0x22>
    80002af8:	0491                	addi	s1,s1,4
    80002afa:	01248b63          	beq	s1,s2,80002b10 <itrunc+0x34>
    if(ip->addrs[i]){
    80002afe:	408c                	lw	a1,0(s1)
    80002b00:	dde5                	beqz	a1,80002af8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002b02:	0009a503          	lw	a0,0(s3)
    80002b06:	9cbff0ef          	jal	ra,800024d0 <bfree>
      ip->addrs[i] = 0;
    80002b0a:	0004a023          	sw	zero,0(s1)
    80002b0e:	b7ed                	j	80002af8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002b10:	0809a583          	lw	a1,128(s3)
    80002b14:	ed91                	bnez	a1,80002b30 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002b16:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002b1a:	854e                	mv	a0,s3
    80002b1c:	e23ff0ef          	jal	ra,8000293e <iupdate>
}
    80002b20:	70a2                	ld	ra,40(sp)
    80002b22:	7402                	ld	s0,32(sp)
    80002b24:	64e2                	ld	s1,24(sp)
    80002b26:	6942                	ld	s2,16(sp)
    80002b28:	69a2                	ld	s3,8(sp)
    80002b2a:	6a02                	ld	s4,0(sp)
    80002b2c:	6145                	addi	sp,sp,48
    80002b2e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002b30:	0009a503          	lw	a0,0(s3)
    80002b34:	fa2ff0ef          	jal	ra,800022d6 <bread>
    80002b38:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002b3a:	05850493          	addi	s1,a0,88
    80002b3e:	45850913          	addi	s2,a0,1112
    80002b42:	a021                	j	80002b4a <itrunc+0x6e>
    80002b44:	0491                	addi	s1,s1,4
    80002b46:	01248963          	beq	s1,s2,80002b58 <itrunc+0x7c>
      if(a[j])
    80002b4a:	408c                	lw	a1,0(s1)
    80002b4c:	dde5                	beqz	a1,80002b44 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80002b4e:	0009a503          	lw	a0,0(s3)
    80002b52:	97fff0ef          	jal	ra,800024d0 <bfree>
    80002b56:	b7fd                	j	80002b44 <itrunc+0x68>
    brelse(bp);
    80002b58:	8552                	mv	a0,s4
    80002b5a:	885ff0ef          	jal	ra,800023de <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002b5e:	0809a583          	lw	a1,128(s3)
    80002b62:	0009a503          	lw	a0,0(s3)
    80002b66:	96bff0ef          	jal	ra,800024d0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002b6a:	0809a023          	sw	zero,128(s3)
    80002b6e:	b765                	j	80002b16 <itrunc+0x3a>

0000000080002b70 <iput>:
{
    80002b70:	1101                	addi	sp,sp,-32
    80002b72:	ec06                	sd	ra,24(sp)
    80002b74:	e822                	sd	s0,16(sp)
    80002b76:	e426                	sd	s1,8(sp)
    80002b78:	e04a                	sd	s2,0(sp)
    80002b7a:	1000                	addi	s0,sp,32
    80002b7c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002b7e:	00013517          	auipc	a0,0x13
    80002b82:	66a50513          	addi	a0,a0,1642 # 800161e8 <itable>
    80002b86:	5fd020ef          	jal	ra,80005982 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002b8a:	4498                	lw	a4,8(s1)
    80002b8c:	4785                	li	a5,1
    80002b8e:	02f70163          	beq	a4,a5,80002bb0 <iput+0x40>
  ip->ref--;
    80002b92:	449c                	lw	a5,8(s1)
    80002b94:	37fd                	addiw	a5,a5,-1
    80002b96:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002b98:	00013517          	auipc	a0,0x13
    80002b9c:	65050513          	addi	a0,a0,1616 # 800161e8 <itable>
    80002ba0:	67b020ef          	jal	ra,80005a1a <release>
}
    80002ba4:	60e2                	ld	ra,24(sp)
    80002ba6:	6442                	ld	s0,16(sp)
    80002ba8:	64a2                	ld	s1,8(sp)
    80002baa:	6902                	ld	s2,0(sp)
    80002bac:	6105                	addi	sp,sp,32
    80002bae:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002bb0:	40bc                	lw	a5,64(s1)
    80002bb2:	d3e5                	beqz	a5,80002b92 <iput+0x22>
    80002bb4:	04a49783          	lh	a5,74(s1)
    80002bb8:	ffe9                	bnez	a5,80002b92 <iput+0x22>
    acquiresleep(&ip->lock);
    80002bba:	01048913          	addi	s2,s1,16
    80002bbe:	854a                	mv	a0,s2
    80002bc0:	14f000ef          	jal	ra,8000350e <acquiresleep>
    release(&itable.lock);
    80002bc4:	00013517          	auipc	a0,0x13
    80002bc8:	62450513          	addi	a0,a0,1572 # 800161e8 <itable>
    80002bcc:	64f020ef          	jal	ra,80005a1a <release>
    itrunc(ip);
    80002bd0:	8526                	mv	a0,s1
    80002bd2:	f0bff0ef          	jal	ra,80002adc <itrunc>
    ip->type = 0;
    80002bd6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002bda:	8526                	mv	a0,s1
    80002bdc:	d63ff0ef          	jal	ra,8000293e <iupdate>
    ip->valid = 0;
    80002be0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002be4:	854a                	mv	a0,s2
    80002be6:	16f000ef          	jal	ra,80003554 <releasesleep>
    acquire(&itable.lock);
    80002bea:	00013517          	auipc	a0,0x13
    80002bee:	5fe50513          	addi	a0,a0,1534 # 800161e8 <itable>
    80002bf2:	591020ef          	jal	ra,80005982 <acquire>
    80002bf6:	bf71                	j	80002b92 <iput+0x22>

0000000080002bf8 <iunlockput>:
{
    80002bf8:	1101                	addi	sp,sp,-32
    80002bfa:	ec06                	sd	ra,24(sp)
    80002bfc:	e822                	sd	s0,16(sp)
    80002bfe:	e426                	sd	s1,8(sp)
    80002c00:	1000                	addi	s0,sp,32
    80002c02:	84aa                	mv	s1,a0
  iunlock(ip);
    80002c04:	e99ff0ef          	jal	ra,80002a9c <iunlock>
  iput(ip);
    80002c08:	8526                	mv	a0,s1
    80002c0a:	f67ff0ef          	jal	ra,80002b70 <iput>
}
    80002c0e:	60e2                	ld	ra,24(sp)
    80002c10:	6442                	ld	s0,16(sp)
    80002c12:	64a2                	ld	s1,8(sp)
    80002c14:	6105                	addi	sp,sp,32
    80002c16:	8082                	ret

0000000080002c18 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002c18:	1141                	addi	sp,sp,-16
    80002c1a:	e422                	sd	s0,8(sp)
    80002c1c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002c1e:	411c                	lw	a5,0(a0)
    80002c20:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002c22:	415c                	lw	a5,4(a0)
    80002c24:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002c26:	04451783          	lh	a5,68(a0)
    80002c2a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002c2e:	04a51783          	lh	a5,74(a0)
    80002c32:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002c36:	04c56783          	lwu	a5,76(a0)
    80002c3a:	e99c                	sd	a5,16(a1)
}
    80002c3c:	6422                	ld	s0,8(sp)
    80002c3e:	0141                	addi	sp,sp,16
    80002c40:	8082                	ret

0000000080002c42 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002c42:	457c                	lw	a5,76(a0)
    80002c44:	0cd7ef63          	bltu	a5,a3,80002d22 <readi+0xe0>
{
    80002c48:	7159                	addi	sp,sp,-112
    80002c4a:	f486                	sd	ra,104(sp)
    80002c4c:	f0a2                	sd	s0,96(sp)
    80002c4e:	eca6                	sd	s1,88(sp)
    80002c50:	e8ca                	sd	s2,80(sp)
    80002c52:	e4ce                	sd	s3,72(sp)
    80002c54:	e0d2                	sd	s4,64(sp)
    80002c56:	fc56                	sd	s5,56(sp)
    80002c58:	f85a                	sd	s6,48(sp)
    80002c5a:	f45e                	sd	s7,40(sp)
    80002c5c:	f062                	sd	s8,32(sp)
    80002c5e:	ec66                	sd	s9,24(sp)
    80002c60:	e86a                	sd	s10,16(sp)
    80002c62:	e46e                	sd	s11,8(sp)
    80002c64:	1880                	addi	s0,sp,112
    80002c66:	8b2a                	mv	s6,a0
    80002c68:	8bae                	mv	s7,a1
    80002c6a:	8a32                	mv	s4,a2
    80002c6c:	84b6                	mv	s1,a3
    80002c6e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002c70:	9f35                	addw	a4,a4,a3
    return 0;
    80002c72:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002c74:	08d76663          	bltu	a4,a3,80002d00 <readi+0xbe>
  if(off + n > ip->size)
    80002c78:	00e7f463          	bgeu	a5,a4,80002c80 <readi+0x3e>
    n = ip->size - off;
    80002c7c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002c80:	080a8f63          	beqz	s5,80002d1e <readi+0xdc>
    80002c84:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002c86:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002c8a:	5c7d                	li	s8,-1
    80002c8c:	a80d                	j	80002cbe <readi+0x7c>
    80002c8e:	020d1d93          	slli	s11,s10,0x20
    80002c92:	020ddd93          	srli	s11,s11,0x20
    80002c96:	05890613          	addi	a2,s2,88
    80002c9a:	86ee                	mv	a3,s11
    80002c9c:	963a                	add	a2,a2,a4
    80002c9e:	85d2                	mv	a1,s4
    80002ca0:	855e                	mv	a0,s7
    80002ca2:	d6bfe0ef          	jal	ra,80001a0c <either_copyout>
    80002ca6:	05850763          	beq	a0,s8,80002cf4 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002caa:	854a                	mv	a0,s2
    80002cac:	f32ff0ef          	jal	ra,800023de <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002cb0:	013d09bb          	addw	s3,s10,s3
    80002cb4:	009d04bb          	addw	s1,s10,s1
    80002cb8:	9a6e                	add	s4,s4,s11
    80002cba:	0559f163          	bgeu	s3,s5,80002cfc <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80002cbe:	00a4d59b          	srliw	a1,s1,0xa
    80002cc2:	855a                	mv	a0,s6
    80002cc4:	987ff0ef          	jal	ra,8000264a <bmap>
    80002cc8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002ccc:	c985                	beqz	a1,80002cfc <readi+0xba>
    bp = bread(ip->dev, addr);
    80002cce:	000b2503          	lw	a0,0(s6)
    80002cd2:	e04ff0ef          	jal	ra,800022d6 <bread>
    80002cd6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002cd8:	3ff4f713          	andi	a4,s1,1023
    80002cdc:	40ec87bb          	subw	a5,s9,a4
    80002ce0:	413a86bb          	subw	a3,s5,s3
    80002ce4:	8d3e                	mv	s10,a5
    80002ce6:	2781                	sext.w	a5,a5
    80002ce8:	0006861b          	sext.w	a2,a3
    80002cec:	faf671e3          	bgeu	a2,a5,80002c8e <readi+0x4c>
    80002cf0:	8d36                	mv	s10,a3
    80002cf2:	bf71                	j	80002c8e <readi+0x4c>
      brelse(bp);
    80002cf4:	854a                	mv	a0,s2
    80002cf6:	ee8ff0ef          	jal	ra,800023de <brelse>
      tot = -1;
    80002cfa:	59fd                	li	s3,-1
  }
  return tot;
    80002cfc:	0009851b          	sext.w	a0,s3
}
    80002d00:	70a6                	ld	ra,104(sp)
    80002d02:	7406                	ld	s0,96(sp)
    80002d04:	64e6                	ld	s1,88(sp)
    80002d06:	6946                	ld	s2,80(sp)
    80002d08:	69a6                	ld	s3,72(sp)
    80002d0a:	6a06                	ld	s4,64(sp)
    80002d0c:	7ae2                	ld	s5,56(sp)
    80002d0e:	7b42                	ld	s6,48(sp)
    80002d10:	7ba2                	ld	s7,40(sp)
    80002d12:	7c02                	ld	s8,32(sp)
    80002d14:	6ce2                	ld	s9,24(sp)
    80002d16:	6d42                	ld	s10,16(sp)
    80002d18:	6da2                	ld	s11,8(sp)
    80002d1a:	6165                	addi	sp,sp,112
    80002d1c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002d1e:	89d6                	mv	s3,s5
    80002d20:	bff1                	j	80002cfc <readi+0xba>
    return 0;
    80002d22:	4501                	li	a0,0
}
    80002d24:	8082                	ret

0000000080002d26 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002d26:	457c                	lw	a5,76(a0)
    80002d28:	0ed7ea63          	bltu	a5,a3,80002e1c <writei+0xf6>
{
    80002d2c:	7159                	addi	sp,sp,-112
    80002d2e:	f486                	sd	ra,104(sp)
    80002d30:	f0a2                	sd	s0,96(sp)
    80002d32:	eca6                	sd	s1,88(sp)
    80002d34:	e8ca                	sd	s2,80(sp)
    80002d36:	e4ce                	sd	s3,72(sp)
    80002d38:	e0d2                	sd	s4,64(sp)
    80002d3a:	fc56                	sd	s5,56(sp)
    80002d3c:	f85a                	sd	s6,48(sp)
    80002d3e:	f45e                	sd	s7,40(sp)
    80002d40:	f062                	sd	s8,32(sp)
    80002d42:	ec66                	sd	s9,24(sp)
    80002d44:	e86a                	sd	s10,16(sp)
    80002d46:	e46e                	sd	s11,8(sp)
    80002d48:	1880                	addi	s0,sp,112
    80002d4a:	8aaa                	mv	s5,a0
    80002d4c:	8bae                	mv	s7,a1
    80002d4e:	8a32                	mv	s4,a2
    80002d50:	8936                	mv	s2,a3
    80002d52:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002d54:	00e687bb          	addw	a5,a3,a4
    80002d58:	0cd7e463          	bltu	a5,a3,80002e20 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002d5c:	00043737          	lui	a4,0x43
    80002d60:	0cf76263          	bltu	a4,a5,80002e24 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002d64:	0a0b0a63          	beqz	s6,80002e18 <writei+0xf2>
    80002d68:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002d6a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002d6e:	5c7d                	li	s8,-1
    80002d70:	a825                	j	80002da8 <writei+0x82>
    80002d72:	020d1d93          	slli	s11,s10,0x20
    80002d76:	020ddd93          	srli	s11,s11,0x20
    80002d7a:	05848513          	addi	a0,s1,88
    80002d7e:	86ee                	mv	a3,s11
    80002d80:	8652                	mv	a2,s4
    80002d82:	85de                	mv	a1,s7
    80002d84:	953a                	add	a0,a0,a4
    80002d86:	cd1fe0ef          	jal	ra,80001a56 <either_copyin>
    80002d8a:	05850a63          	beq	a0,s8,80002dde <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002d8e:	8526                	mv	a0,s1
    80002d90:	678000ef          	jal	ra,80003408 <log_write>
    brelse(bp);
    80002d94:	8526                	mv	a0,s1
    80002d96:	e48ff0ef          	jal	ra,800023de <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002d9a:	013d09bb          	addw	s3,s10,s3
    80002d9e:	012d093b          	addw	s2,s10,s2
    80002da2:	9a6e                	add	s4,s4,s11
    80002da4:	0569f063          	bgeu	s3,s6,80002de4 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002da8:	00a9559b          	srliw	a1,s2,0xa
    80002dac:	8556                	mv	a0,s5
    80002dae:	89dff0ef          	jal	ra,8000264a <bmap>
    80002db2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002db6:	c59d                	beqz	a1,80002de4 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002db8:	000aa503          	lw	a0,0(s5)
    80002dbc:	d1aff0ef          	jal	ra,800022d6 <bread>
    80002dc0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002dc2:	3ff97713          	andi	a4,s2,1023
    80002dc6:	40ec87bb          	subw	a5,s9,a4
    80002dca:	413b06bb          	subw	a3,s6,s3
    80002dce:	8d3e                	mv	s10,a5
    80002dd0:	2781                	sext.w	a5,a5
    80002dd2:	0006861b          	sext.w	a2,a3
    80002dd6:	f8f67ee3          	bgeu	a2,a5,80002d72 <writei+0x4c>
    80002dda:	8d36                	mv	s10,a3
    80002ddc:	bf59                	j	80002d72 <writei+0x4c>
      brelse(bp);
    80002dde:	8526                	mv	a0,s1
    80002de0:	dfeff0ef          	jal	ra,800023de <brelse>
  }

  if(off > ip->size)
    80002de4:	04caa783          	lw	a5,76(s5)
    80002de8:	0127f463          	bgeu	a5,s2,80002df0 <writei+0xca>
    ip->size = off;
    80002dec:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002df0:	8556                	mv	a0,s5
    80002df2:	b4dff0ef          	jal	ra,8000293e <iupdate>

  return tot;
    80002df6:	0009851b          	sext.w	a0,s3
}
    80002dfa:	70a6                	ld	ra,104(sp)
    80002dfc:	7406                	ld	s0,96(sp)
    80002dfe:	64e6                	ld	s1,88(sp)
    80002e00:	6946                	ld	s2,80(sp)
    80002e02:	69a6                	ld	s3,72(sp)
    80002e04:	6a06                	ld	s4,64(sp)
    80002e06:	7ae2                	ld	s5,56(sp)
    80002e08:	7b42                	ld	s6,48(sp)
    80002e0a:	7ba2                	ld	s7,40(sp)
    80002e0c:	7c02                	ld	s8,32(sp)
    80002e0e:	6ce2                	ld	s9,24(sp)
    80002e10:	6d42                	ld	s10,16(sp)
    80002e12:	6da2                	ld	s11,8(sp)
    80002e14:	6165                	addi	sp,sp,112
    80002e16:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002e18:	89da                	mv	s3,s6
    80002e1a:	bfd9                	j	80002df0 <writei+0xca>
    return -1;
    80002e1c:	557d                	li	a0,-1
}
    80002e1e:	8082                	ret
    return -1;
    80002e20:	557d                	li	a0,-1
    80002e22:	bfe1                	j	80002dfa <writei+0xd4>
    return -1;
    80002e24:	557d                	li	a0,-1
    80002e26:	bfd1                	j	80002dfa <writei+0xd4>

0000000080002e28 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002e28:	1141                	addi	sp,sp,-16
    80002e2a:	e406                	sd	ra,8(sp)
    80002e2c:	e022                	sd	s0,0(sp)
    80002e2e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002e30:	4639                	li	a2,14
    80002e32:	d4cfd0ef          	jal	ra,8000037e <strncmp>
}
    80002e36:	60a2                	ld	ra,8(sp)
    80002e38:	6402                	ld	s0,0(sp)
    80002e3a:	0141                	addi	sp,sp,16
    80002e3c:	8082                	ret

0000000080002e3e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002e3e:	7139                	addi	sp,sp,-64
    80002e40:	fc06                	sd	ra,56(sp)
    80002e42:	f822                	sd	s0,48(sp)
    80002e44:	f426                	sd	s1,40(sp)
    80002e46:	f04a                	sd	s2,32(sp)
    80002e48:	ec4e                	sd	s3,24(sp)
    80002e4a:	e852                	sd	s4,16(sp)
    80002e4c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002e4e:	04451703          	lh	a4,68(a0)
    80002e52:	4785                	li	a5,1
    80002e54:	00f71a63          	bne	a4,a5,80002e68 <dirlookup+0x2a>
    80002e58:	892a                	mv	s2,a0
    80002e5a:	89ae                	mv	s3,a1
    80002e5c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e5e:	457c                	lw	a5,76(a0)
    80002e60:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002e62:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e64:	e39d                	bnez	a5,80002e8a <dirlookup+0x4c>
    80002e66:	a095                	j	80002eca <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002e68:	00005517          	auipc	a0,0x5
    80002e6c:	8d050513          	addi	a0,a0,-1840 # 80007738 <syscalls+0x208>
    80002e70:	003020ef          	jal	ra,80005672 <panic>
      panic("dirlookup read");
    80002e74:	00005517          	auipc	a0,0x5
    80002e78:	8dc50513          	addi	a0,a0,-1828 # 80007750 <syscalls+0x220>
    80002e7c:	7f6020ef          	jal	ra,80005672 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e80:	24c1                	addiw	s1,s1,16
    80002e82:	04c92783          	lw	a5,76(s2)
    80002e86:	04f4f163          	bgeu	s1,a5,80002ec8 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002e8a:	4741                	li	a4,16
    80002e8c:	86a6                	mv	a3,s1
    80002e8e:	fc040613          	addi	a2,s0,-64
    80002e92:	4581                	li	a1,0
    80002e94:	854a                	mv	a0,s2
    80002e96:	dadff0ef          	jal	ra,80002c42 <readi>
    80002e9a:	47c1                	li	a5,16
    80002e9c:	fcf51ce3          	bne	a0,a5,80002e74 <dirlookup+0x36>
    if(de.inum == 0)
    80002ea0:	fc045783          	lhu	a5,-64(s0)
    80002ea4:	dff1                	beqz	a5,80002e80 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002ea6:	fc240593          	addi	a1,s0,-62
    80002eaa:	854e                	mv	a0,s3
    80002eac:	f7dff0ef          	jal	ra,80002e28 <namecmp>
    80002eb0:	f961                	bnez	a0,80002e80 <dirlookup+0x42>
      if(poff)
    80002eb2:	000a0463          	beqz	s4,80002eba <dirlookup+0x7c>
        *poff = off;
    80002eb6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002eba:	fc045583          	lhu	a1,-64(s0)
    80002ebe:	00092503          	lw	a0,0(s2)
    80002ec2:	857ff0ef          	jal	ra,80002718 <iget>
    80002ec6:	a011                	j	80002eca <dirlookup+0x8c>
  return 0;
    80002ec8:	4501                	li	a0,0
}
    80002eca:	70e2                	ld	ra,56(sp)
    80002ecc:	7442                	ld	s0,48(sp)
    80002ece:	74a2                	ld	s1,40(sp)
    80002ed0:	7902                	ld	s2,32(sp)
    80002ed2:	69e2                	ld	s3,24(sp)
    80002ed4:	6a42                	ld	s4,16(sp)
    80002ed6:	6121                	addi	sp,sp,64
    80002ed8:	8082                	ret

0000000080002eda <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002eda:	711d                	addi	sp,sp,-96
    80002edc:	ec86                	sd	ra,88(sp)
    80002ede:	e8a2                	sd	s0,80(sp)
    80002ee0:	e4a6                	sd	s1,72(sp)
    80002ee2:	e0ca                	sd	s2,64(sp)
    80002ee4:	fc4e                	sd	s3,56(sp)
    80002ee6:	f852                	sd	s4,48(sp)
    80002ee8:	f456                	sd	s5,40(sp)
    80002eea:	f05a                	sd	s6,32(sp)
    80002eec:	ec5e                	sd	s7,24(sp)
    80002eee:	e862                	sd	s8,16(sp)
    80002ef0:	e466                	sd	s9,8(sp)
    80002ef2:	e06a                	sd	s10,0(sp)
    80002ef4:	1080                	addi	s0,sp,96
    80002ef6:	84aa                	mv	s1,a0
    80002ef8:	8b2e                	mv	s6,a1
    80002efa:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002efc:	00054703          	lbu	a4,0(a0)
    80002f00:	02f00793          	li	a5,47
    80002f04:	00f70f63          	beq	a4,a5,80002f22 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002f08:	9dcfe0ef          	jal	ra,800010e4 <myproc>
    80002f0c:	15053503          	ld	a0,336(a0)
    80002f10:	aadff0ef          	jal	ra,800029bc <idup>
    80002f14:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002f16:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002f1a:	4cb5                	li	s9,13
  len = path - s;
    80002f1c:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002f1e:	4c05                	li	s8,1
    80002f20:	a879                	j	80002fbe <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80002f22:	4585                	li	a1,1
    80002f24:	4505                	li	a0,1
    80002f26:	ff2ff0ef          	jal	ra,80002718 <iget>
    80002f2a:	8a2a                	mv	s4,a0
    80002f2c:	b7ed                	j	80002f16 <namex+0x3c>
      iunlockput(ip);
    80002f2e:	8552                	mv	a0,s4
    80002f30:	cc9ff0ef          	jal	ra,80002bf8 <iunlockput>
      return 0;
    80002f34:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002f36:	8552                	mv	a0,s4
    80002f38:	60e6                	ld	ra,88(sp)
    80002f3a:	6446                	ld	s0,80(sp)
    80002f3c:	64a6                	ld	s1,72(sp)
    80002f3e:	6906                	ld	s2,64(sp)
    80002f40:	79e2                	ld	s3,56(sp)
    80002f42:	7a42                	ld	s4,48(sp)
    80002f44:	7aa2                	ld	s5,40(sp)
    80002f46:	7b02                	ld	s6,32(sp)
    80002f48:	6be2                	ld	s7,24(sp)
    80002f4a:	6c42                	ld	s8,16(sp)
    80002f4c:	6ca2                	ld	s9,8(sp)
    80002f4e:	6d02                	ld	s10,0(sp)
    80002f50:	6125                	addi	sp,sp,96
    80002f52:	8082                	ret
      iunlock(ip);
    80002f54:	8552                	mv	a0,s4
    80002f56:	b47ff0ef          	jal	ra,80002a9c <iunlock>
      return ip;
    80002f5a:	bff1                	j	80002f36 <namex+0x5c>
      iunlockput(ip);
    80002f5c:	8552                	mv	a0,s4
    80002f5e:	c9bff0ef          	jal	ra,80002bf8 <iunlockput>
      return 0;
    80002f62:	8a4e                	mv	s4,s3
    80002f64:	bfc9                	j	80002f36 <namex+0x5c>
  len = path - s;
    80002f66:	40998633          	sub	a2,s3,s1
    80002f6a:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80002f6e:	09acd063          	bge	s9,s10,80002fee <namex+0x114>
    memmove(name, s, DIRSIZ);
    80002f72:	4639                	li	a2,14
    80002f74:	85a6                	mv	a1,s1
    80002f76:	8556                	mv	a0,s5
    80002f78:	b96fd0ef          	jal	ra,8000030e <memmove>
    80002f7c:	84ce                	mv	s1,s3
  while(*path == '/')
    80002f7e:	0004c783          	lbu	a5,0(s1)
    80002f82:	01279763          	bne	a5,s2,80002f90 <namex+0xb6>
    path++;
    80002f86:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002f88:	0004c783          	lbu	a5,0(s1)
    80002f8c:	ff278de3          	beq	a5,s2,80002f86 <namex+0xac>
    ilock(ip);
    80002f90:	8552                	mv	a0,s4
    80002f92:	a61ff0ef          	jal	ra,800029f2 <ilock>
    if(ip->type != T_DIR){
    80002f96:	044a1783          	lh	a5,68(s4)
    80002f9a:	f9879ae3          	bne	a5,s8,80002f2e <namex+0x54>
    if(nameiparent && *path == '\0'){
    80002f9e:	000b0563          	beqz	s6,80002fa8 <namex+0xce>
    80002fa2:	0004c783          	lbu	a5,0(s1)
    80002fa6:	d7dd                	beqz	a5,80002f54 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002fa8:	865e                	mv	a2,s7
    80002faa:	85d6                	mv	a1,s5
    80002fac:	8552                	mv	a0,s4
    80002fae:	e91ff0ef          	jal	ra,80002e3e <dirlookup>
    80002fb2:	89aa                	mv	s3,a0
    80002fb4:	d545                	beqz	a0,80002f5c <namex+0x82>
    iunlockput(ip);
    80002fb6:	8552                	mv	a0,s4
    80002fb8:	c41ff0ef          	jal	ra,80002bf8 <iunlockput>
    ip = next;
    80002fbc:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002fbe:	0004c783          	lbu	a5,0(s1)
    80002fc2:	01279763          	bne	a5,s2,80002fd0 <namex+0xf6>
    path++;
    80002fc6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002fc8:	0004c783          	lbu	a5,0(s1)
    80002fcc:	ff278de3          	beq	a5,s2,80002fc6 <namex+0xec>
  if(*path == 0)
    80002fd0:	cb8d                	beqz	a5,80003002 <namex+0x128>
  while(*path != '/' && *path != 0)
    80002fd2:	0004c783          	lbu	a5,0(s1)
    80002fd6:	89a6                	mv	s3,s1
  len = path - s;
    80002fd8:	8d5e                	mv	s10,s7
    80002fda:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80002fdc:	01278963          	beq	a5,s2,80002fee <namex+0x114>
    80002fe0:	d3d9                	beqz	a5,80002f66 <namex+0x8c>
    path++;
    80002fe2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002fe4:	0009c783          	lbu	a5,0(s3)
    80002fe8:	ff279ce3          	bne	a5,s2,80002fe0 <namex+0x106>
    80002fec:	bfad                	j	80002f66 <namex+0x8c>
    memmove(name, s, len);
    80002fee:	2601                	sext.w	a2,a2
    80002ff0:	85a6                	mv	a1,s1
    80002ff2:	8556                	mv	a0,s5
    80002ff4:	b1afd0ef          	jal	ra,8000030e <memmove>
    name[len] = 0;
    80002ff8:	9d56                	add	s10,s10,s5
    80002ffa:	000d0023          	sb	zero,0(s10)
    80002ffe:	84ce                	mv	s1,s3
    80003000:	bfbd                	j	80002f7e <namex+0xa4>
  if(nameiparent){
    80003002:	f20b0ae3          	beqz	s6,80002f36 <namex+0x5c>
    iput(ip);
    80003006:	8552                	mv	a0,s4
    80003008:	b69ff0ef          	jal	ra,80002b70 <iput>
    return 0;
    8000300c:	4a01                	li	s4,0
    8000300e:	b725                	j	80002f36 <namex+0x5c>

0000000080003010 <dirlink>:
{
    80003010:	7139                	addi	sp,sp,-64
    80003012:	fc06                	sd	ra,56(sp)
    80003014:	f822                	sd	s0,48(sp)
    80003016:	f426                	sd	s1,40(sp)
    80003018:	f04a                	sd	s2,32(sp)
    8000301a:	ec4e                	sd	s3,24(sp)
    8000301c:	e852                	sd	s4,16(sp)
    8000301e:	0080                	addi	s0,sp,64
    80003020:	892a                	mv	s2,a0
    80003022:	8a2e                	mv	s4,a1
    80003024:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003026:	4601                	li	a2,0
    80003028:	e17ff0ef          	jal	ra,80002e3e <dirlookup>
    8000302c:	e52d                	bnez	a0,80003096 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000302e:	04c92483          	lw	s1,76(s2)
    80003032:	c48d                	beqz	s1,8000305c <dirlink+0x4c>
    80003034:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003036:	4741                	li	a4,16
    80003038:	86a6                	mv	a3,s1
    8000303a:	fc040613          	addi	a2,s0,-64
    8000303e:	4581                	li	a1,0
    80003040:	854a                	mv	a0,s2
    80003042:	c01ff0ef          	jal	ra,80002c42 <readi>
    80003046:	47c1                	li	a5,16
    80003048:	04f51b63          	bne	a0,a5,8000309e <dirlink+0x8e>
    if(de.inum == 0)
    8000304c:	fc045783          	lhu	a5,-64(s0)
    80003050:	c791                	beqz	a5,8000305c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003052:	24c1                	addiw	s1,s1,16
    80003054:	04c92783          	lw	a5,76(s2)
    80003058:	fcf4efe3          	bltu	s1,a5,80003036 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    8000305c:	4639                	li	a2,14
    8000305e:	85d2                	mv	a1,s4
    80003060:	fc240513          	addi	a0,s0,-62
    80003064:	b56fd0ef          	jal	ra,800003ba <strncpy>
  de.inum = inum;
    80003068:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000306c:	4741                	li	a4,16
    8000306e:	86a6                	mv	a3,s1
    80003070:	fc040613          	addi	a2,s0,-64
    80003074:	4581                	li	a1,0
    80003076:	854a                	mv	a0,s2
    80003078:	cafff0ef          	jal	ra,80002d26 <writei>
    8000307c:	1541                	addi	a0,a0,-16
    8000307e:	00a03533          	snez	a0,a0
    80003082:	40a00533          	neg	a0,a0
}
    80003086:	70e2                	ld	ra,56(sp)
    80003088:	7442                	ld	s0,48(sp)
    8000308a:	74a2                	ld	s1,40(sp)
    8000308c:	7902                	ld	s2,32(sp)
    8000308e:	69e2                	ld	s3,24(sp)
    80003090:	6a42                	ld	s4,16(sp)
    80003092:	6121                	addi	sp,sp,64
    80003094:	8082                	ret
    iput(ip);
    80003096:	adbff0ef          	jal	ra,80002b70 <iput>
    return -1;
    8000309a:	557d                	li	a0,-1
    8000309c:	b7ed                	j	80003086 <dirlink+0x76>
      panic("dirlink read");
    8000309e:	00004517          	auipc	a0,0x4
    800030a2:	6c250513          	addi	a0,a0,1730 # 80007760 <syscalls+0x230>
    800030a6:	5cc020ef          	jal	ra,80005672 <panic>

00000000800030aa <namei>:

struct inode*
namei(char *path)
{
    800030aa:	1101                	addi	sp,sp,-32
    800030ac:	ec06                	sd	ra,24(sp)
    800030ae:	e822                	sd	s0,16(sp)
    800030b0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800030b2:	fe040613          	addi	a2,s0,-32
    800030b6:	4581                	li	a1,0
    800030b8:	e23ff0ef          	jal	ra,80002eda <namex>
}
    800030bc:	60e2                	ld	ra,24(sp)
    800030be:	6442                	ld	s0,16(sp)
    800030c0:	6105                	addi	sp,sp,32
    800030c2:	8082                	ret

00000000800030c4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800030c4:	1141                	addi	sp,sp,-16
    800030c6:	e406                	sd	ra,8(sp)
    800030c8:	e022                	sd	s0,0(sp)
    800030ca:	0800                	addi	s0,sp,16
    800030cc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800030ce:	4585                	li	a1,1
    800030d0:	e0bff0ef          	jal	ra,80002eda <namex>
}
    800030d4:	60a2                	ld	ra,8(sp)
    800030d6:	6402                	ld	s0,0(sp)
    800030d8:	0141                	addi	sp,sp,16
    800030da:	8082                	ret

00000000800030dc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800030dc:	1101                	addi	sp,sp,-32
    800030de:	ec06                	sd	ra,24(sp)
    800030e0:	e822                	sd	s0,16(sp)
    800030e2:	e426                	sd	s1,8(sp)
    800030e4:	e04a                	sd	s2,0(sp)
    800030e6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800030e8:	00015917          	auipc	s2,0x15
    800030ec:	ba890913          	addi	s2,s2,-1112 # 80017c90 <log>
    800030f0:	01892583          	lw	a1,24(s2)
    800030f4:	02892503          	lw	a0,40(s2)
    800030f8:	9deff0ef          	jal	ra,800022d6 <bread>
    800030fc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800030fe:	02c92683          	lw	a3,44(s2)
    80003102:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003104:	02d05863          	blez	a3,80003134 <write_head+0x58>
    80003108:	00015797          	auipc	a5,0x15
    8000310c:	bb878793          	addi	a5,a5,-1096 # 80017cc0 <log+0x30>
    80003110:	05c50713          	addi	a4,a0,92
    80003114:	36fd                	addiw	a3,a3,-1
    80003116:	02069613          	slli	a2,a3,0x20
    8000311a:	01e65693          	srli	a3,a2,0x1e
    8000311e:	00015617          	auipc	a2,0x15
    80003122:	ba660613          	addi	a2,a2,-1114 # 80017cc4 <log+0x34>
    80003126:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003128:	4390                	lw	a2,0(a5)
    8000312a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000312c:	0791                	addi	a5,a5,4
    8000312e:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003130:	fed79ce3          	bne	a5,a3,80003128 <write_head+0x4c>
  }
  bwrite(buf);
    80003134:	8526                	mv	a0,s1
    80003136:	a76ff0ef          	jal	ra,800023ac <bwrite>
  brelse(buf);
    8000313a:	8526                	mv	a0,s1
    8000313c:	aa2ff0ef          	jal	ra,800023de <brelse>
}
    80003140:	60e2                	ld	ra,24(sp)
    80003142:	6442                	ld	s0,16(sp)
    80003144:	64a2                	ld	s1,8(sp)
    80003146:	6902                	ld	s2,0(sp)
    80003148:	6105                	addi	sp,sp,32
    8000314a:	8082                	ret

000000008000314c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000314c:	00015797          	auipc	a5,0x15
    80003150:	b707a783          	lw	a5,-1168(a5) # 80017cbc <log+0x2c>
    80003154:	08f05f63          	blez	a5,800031f2 <install_trans+0xa6>
{
    80003158:	7139                	addi	sp,sp,-64
    8000315a:	fc06                	sd	ra,56(sp)
    8000315c:	f822                	sd	s0,48(sp)
    8000315e:	f426                	sd	s1,40(sp)
    80003160:	f04a                	sd	s2,32(sp)
    80003162:	ec4e                	sd	s3,24(sp)
    80003164:	e852                	sd	s4,16(sp)
    80003166:	e456                	sd	s5,8(sp)
    80003168:	e05a                	sd	s6,0(sp)
    8000316a:	0080                	addi	s0,sp,64
    8000316c:	8b2a                	mv	s6,a0
    8000316e:	00015a97          	auipc	s5,0x15
    80003172:	b52a8a93          	addi	s5,s5,-1198 # 80017cc0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003176:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003178:	00015997          	auipc	s3,0x15
    8000317c:	b1898993          	addi	s3,s3,-1256 # 80017c90 <log>
    80003180:	a829                	j	8000319a <install_trans+0x4e>
    brelse(lbuf);
    80003182:	854a                	mv	a0,s2
    80003184:	a5aff0ef          	jal	ra,800023de <brelse>
    brelse(dbuf);
    80003188:	8526                	mv	a0,s1
    8000318a:	a54ff0ef          	jal	ra,800023de <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000318e:	2a05                	addiw	s4,s4,1
    80003190:	0a91                	addi	s5,s5,4
    80003192:	02c9a783          	lw	a5,44(s3)
    80003196:	04fa5463          	bge	s4,a5,800031de <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000319a:	0189a583          	lw	a1,24(s3)
    8000319e:	014585bb          	addw	a1,a1,s4
    800031a2:	2585                	addiw	a1,a1,1
    800031a4:	0289a503          	lw	a0,40(s3)
    800031a8:	92eff0ef          	jal	ra,800022d6 <bread>
    800031ac:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800031ae:	000aa583          	lw	a1,0(s5)
    800031b2:	0289a503          	lw	a0,40(s3)
    800031b6:	920ff0ef          	jal	ra,800022d6 <bread>
    800031ba:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800031bc:	40000613          	li	a2,1024
    800031c0:	05890593          	addi	a1,s2,88
    800031c4:	05850513          	addi	a0,a0,88
    800031c8:	946fd0ef          	jal	ra,8000030e <memmove>
    bwrite(dbuf);  // write dst to disk
    800031cc:	8526                	mv	a0,s1
    800031ce:	9deff0ef          	jal	ra,800023ac <bwrite>
    if(recovering == 0)
    800031d2:	fa0b18e3          	bnez	s6,80003182 <install_trans+0x36>
      bunpin(dbuf);
    800031d6:	8526                	mv	a0,s1
    800031d8:	ac4ff0ef          	jal	ra,8000249c <bunpin>
    800031dc:	b75d                	j	80003182 <install_trans+0x36>
}
    800031de:	70e2                	ld	ra,56(sp)
    800031e0:	7442                	ld	s0,48(sp)
    800031e2:	74a2                	ld	s1,40(sp)
    800031e4:	7902                	ld	s2,32(sp)
    800031e6:	69e2                	ld	s3,24(sp)
    800031e8:	6a42                	ld	s4,16(sp)
    800031ea:	6aa2                	ld	s5,8(sp)
    800031ec:	6b02                	ld	s6,0(sp)
    800031ee:	6121                	addi	sp,sp,64
    800031f0:	8082                	ret
    800031f2:	8082                	ret

00000000800031f4 <initlog>:
{
    800031f4:	7179                	addi	sp,sp,-48
    800031f6:	f406                	sd	ra,40(sp)
    800031f8:	f022                	sd	s0,32(sp)
    800031fa:	ec26                	sd	s1,24(sp)
    800031fc:	e84a                	sd	s2,16(sp)
    800031fe:	e44e                	sd	s3,8(sp)
    80003200:	1800                	addi	s0,sp,48
    80003202:	892a                	mv	s2,a0
    80003204:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003206:	00015497          	auipc	s1,0x15
    8000320a:	a8a48493          	addi	s1,s1,-1398 # 80017c90 <log>
    8000320e:	00004597          	auipc	a1,0x4
    80003212:	56258593          	addi	a1,a1,1378 # 80007770 <syscalls+0x240>
    80003216:	8526                	mv	a0,s1
    80003218:	6ea020ef          	jal	ra,80005902 <initlock>
  log.start = sb->logstart;
    8000321c:	0149a583          	lw	a1,20(s3)
    80003220:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003222:	0109a783          	lw	a5,16(s3)
    80003226:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003228:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000322c:	854a                	mv	a0,s2
    8000322e:	8a8ff0ef          	jal	ra,800022d6 <bread>
  log.lh.n = lh->n;
    80003232:	4d34                	lw	a3,88(a0)
    80003234:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003236:	02d05663          	blez	a3,80003262 <initlog+0x6e>
    8000323a:	05c50793          	addi	a5,a0,92
    8000323e:	00015717          	auipc	a4,0x15
    80003242:	a8270713          	addi	a4,a4,-1406 # 80017cc0 <log+0x30>
    80003246:	36fd                	addiw	a3,a3,-1
    80003248:	02069613          	slli	a2,a3,0x20
    8000324c:	01e65693          	srli	a3,a2,0x1e
    80003250:	06050613          	addi	a2,a0,96
    80003254:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003256:	4390                	lw	a2,0(a5)
    80003258:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000325a:	0791                	addi	a5,a5,4
    8000325c:	0711                	addi	a4,a4,4
    8000325e:	fed79ce3          	bne	a5,a3,80003256 <initlog+0x62>
  brelse(buf);
    80003262:	97cff0ef          	jal	ra,800023de <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003266:	4505                	li	a0,1
    80003268:	ee5ff0ef          	jal	ra,8000314c <install_trans>
  log.lh.n = 0;
    8000326c:	00015797          	auipc	a5,0x15
    80003270:	a407a823          	sw	zero,-1456(a5) # 80017cbc <log+0x2c>
  write_head(); // clear the log
    80003274:	e69ff0ef          	jal	ra,800030dc <write_head>
}
    80003278:	70a2                	ld	ra,40(sp)
    8000327a:	7402                	ld	s0,32(sp)
    8000327c:	64e2                	ld	s1,24(sp)
    8000327e:	6942                	ld	s2,16(sp)
    80003280:	69a2                	ld	s3,8(sp)
    80003282:	6145                	addi	sp,sp,48
    80003284:	8082                	ret

0000000080003286 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003286:	1101                	addi	sp,sp,-32
    80003288:	ec06                	sd	ra,24(sp)
    8000328a:	e822                	sd	s0,16(sp)
    8000328c:	e426                	sd	s1,8(sp)
    8000328e:	e04a                	sd	s2,0(sp)
    80003290:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003292:	00015517          	auipc	a0,0x15
    80003296:	9fe50513          	addi	a0,a0,-1538 # 80017c90 <log>
    8000329a:	6e8020ef          	jal	ra,80005982 <acquire>
  while(1){
    if(log.committing){
    8000329e:	00015497          	auipc	s1,0x15
    800032a2:	9f248493          	addi	s1,s1,-1550 # 80017c90 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800032a6:	4979                	li	s2,30
    800032a8:	a029                	j	800032b2 <begin_op+0x2c>
      sleep(&log, &log.lock);
    800032aa:	85a6                	mv	a1,s1
    800032ac:	8526                	mv	a0,s1
    800032ae:	c02fe0ef          	jal	ra,800016b0 <sleep>
    if(log.committing){
    800032b2:	50dc                	lw	a5,36(s1)
    800032b4:	fbfd                	bnez	a5,800032aa <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800032b6:	5098                	lw	a4,32(s1)
    800032b8:	2705                	addiw	a4,a4,1
    800032ba:	0007069b          	sext.w	a3,a4
    800032be:	0027179b          	slliw	a5,a4,0x2
    800032c2:	9fb9                	addw	a5,a5,a4
    800032c4:	0017979b          	slliw	a5,a5,0x1
    800032c8:	54d8                	lw	a4,44(s1)
    800032ca:	9fb9                	addw	a5,a5,a4
    800032cc:	00f95763          	bge	s2,a5,800032da <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800032d0:	85a6                	mv	a1,s1
    800032d2:	8526                	mv	a0,s1
    800032d4:	bdcfe0ef          	jal	ra,800016b0 <sleep>
    800032d8:	bfe9                	j	800032b2 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800032da:	00015517          	auipc	a0,0x15
    800032de:	9b650513          	addi	a0,a0,-1610 # 80017c90 <log>
    800032e2:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800032e4:	736020ef          	jal	ra,80005a1a <release>
      break;
    }
  }
}
    800032e8:	60e2                	ld	ra,24(sp)
    800032ea:	6442                	ld	s0,16(sp)
    800032ec:	64a2                	ld	s1,8(sp)
    800032ee:	6902                	ld	s2,0(sp)
    800032f0:	6105                	addi	sp,sp,32
    800032f2:	8082                	ret

00000000800032f4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800032f4:	7139                	addi	sp,sp,-64
    800032f6:	fc06                	sd	ra,56(sp)
    800032f8:	f822                	sd	s0,48(sp)
    800032fa:	f426                	sd	s1,40(sp)
    800032fc:	f04a                	sd	s2,32(sp)
    800032fe:	ec4e                	sd	s3,24(sp)
    80003300:	e852                	sd	s4,16(sp)
    80003302:	e456                	sd	s5,8(sp)
    80003304:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003306:	00015497          	auipc	s1,0x15
    8000330a:	98a48493          	addi	s1,s1,-1654 # 80017c90 <log>
    8000330e:	8526                	mv	a0,s1
    80003310:	672020ef          	jal	ra,80005982 <acquire>
  log.outstanding -= 1;
    80003314:	509c                	lw	a5,32(s1)
    80003316:	37fd                	addiw	a5,a5,-1
    80003318:	0007891b          	sext.w	s2,a5
    8000331c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000331e:	50dc                	lw	a5,36(s1)
    80003320:	ef9d                	bnez	a5,8000335e <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003322:	04091463          	bnez	s2,8000336a <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003326:	00015497          	auipc	s1,0x15
    8000332a:	96a48493          	addi	s1,s1,-1686 # 80017c90 <log>
    8000332e:	4785                	li	a5,1
    80003330:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003332:	8526                	mv	a0,s1
    80003334:	6e6020ef          	jal	ra,80005a1a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003338:	54dc                	lw	a5,44(s1)
    8000333a:	04f04b63          	bgtz	a5,80003390 <end_op+0x9c>
    acquire(&log.lock);
    8000333e:	00015497          	auipc	s1,0x15
    80003342:	95248493          	addi	s1,s1,-1710 # 80017c90 <log>
    80003346:	8526                	mv	a0,s1
    80003348:	63a020ef          	jal	ra,80005982 <acquire>
    log.committing = 0;
    8000334c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003350:	8526                	mv	a0,s1
    80003352:	baafe0ef          	jal	ra,800016fc <wakeup>
    release(&log.lock);
    80003356:	8526                	mv	a0,s1
    80003358:	6c2020ef          	jal	ra,80005a1a <release>
}
    8000335c:	a00d                	j	8000337e <end_op+0x8a>
    panic("log.committing");
    8000335e:	00004517          	auipc	a0,0x4
    80003362:	41a50513          	addi	a0,a0,1050 # 80007778 <syscalls+0x248>
    80003366:	30c020ef          	jal	ra,80005672 <panic>
    wakeup(&log);
    8000336a:	00015497          	auipc	s1,0x15
    8000336e:	92648493          	addi	s1,s1,-1754 # 80017c90 <log>
    80003372:	8526                	mv	a0,s1
    80003374:	b88fe0ef          	jal	ra,800016fc <wakeup>
  release(&log.lock);
    80003378:	8526                	mv	a0,s1
    8000337a:	6a0020ef          	jal	ra,80005a1a <release>
}
    8000337e:	70e2                	ld	ra,56(sp)
    80003380:	7442                	ld	s0,48(sp)
    80003382:	74a2                	ld	s1,40(sp)
    80003384:	7902                	ld	s2,32(sp)
    80003386:	69e2                	ld	s3,24(sp)
    80003388:	6a42                	ld	s4,16(sp)
    8000338a:	6aa2                	ld	s5,8(sp)
    8000338c:	6121                	addi	sp,sp,64
    8000338e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003390:	00015a97          	auipc	s5,0x15
    80003394:	930a8a93          	addi	s5,s5,-1744 # 80017cc0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003398:	00015a17          	auipc	s4,0x15
    8000339c:	8f8a0a13          	addi	s4,s4,-1800 # 80017c90 <log>
    800033a0:	018a2583          	lw	a1,24(s4)
    800033a4:	012585bb          	addw	a1,a1,s2
    800033a8:	2585                	addiw	a1,a1,1
    800033aa:	028a2503          	lw	a0,40(s4)
    800033ae:	f29fe0ef          	jal	ra,800022d6 <bread>
    800033b2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800033b4:	000aa583          	lw	a1,0(s5)
    800033b8:	028a2503          	lw	a0,40(s4)
    800033bc:	f1bfe0ef          	jal	ra,800022d6 <bread>
    800033c0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800033c2:	40000613          	li	a2,1024
    800033c6:	05850593          	addi	a1,a0,88
    800033ca:	05848513          	addi	a0,s1,88
    800033ce:	f41fc0ef          	jal	ra,8000030e <memmove>
    bwrite(to);  // write the log
    800033d2:	8526                	mv	a0,s1
    800033d4:	fd9fe0ef          	jal	ra,800023ac <bwrite>
    brelse(from);
    800033d8:	854e                	mv	a0,s3
    800033da:	804ff0ef          	jal	ra,800023de <brelse>
    brelse(to);
    800033de:	8526                	mv	a0,s1
    800033e0:	ffffe0ef          	jal	ra,800023de <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800033e4:	2905                	addiw	s2,s2,1
    800033e6:	0a91                	addi	s5,s5,4
    800033e8:	02ca2783          	lw	a5,44(s4)
    800033ec:	faf94ae3          	blt	s2,a5,800033a0 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800033f0:	cedff0ef          	jal	ra,800030dc <write_head>
    install_trans(0); // Now install writes to home locations
    800033f4:	4501                	li	a0,0
    800033f6:	d57ff0ef          	jal	ra,8000314c <install_trans>
    log.lh.n = 0;
    800033fa:	00015797          	auipc	a5,0x15
    800033fe:	8c07a123          	sw	zero,-1854(a5) # 80017cbc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003402:	cdbff0ef          	jal	ra,800030dc <write_head>
    80003406:	bf25                	j	8000333e <end_op+0x4a>

0000000080003408 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003408:	1101                	addi	sp,sp,-32
    8000340a:	ec06                	sd	ra,24(sp)
    8000340c:	e822                	sd	s0,16(sp)
    8000340e:	e426                	sd	s1,8(sp)
    80003410:	e04a                	sd	s2,0(sp)
    80003412:	1000                	addi	s0,sp,32
    80003414:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003416:	00015917          	auipc	s2,0x15
    8000341a:	87a90913          	addi	s2,s2,-1926 # 80017c90 <log>
    8000341e:	854a                	mv	a0,s2
    80003420:	562020ef          	jal	ra,80005982 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003424:	02c92603          	lw	a2,44(s2)
    80003428:	47f5                	li	a5,29
    8000342a:	06c7c363          	blt	a5,a2,80003490 <log_write+0x88>
    8000342e:	00015797          	auipc	a5,0x15
    80003432:	87e7a783          	lw	a5,-1922(a5) # 80017cac <log+0x1c>
    80003436:	37fd                	addiw	a5,a5,-1
    80003438:	04f65c63          	bge	a2,a5,80003490 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000343c:	00015797          	auipc	a5,0x15
    80003440:	8747a783          	lw	a5,-1932(a5) # 80017cb0 <log+0x20>
    80003444:	04f05c63          	blez	a5,8000349c <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003448:	4781                	li	a5,0
    8000344a:	04c05f63          	blez	a2,800034a8 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000344e:	44cc                	lw	a1,12(s1)
    80003450:	00015717          	auipc	a4,0x15
    80003454:	87070713          	addi	a4,a4,-1936 # 80017cc0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003458:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000345a:	4314                	lw	a3,0(a4)
    8000345c:	04b68663          	beq	a3,a1,800034a8 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003460:	2785                	addiw	a5,a5,1
    80003462:	0711                	addi	a4,a4,4
    80003464:	fef61be3          	bne	a2,a5,8000345a <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003468:	0621                	addi	a2,a2,8
    8000346a:	060a                	slli	a2,a2,0x2
    8000346c:	00015797          	auipc	a5,0x15
    80003470:	82478793          	addi	a5,a5,-2012 # 80017c90 <log>
    80003474:	97b2                	add	a5,a5,a2
    80003476:	44d8                	lw	a4,12(s1)
    80003478:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000347a:	8526                	mv	a0,s1
    8000347c:	fedfe0ef          	jal	ra,80002468 <bpin>
    log.lh.n++;
    80003480:	00015717          	auipc	a4,0x15
    80003484:	81070713          	addi	a4,a4,-2032 # 80017c90 <log>
    80003488:	575c                	lw	a5,44(a4)
    8000348a:	2785                	addiw	a5,a5,1
    8000348c:	d75c                	sw	a5,44(a4)
    8000348e:	a80d                	j	800034c0 <log_write+0xb8>
    panic("too big a transaction");
    80003490:	00004517          	auipc	a0,0x4
    80003494:	2f850513          	addi	a0,a0,760 # 80007788 <syscalls+0x258>
    80003498:	1da020ef          	jal	ra,80005672 <panic>
    panic("log_write outside of trans");
    8000349c:	00004517          	auipc	a0,0x4
    800034a0:	30450513          	addi	a0,a0,772 # 800077a0 <syscalls+0x270>
    800034a4:	1ce020ef          	jal	ra,80005672 <panic>
  log.lh.block[i] = b->blockno;
    800034a8:	00878693          	addi	a3,a5,8
    800034ac:	068a                	slli	a3,a3,0x2
    800034ae:	00014717          	auipc	a4,0x14
    800034b2:	7e270713          	addi	a4,a4,2018 # 80017c90 <log>
    800034b6:	9736                	add	a4,a4,a3
    800034b8:	44d4                	lw	a3,12(s1)
    800034ba:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800034bc:	faf60fe3          	beq	a2,a5,8000347a <log_write+0x72>
  }
  release(&log.lock);
    800034c0:	00014517          	auipc	a0,0x14
    800034c4:	7d050513          	addi	a0,a0,2000 # 80017c90 <log>
    800034c8:	552020ef          	jal	ra,80005a1a <release>
}
    800034cc:	60e2                	ld	ra,24(sp)
    800034ce:	6442                	ld	s0,16(sp)
    800034d0:	64a2                	ld	s1,8(sp)
    800034d2:	6902                	ld	s2,0(sp)
    800034d4:	6105                	addi	sp,sp,32
    800034d6:	8082                	ret

00000000800034d8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800034d8:	1101                	addi	sp,sp,-32
    800034da:	ec06                	sd	ra,24(sp)
    800034dc:	e822                	sd	s0,16(sp)
    800034de:	e426                	sd	s1,8(sp)
    800034e0:	e04a                	sd	s2,0(sp)
    800034e2:	1000                	addi	s0,sp,32
    800034e4:	84aa                	mv	s1,a0
    800034e6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800034e8:	00004597          	auipc	a1,0x4
    800034ec:	2d858593          	addi	a1,a1,728 # 800077c0 <syscalls+0x290>
    800034f0:	0521                	addi	a0,a0,8
    800034f2:	410020ef          	jal	ra,80005902 <initlock>
  lk->name = name;
    800034f6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800034fa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800034fe:	0204a423          	sw	zero,40(s1)
}
    80003502:	60e2                	ld	ra,24(sp)
    80003504:	6442                	ld	s0,16(sp)
    80003506:	64a2                	ld	s1,8(sp)
    80003508:	6902                	ld	s2,0(sp)
    8000350a:	6105                	addi	sp,sp,32
    8000350c:	8082                	ret

000000008000350e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000350e:	1101                	addi	sp,sp,-32
    80003510:	ec06                	sd	ra,24(sp)
    80003512:	e822                	sd	s0,16(sp)
    80003514:	e426                	sd	s1,8(sp)
    80003516:	e04a                	sd	s2,0(sp)
    80003518:	1000                	addi	s0,sp,32
    8000351a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000351c:	00850913          	addi	s2,a0,8
    80003520:	854a                	mv	a0,s2
    80003522:	460020ef          	jal	ra,80005982 <acquire>
  while (lk->locked) {
    80003526:	409c                	lw	a5,0(s1)
    80003528:	c799                	beqz	a5,80003536 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000352a:	85ca                	mv	a1,s2
    8000352c:	8526                	mv	a0,s1
    8000352e:	982fe0ef          	jal	ra,800016b0 <sleep>
  while (lk->locked) {
    80003532:	409c                	lw	a5,0(s1)
    80003534:	fbfd                	bnez	a5,8000352a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003536:	4785                	li	a5,1
    80003538:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000353a:	babfd0ef          	jal	ra,800010e4 <myproc>
    8000353e:	591c                	lw	a5,48(a0)
    80003540:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003542:	854a                	mv	a0,s2
    80003544:	4d6020ef          	jal	ra,80005a1a <release>
}
    80003548:	60e2                	ld	ra,24(sp)
    8000354a:	6442                	ld	s0,16(sp)
    8000354c:	64a2                	ld	s1,8(sp)
    8000354e:	6902                	ld	s2,0(sp)
    80003550:	6105                	addi	sp,sp,32
    80003552:	8082                	ret

0000000080003554 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003554:	1101                	addi	sp,sp,-32
    80003556:	ec06                	sd	ra,24(sp)
    80003558:	e822                	sd	s0,16(sp)
    8000355a:	e426                	sd	s1,8(sp)
    8000355c:	e04a                	sd	s2,0(sp)
    8000355e:	1000                	addi	s0,sp,32
    80003560:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003562:	00850913          	addi	s2,a0,8
    80003566:	854a                	mv	a0,s2
    80003568:	41a020ef          	jal	ra,80005982 <acquire>
  lk->locked = 0;
    8000356c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003570:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003574:	8526                	mv	a0,s1
    80003576:	986fe0ef          	jal	ra,800016fc <wakeup>
  release(&lk->lk);
    8000357a:	854a                	mv	a0,s2
    8000357c:	49e020ef          	jal	ra,80005a1a <release>
}
    80003580:	60e2                	ld	ra,24(sp)
    80003582:	6442                	ld	s0,16(sp)
    80003584:	64a2                	ld	s1,8(sp)
    80003586:	6902                	ld	s2,0(sp)
    80003588:	6105                	addi	sp,sp,32
    8000358a:	8082                	ret

000000008000358c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000358c:	7179                	addi	sp,sp,-48
    8000358e:	f406                	sd	ra,40(sp)
    80003590:	f022                	sd	s0,32(sp)
    80003592:	ec26                	sd	s1,24(sp)
    80003594:	e84a                	sd	s2,16(sp)
    80003596:	e44e                	sd	s3,8(sp)
    80003598:	1800                	addi	s0,sp,48
    8000359a:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    8000359c:	00850913          	addi	s2,a0,8
    800035a0:	854a                	mv	a0,s2
    800035a2:	3e0020ef          	jal	ra,80005982 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800035a6:	409c                	lw	a5,0(s1)
    800035a8:	ef89                	bnez	a5,800035c2 <holdingsleep+0x36>
    800035aa:	4481                	li	s1,0
  release(&lk->lk);
    800035ac:	854a                	mv	a0,s2
    800035ae:	46c020ef          	jal	ra,80005a1a <release>
  return r;
}
    800035b2:	8526                	mv	a0,s1
    800035b4:	70a2                	ld	ra,40(sp)
    800035b6:	7402                	ld	s0,32(sp)
    800035b8:	64e2                	ld	s1,24(sp)
    800035ba:	6942                	ld	s2,16(sp)
    800035bc:	69a2                	ld	s3,8(sp)
    800035be:	6145                	addi	sp,sp,48
    800035c0:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800035c2:	0284a983          	lw	s3,40(s1)
    800035c6:	b1ffd0ef          	jal	ra,800010e4 <myproc>
    800035ca:	5904                	lw	s1,48(a0)
    800035cc:	413484b3          	sub	s1,s1,s3
    800035d0:	0014b493          	seqz	s1,s1
    800035d4:	bfe1                	j	800035ac <holdingsleep+0x20>

00000000800035d6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800035d6:	1141                	addi	sp,sp,-16
    800035d8:	e406                	sd	ra,8(sp)
    800035da:	e022                	sd	s0,0(sp)
    800035dc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800035de:	00004597          	auipc	a1,0x4
    800035e2:	1f258593          	addi	a1,a1,498 # 800077d0 <syscalls+0x2a0>
    800035e6:	00014517          	auipc	a0,0x14
    800035ea:	7f250513          	addi	a0,a0,2034 # 80017dd8 <ftable>
    800035ee:	314020ef          	jal	ra,80005902 <initlock>
}
    800035f2:	60a2                	ld	ra,8(sp)
    800035f4:	6402                	ld	s0,0(sp)
    800035f6:	0141                	addi	sp,sp,16
    800035f8:	8082                	ret

00000000800035fa <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800035fa:	1101                	addi	sp,sp,-32
    800035fc:	ec06                	sd	ra,24(sp)
    800035fe:	e822                	sd	s0,16(sp)
    80003600:	e426                	sd	s1,8(sp)
    80003602:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003604:	00014517          	auipc	a0,0x14
    80003608:	7d450513          	addi	a0,a0,2004 # 80017dd8 <ftable>
    8000360c:	376020ef          	jal	ra,80005982 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003610:	00014497          	auipc	s1,0x14
    80003614:	7e048493          	addi	s1,s1,2016 # 80017df0 <ftable+0x18>
    80003618:	00015717          	auipc	a4,0x15
    8000361c:	77870713          	addi	a4,a4,1912 # 80018d90 <disk>
    if(f->ref == 0){
    80003620:	40dc                	lw	a5,4(s1)
    80003622:	cf89                	beqz	a5,8000363c <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003624:	02848493          	addi	s1,s1,40
    80003628:	fee49ce3          	bne	s1,a4,80003620 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000362c:	00014517          	auipc	a0,0x14
    80003630:	7ac50513          	addi	a0,a0,1964 # 80017dd8 <ftable>
    80003634:	3e6020ef          	jal	ra,80005a1a <release>
  return 0;
    80003638:	4481                	li	s1,0
    8000363a:	a809                	j	8000364c <filealloc+0x52>
      f->ref = 1;
    8000363c:	4785                	li	a5,1
    8000363e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003640:	00014517          	auipc	a0,0x14
    80003644:	79850513          	addi	a0,a0,1944 # 80017dd8 <ftable>
    80003648:	3d2020ef          	jal	ra,80005a1a <release>
}
    8000364c:	8526                	mv	a0,s1
    8000364e:	60e2                	ld	ra,24(sp)
    80003650:	6442                	ld	s0,16(sp)
    80003652:	64a2                	ld	s1,8(sp)
    80003654:	6105                	addi	sp,sp,32
    80003656:	8082                	ret

0000000080003658 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003658:	1101                	addi	sp,sp,-32
    8000365a:	ec06                	sd	ra,24(sp)
    8000365c:	e822                	sd	s0,16(sp)
    8000365e:	e426                	sd	s1,8(sp)
    80003660:	1000                	addi	s0,sp,32
    80003662:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003664:	00014517          	auipc	a0,0x14
    80003668:	77450513          	addi	a0,a0,1908 # 80017dd8 <ftable>
    8000366c:	316020ef          	jal	ra,80005982 <acquire>
  if(f->ref < 1)
    80003670:	40dc                	lw	a5,4(s1)
    80003672:	02f05063          	blez	a5,80003692 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003676:	2785                	addiw	a5,a5,1
    80003678:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000367a:	00014517          	auipc	a0,0x14
    8000367e:	75e50513          	addi	a0,a0,1886 # 80017dd8 <ftable>
    80003682:	398020ef          	jal	ra,80005a1a <release>
  return f;
}
    80003686:	8526                	mv	a0,s1
    80003688:	60e2                	ld	ra,24(sp)
    8000368a:	6442                	ld	s0,16(sp)
    8000368c:	64a2                	ld	s1,8(sp)
    8000368e:	6105                	addi	sp,sp,32
    80003690:	8082                	ret
    panic("filedup");
    80003692:	00004517          	auipc	a0,0x4
    80003696:	14650513          	addi	a0,a0,326 # 800077d8 <syscalls+0x2a8>
    8000369a:	7d9010ef          	jal	ra,80005672 <panic>

000000008000369e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000369e:	7139                	addi	sp,sp,-64
    800036a0:	fc06                	sd	ra,56(sp)
    800036a2:	f822                	sd	s0,48(sp)
    800036a4:	f426                	sd	s1,40(sp)
    800036a6:	f04a                	sd	s2,32(sp)
    800036a8:	ec4e                	sd	s3,24(sp)
    800036aa:	e852                	sd	s4,16(sp)
    800036ac:	e456                	sd	s5,8(sp)
    800036ae:	0080                	addi	s0,sp,64
    800036b0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800036b2:	00014517          	auipc	a0,0x14
    800036b6:	72650513          	addi	a0,a0,1830 # 80017dd8 <ftable>
    800036ba:	2c8020ef          	jal	ra,80005982 <acquire>
  if(f->ref < 1)
    800036be:	40dc                	lw	a5,4(s1)
    800036c0:	04f05963          	blez	a5,80003712 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    800036c4:	37fd                	addiw	a5,a5,-1
    800036c6:	0007871b          	sext.w	a4,a5
    800036ca:	c0dc                	sw	a5,4(s1)
    800036cc:	04e04963          	bgtz	a4,8000371e <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800036d0:	0004a903          	lw	s2,0(s1)
    800036d4:	0094ca83          	lbu	s5,9(s1)
    800036d8:	0104ba03          	ld	s4,16(s1)
    800036dc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800036e0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800036e4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800036e8:	00014517          	auipc	a0,0x14
    800036ec:	6f050513          	addi	a0,a0,1776 # 80017dd8 <ftable>
    800036f0:	32a020ef          	jal	ra,80005a1a <release>

  if(ff.type == FD_PIPE){
    800036f4:	4785                	li	a5,1
    800036f6:	04f90363          	beq	s2,a5,8000373c <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800036fa:	3979                	addiw	s2,s2,-2
    800036fc:	4785                	li	a5,1
    800036fe:	0327e663          	bltu	a5,s2,8000372a <fileclose+0x8c>
    begin_op();
    80003702:	b85ff0ef          	jal	ra,80003286 <begin_op>
    iput(ff.ip);
    80003706:	854e                	mv	a0,s3
    80003708:	c68ff0ef          	jal	ra,80002b70 <iput>
    end_op();
    8000370c:	be9ff0ef          	jal	ra,800032f4 <end_op>
    80003710:	a829                	j	8000372a <fileclose+0x8c>
    panic("fileclose");
    80003712:	00004517          	auipc	a0,0x4
    80003716:	0ce50513          	addi	a0,a0,206 # 800077e0 <syscalls+0x2b0>
    8000371a:	759010ef          	jal	ra,80005672 <panic>
    release(&ftable.lock);
    8000371e:	00014517          	auipc	a0,0x14
    80003722:	6ba50513          	addi	a0,a0,1722 # 80017dd8 <ftable>
    80003726:	2f4020ef          	jal	ra,80005a1a <release>
  }
}
    8000372a:	70e2                	ld	ra,56(sp)
    8000372c:	7442                	ld	s0,48(sp)
    8000372e:	74a2                	ld	s1,40(sp)
    80003730:	7902                	ld	s2,32(sp)
    80003732:	69e2                	ld	s3,24(sp)
    80003734:	6a42                	ld	s4,16(sp)
    80003736:	6aa2                	ld	s5,8(sp)
    80003738:	6121                	addi	sp,sp,64
    8000373a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000373c:	85d6                	mv	a1,s5
    8000373e:	8552                	mv	a0,s4
    80003740:	2ec000ef          	jal	ra,80003a2c <pipeclose>
    80003744:	b7dd                	j	8000372a <fileclose+0x8c>

0000000080003746 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003746:	715d                	addi	sp,sp,-80
    80003748:	e486                	sd	ra,72(sp)
    8000374a:	e0a2                	sd	s0,64(sp)
    8000374c:	fc26                	sd	s1,56(sp)
    8000374e:	f84a                	sd	s2,48(sp)
    80003750:	f44e                	sd	s3,40(sp)
    80003752:	0880                	addi	s0,sp,80
    80003754:	84aa                	mv	s1,a0
    80003756:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003758:	98dfd0ef          	jal	ra,800010e4 <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000375c:	409c                	lw	a5,0(s1)
    8000375e:	37f9                	addiw	a5,a5,-2
    80003760:	4705                	li	a4,1
    80003762:	02f76f63          	bltu	a4,a5,800037a0 <filestat+0x5a>
    80003766:	892a                	mv	s2,a0
    ilock(f->ip);
    80003768:	6c88                	ld	a0,24(s1)
    8000376a:	a88ff0ef          	jal	ra,800029f2 <ilock>
    stati(f->ip, &st);
    8000376e:	fb840593          	addi	a1,s0,-72
    80003772:	6c88                	ld	a0,24(s1)
    80003774:	ca4ff0ef          	jal	ra,80002c18 <stati>
    iunlock(f->ip);
    80003778:	6c88                	ld	a0,24(s1)
    8000377a:	b22ff0ef          	jal	ra,80002a9c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000377e:	46e1                	li	a3,24
    80003780:	fb840613          	addi	a2,s0,-72
    80003784:	85ce                	mv	a1,s3
    80003786:	05093503          	ld	a0,80(s2)
    8000378a:	cfefd0ef          	jal	ra,80000c88 <copyout>
    8000378e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003792:	60a6                	ld	ra,72(sp)
    80003794:	6406                	ld	s0,64(sp)
    80003796:	74e2                	ld	s1,56(sp)
    80003798:	7942                	ld	s2,48(sp)
    8000379a:	79a2                	ld	s3,40(sp)
    8000379c:	6161                	addi	sp,sp,80
    8000379e:	8082                	ret
  return -1;
    800037a0:	557d                	li	a0,-1
    800037a2:	bfc5                	j	80003792 <filestat+0x4c>

00000000800037a4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800037a4:	7179                	addi	sp,sp,-48
    800037a6:	f406                	sd	ra,40(sp)
    800037a8:	f022                	sd	s0,32(sp)
    800037aa:	ec26                	sd	s1,24(sp)
    800037ac:	e84a                	sd	s2,16(sp)
    800037ae:	e44e                	sd	s3,8(sp)
    800037b0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800037b2:	00854783          	lbu	a5,8(a0)
    800037b6:	cbc1                	beqz	a5,80003846 <fileread+0xa2>
    800037b8:	84aa                	mv	s1,a0
    800037ba:	89ae                	mv	s3,a1
    800037bc:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800037be:	411c                	lw	a5,0(a0)
    800037c0:	4705                	li	a4,1
    800037c2:	04e78363          	beq	a5,a4,80003808 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800037c6:	470d                	li	a4,3
    800037c8:	04e78563          	beq	a5,a4,80003812 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800037cc:	4709                	li	a4,2
    800037ce:	06e79663          	bne	a5,a4,8000383a <fileread+0x96>
    ilock(f->ip);
    800037d2:	6d08                	ld	a0,24(a0)
    800037d4:	a1eff0ef          	jal	ra,800029f2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800037d8:	874a                	mv	a4,s2
    800037da:	5094                	lw	a3,32(s1)
    800037dc:	864e                	mv	a2,s3
    800037de:	4585                	li	a1,1
    800037e0:	6c88                	ld	a0,24(s1)
    800037e2:	c60ff0ef          	jal	ra,80002c42 <readi>
    800037e6:	892a                	mv	s2,a0
    800037e8:	00a05563          	blez	a0,800037f2 <fileread+0x4e>
      f->off += r;
    800037ec:	509c                	lw	a5,32(s1)
    800037ee:	9fa9                	addw	a5,a5,a0
    800037f0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800037f2:	6c88                	ld	a0,24(s1)
    800037f4:	aa8ff0ef          	jal	ra,80002a9c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800037f8:	854a                	mv	a0,s2
    800037fa:	70a2                	ld	ra,40(sp)
    800037fc:	7402                	ld	s0,32(sp)
    800037fe:	64e2                	ld	s1,24(sp)
    80003800:	6942                	ld	s2,16(sp)
    80003802:	69a2                	ld	s3,8(sp)
    80003804:	6145                	addi	sp,sp,48
    80003806:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003808:	6908                	ld	a0,16(a0)
    8000380a:	34e000ef          	jal	ra,80003b58 <piperead>
    8000380e:	892a                	mv	s2,a0
    80003810:	b7e5                	j	800037f8 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003812:	02451783          	lh	a5,36(a0)
    80003816:	03079693          	slli	a3,a5,0x30
    8000381a:	92c1                	srli	a3,a3,0x30
    8000381c:	4725                	li	a4,9
    8000381e:	02d76663          	bltu	a4,a3,8000384a <fileread+0xa6>
    80003822:	0792                	slli	a5,a5,0x4
    80003824:	00014717          	auipc	a4,0x14
    80003828:	51470713          	addi	a4,a4,1300 # 80017d38 <devsw>
    8000382c:	97ba                	add	a5,a5,a4
    8000382e:	639c                	ld	a5,0(a5)
    80003830:	cf99                	beqz	a5,8000384e <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80003832:	4505                	li	a0,1
    80003834:	9782                	jalr	a5
    80003836:	892a                	mv	s2,a0
    80003838:	b7c1                	j	800037f8 <fileread+0x54>
    panic("fileread");
    8000383a:	00004517          	auipc	a0,0x4
    8000383e:	fb650513          	addi	a0,a0,-74 # 800077f0 <syscalls+0x2c0>
    80003842:	631010ef          	jal	ra,80005672 <panic>
    return -1;
    80003846:	597d                	li	s2,-1
    80003848:	bf45                	j	800037f8 <fileread+0x54>
      return -1;
    8000384a:	597d                	li	s2,-1
    8000384c:	b775                	j	800037f8 <fileread+0x54>
    8000384e:	597d                	li	s2,-1
    80003850:	b765                	j	800037f8 <fileread+0x54>

0000000080003852 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003852:	715d                	addi	sp,sp,-80
    80003854:	e486                	sd	ra,72(sp)
    80003856:	e0a2                	sd	s0,64(sp)
    80003858:	fc26                	sd	s1,56(sp)
    8000385a:	f84a                	sd	s2,48(sp)
    8000385c:	f44e                	sd	s3,40(sp)
    8000385e:	f052                	sd	s4,32(sp)
    80003860:	ec56                	sd	s5,24(sp)
    80003862:	e85a                	sd	s6,16(sp)
    80003864:	e45e                	sd	s7,8(sp)
    80003866:	e062                	sd	s8,0(sp)
    80003868:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000386a:	00954783          	lbu	a5,9(a0)
    8000386e:	0e078863          	beqz	a5,8000395e <filewrite+0x10c>
    80003872:	892a                	mv	s2,a0
    80003874:	8b2e                	mv	s6,a1
    80003876:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003878:	411c                	lw	a5,0(a0)
    8000387a:	4705                	li	a4,1
    8000387c:	02e78263          	beq	a5,a4,800038a0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003880:	470d                	li	a4,3
    80003882:	02e78463          	beq	a5,a4,800038aa <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003886:	4709                	li	a4,2
    80003888:	0ce79563          	bne	a5,a4,80003952 <filewrite+0x100>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000388c:	0ac05163          	blez	a2,8000392e <filewrite+0xdc>
    int i = 0;
    80003890:	4981                	li	s3,0
    80003892:	6b85                	lui	s7,0x1
    80003894:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80003898:	6c05                	lui	s8,0x1
    8000389a:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000389e:	a041                	j	8000391e <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800038a0:	6908                	ld	a0,16(a0)
    800038a2:	1e2000ef          	jal	ra,80003a84 <pipewrite>
    800038a6:	8a2a                	mv	s4,a0
    800038a8:	a071                	j	80003934 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800038aa:	02451783          	lh	a5,36(a0)
    800038ae:	03079693          	slli	a3,a5,0x30
    800038b2:	92c1                	srli	a3,a3,0x30
    800038b4:	4725                	li	a4,9
    800038b6:	0ad76663          	bltu	a4,a3,80003962 <filewrite+0x110>
    800038ba:	0792                	slli	a5,a5,0x4
    800038bc:	00014717          	auipc	a4,0x14
    800038c0:	47c70713          	addi	a4,a4,1148 # 80017d38 <devsw>
    800038c4:	97ba                	add	a5,a5,a4
    800038c6:	679c                	ld	a5,8(a5)
    800038c8:	cfd9                	beqz	a5,80003966 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    800038ca:	4505                	li	a0,1
    800038cc:	9782                	jalr	a5
    800038ce:	8a2a                	mv	s4,a0
    800038d0:	a095                	j	80003934 <filewrite+0xe2>
    800038d2:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800038d6:	9b1ff0ef          	jal	ra,80003286 <begin_op>
      ilock(f->ip);
    800038da:	01893503          	ld	a0,24(s2)
    800038de:	914ff0ef          	jal	ra,800029f2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800038e2:	8756                	mv	a4,s5
    800038e4:	02092683          	lw	a3,32(s2)
    800038e8:	01698633          	add	a2,s3,s6
    800038ec:	4585                	li	a1,1
    800038ee:	01893503          	ld	a0,24(s2)
    800038f2:	c34ff0ef          	jal	ra,80002d26 <writei>
    800038f6:	84aa                	mv	s1,a0
    800038f8:	00a05763          	blez	a0,80003906 <filewrite+0xb4>
        f->off += r;
    800038fc:	02092783          	lw	a5,32(s2)
    80003900:	9fa9                	addw	a5,a5,a0
    80003902:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003906:	01893503          	ld	a0,24(s2)
    8000390a:	992ff0ef          	jal	ra,80002a9c <iunlock>
      end_op();
    8000390e:	9e7ff0ef          	jal	ra,800032f4 <end_op>

      if(r != n1){
    80003912:	009a9f63          	bne	s5,s1,80003930 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80003916:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000391a:	0149db63          	bge	s3,s4,80003930 <filewrite+0xde>
      int n1 = n - i;
    8000391e:	413a04bb          	subw	s1,s4,s3
    80003922:	0004879b          	sext.w	a5,s1
    80003926:	fafbd6e3          	bge	s7,a5,800038d2 <filewrite+0x80>
    8000392a:	84e2                	mv	s1,s8
    8000392c:	b75d                	j	800038d2 <filewrite+0x80>
    int i = 0;
    8000392e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003930:	013a1f63          	bne	s4,s3,8000394e <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003934:	8552                	mv	a0,s4
    80003936:	60a6                	ld	ra,72(sp)
    80003938:	6406                	ld	s0,64(sp)
    8000393a:	74e2                	ld	s1,56(sp)
    8000393c:	7942                	ld	s2,48(sp)
    8000393e:	79a2                	ld	s3,40(sp)
    80003940:	7a02                	ld	s4,32(sp)
    80003942:	6ae2                	ld	s5,24(sp)
    80003944:	6b42                	ld	s6,16(sp)
    80003946:	6ba2                	ld	s7,8(sp)
    80003948:	6c02                	ld	s8,0(sp)
    8000394a:	6161                	addi	sp,sp,80
    8000394c:	8082                	ret
    ret = (i == n ? n : -1);
    8000394e:	5a7d                	li	s4,-1
    80003950:	b7d5                	j	80003934 <filewrite+0xe2>
    panic("filewrite");
    80003952:	00004517          	auipc	a0,0x4
    80003956:	eae50513          	addi	a0,a0,-338 # 80007800 <syscalls+0x2d0>
    8000395a:	519010ef          	jal	ra,80005672 <panic>
    return -1;
    8000395e:	5a7d                	li	s4,-1
    80003960:	bfd1                	j	80003934 <filewrite+0xe2>
      return -1;
    80003962:	5a7d                	li	s4,-1
    80003964:	bfc1                	j	80003934 <filewrite+0xe2>
    80003966:	5a7d                	li	s4,-1
    80003968:	b7f1                	j	80003934 <filewrite+0xe2>

000000008000396a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000396a:	7179                	addi	sp,sp,-48
    8000396c:	f406                	sd	ra,40(sp)
    8000396e:	f022                	sd	s0,32(sp)
    80003970:	ec26                	sd	s1,24(sp)
    80003972:	e84a                	sd	s2,16(sp)
    80003974:	e44e                	sd	s3,8(sp)
    80003976:	e052                	sd	s4,0(sp)
    80003978:	1800                	addi	s0,sp,48
    8000397a:	84aa                	mv	s1,a0
    8000397c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000397e:	0005b023          	sd	zero,0(a1)
    80003982:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003986:	c75ff0ef          	jal	ra,800035fa <filealloc>
    8000398a:	e088                	sd	a0,0(s1)
    8000398c:	cd35                	beqz	a0,80003a08 <pipealloc+0x9e>
    8000398e:	c6dff0ef          	jal	ra,800035fa <filealloc>
    80003992:	00aa3023          	sd	a0,0(s4)
    80003996:	c52d                	beqz	a0,80003a00 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003998:	fccfc0ef          	jal	ra,80000164 <kalloc>
    8000399c:	892a                	mv	s2,a0
    8000399e:	cd31                	beqz	a0,800039fa <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    800039a0:	4985                	li	s3,1
    800039a2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800039a6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800039aa:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800039ae:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800039b2:	00004597          	auipc	a1,0x4
    800039b6:	e5e58593          	addi	a1,a1,-418 # 80007810 <syscalls+0x2e0>
    800039ba:	749010ef          	jal	ra,80005902 <initlock>
  (*f0)->type = FD_PIPE;
    800039be:	609c                	ld	a5,0(s1)
    800039c0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800039c4:	609c                	ld	a5,0(s1)
    800039c6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800039ca:	609c                	ld	a5,0(s1)
    800039cc:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800039d0:	609c                	ld	a5,0(s1)
    800039d2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800039d6:	000a3783          	ld	a5,0(s4)
    800039da:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800039de:	000a3783          	ld	a5,0(s4)
    800039e2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800039e6:	000a3783          	ld	a5,0(s4)
    800039ea:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800039ee:	000a3783          	ld	a5,0(s4)
    800039f2:	0127b823          	sd	s2,16(a5)
  return 0;
    800039f6:	4501                	li	a0,0
    800039f8:	a005                	j	80003a18 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800039fa:	6088                	ld	a0,0(s1)
    800039fc:	e501                	bnez	a0,80003a04 <pipealloc+0x9a>
    800039fe:	a029                	j	80003a08 <pipealloc+0x9e>
    80003a00:	6088                	ld	a0,0(s1)
    80003a02:	c11d                	beqz	a0,80003a28 <pipealloc+0xbe>
    fileclose(*f0);
    80003a04:	c9bff0ef          	jal	ra,8000369e <fileclose>
  if(*f1)
    80003a08:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003a0c:	557d                	li	a0,-1
  if(*f1)
    80003a0e:	c789                	beqz	a5,80003a18 <pipealloc+0xae>
    fileclose(*f1);
    80003a10:	853e                	mv	a0,a5
    80003a12:	c8dff0ef          	jal	ra,8000369e <fileclose>
  return -1;
    80003a16:	557d                	li	a0,-1
}
    80003a18:	70a2                	ld	ra,40(sp)
    80003a1a:	7402                	ld	s0,32(sp)
    80003a1c:	64e2                	ld	s1,24(sp)
    80003a1e:	6942                	ld	s2,16(sp)
    80003a20:	69a2                	ld	s3,8(sp)
    80003a22:	6a02                	ld	s4,0(sp)
    80003a24:	6145                	addi	sp,sp,48
    80003a26:	8082                	ret
  return -1;
    80003a28:	557d                	li	a0,-1
    80003a2a:	b7fd                	j	80003a18 <pipealloc+0xae>

0000000080003a2c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003a2c:	1101                	addi	sp,sp,-32
    80003a2e:	ec06                	sd	ra,24(sp)
    80003a30:	e822                	sd	s0,16(sp)
    80003a32:	e426                	sd	s1,8(sp)
    80003a34:	e04a                	sd	s2,0(sp)
    80003a36:	1000                	addi	s0,sp,32
    80003a38:	84aa                	mv	s1,a0
    80003a3a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003a3c:	747010ef          	jal	ra,80005982 <acquire>
  if(writable){
    80003a40:	02090763          	beqz	s2,80003a6e <pipeclose+0x42>
    pi->writeopen = 0;
    80003a44:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003a48:	21848513          	addi	a0,s1,536
    80003a4c:	cb1fd0ef          	jal	ra,800016fc <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003a50:	2204b783          	ld	a5,544(s1)
    80003a54:	e785                	bnez	a5,80003a7c <pipeclose+0x50>
    release(&pi->lock);
    80003a56:	8526                	mv	a0,s1
    80003a58:	7c3010ef          	jal	ra,80005a1a <release>
    kfree((char*)pi);
    80003a5c:	8526                	mv	a0,s1
    80003a5e:	e12fc0ef          	jal	ra,80000070 <kfree>
  } else
    release(&pi->lock);
}
    80003a62:	60e2                	ld	ra,24(sp)
    80003a64:	6442                	ld	s0,16(sp)
    80003a66:	64a2                	ld	s1,8(sp)
    80003a68:	6902                	ld	s2,0(sp)
    80003a6a:	6105                	addi	sp,sp,32
    80003a6c:	8082                	ret
    pi->readopen = 0;
    80003a6e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003a72:	21c48513          	addi	a0,s1,540
    80003a76:	c87fd0ef          	jal	ra,800016fc <wakeup>
    80003a7a:	bfd9                	j	80003a50 <pipeclose+0x24>
    release(&pi->lock);
    80003a7c:	8526                	mv	a0,s1
    80003a7e:	79d010ef          	jal	ra,80005a1a <release>
}
    80003a82:	b7c5                	j	80003a62 <pipeclose+0x36>

0000000080003a84 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003a84:	711d                	addi	sp,sp,-96
    80003a86:	ec86                	sd	ra,88(sp)
    80003a88:	e8a2                	sd	s0,80(sp)
    80003a8a:	e4a6                	sd	s1,72(sp)
    80003a8c:	e0ca                	sd	s2,64(sp)
    80003a8e:	fc4e                	sd	s3,56(sp)
    80003a90:	f852                	sd	s4,48(sp)
    80003a92:	f456                	sd	s5,40(sp)
    80003a94:	f05a                	sd	s6,32(sp)
    80003a96:	ec5e                	sd	s7,24(sp)
    80003a98:	e862                	sd	s8,16(sp)
    80003a9a:	1080                	addi	s0,sp,96
    80003a9c:	84aa                	mv	s1,a0
    80003a9e:	8aae                	mv	s5,a1
    80003aa0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003aa2:	e42fd0ef          	jal	ra,800010e4 <myproc>
    80003aa6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003aa8:	8526                	mv	a0,s1
    80003aaa:	6d9010ef          	jal	ra,80005982 <acquire>
  while(i < n){
    80003aae:	09405c63          	blez	s4,80003b46 <pipewrite+0xc2>
  int i = 0;
    80003ab2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003ab4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003ab6:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003aba:	21c48b93          	addi	s7,s1,540
    80003abe:	a81d                	j	80003af4 <pipewrite+0x70>
      release(&pi->lock);
    80003ac0:	8526                	mv	a0,s1
    80003ac2:	759010ef          	jal	ra,80005a1a <release>
      return -1;
    80003ac6:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003ac8:	854a                	mv	a0,s2
    80003aca:	60e6                	ld	ra,88(sp)
    80003acc:	6446                	ld	s0,80(sp)
    80003ace:	64a6                	ld	s1,72(sp)
    80003ad0:	6906                	ld	s2,64(sp)
    80003ad2:	79e2                	ld	s3,56(sp)
    80003ad4:	7a42                	ld	s4,48(sp)
    80003ad6:	7aa2                	ld	s5,40(sp)
    80003ad8:	7b02                	ld	s6,32(sp)
    80003ada:	6be2                	ld	s7,24(sp)
    80003adc:	6c42                	ld	s8,16(sp)
    80003ade:	6125                	addi	sp,sp,96
    80003ae0:	8082                	ret
      wakeup(&pi->nread);
    80003ae2:	8562                	mv	a0,s8
    80003ae4:	c19fd0ef          	jal	ra,800016fc <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003ae8:	85a6                	mv	a1,s1
    80003aea:	855e                	mv	a0,s7
    80003aec:	bc5fd0ef          	jal	ra,800016b0 <sleep>
  while(i < n){
    80003af0:	05495c63          	bge	s2,s4,80003b48 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80003af4:	2204a783          	lw	a5,544(s1)
    80003af8:	d7e1                	beqz	a5,80003ac0 <pipewrite+0x3c>
    80003afa:	854e                	mv	a0,s3
    80003afc:	dedfd0ef          	jal	ra,800018e8 <killed>
    80003b00:	f161                	bnez	a0,80003ac0 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003b02:	2184a783          	lw	a5,536(s1)
    80003b06:	21c4a703          	lw	a4,540(s1)
    80003b0a:	2007879b          	addiw	a5,a5,512
    80003b0e:	fcf70ae3          	beq	a4,a5,80003ae2 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003b12:	4685                	li	a3,1
    80003b14:	01590633          	add	a2,s2,s5
    80003b18:	faf40593          	addi	a1,s0,-81
    80003b1c:	0509b503          	ld	a0,80(s3)
    80003b20:	a20fd0ef          	jal	ra,80000d40 <copyin>
    80003b24:	03650263          	beq	a0,s6,80003b48 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003b28:	21c4a783          	lw	a5,540(s1)
    80003b2c:	0017871b          	addiw	a4,a5,1
    80003b30:	20e4ae23          	sw	a4,540(s1)
    80003b34:	1ff7f793          	andi	a5,a5,511
    80003b38:	97a6                	add	a5,a5,s1
    80003b3a:	faf44703          	lbu	a4,-81(s0)
    80003b3e:	00e78c23          	sb	a4,24(a5)
      i++;
    80003b42:	2905                	addiw	s2,s2,1
    80003b44:	b775                	j	80003af0 <pipewrite+0x6c>
  int i = 0;
    80003b46:	4901                	li	s2,0
  wakeup(&pi->nread);
    80003b48:	21848513          	addi	a0,s1,536
    80003b4c:	bb1fd0ef          	jal	ra,800016fc <wakeup>
  release(&pi->lock);
    80003b50:	8526                	mv	a0,s1
    80003b52:	6c9010ef          	jal	ra,80005a1a <release>
  return i;
    80003b56:	bf8d                	j	80003ac8 <pipewrite+0x44>

0000000080003b58 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003b58:	715d                	addi	sp,sp,-80
    80003b5a:	e486                	sd	ra,72(sp)
    80003b5c:	e0a2                	sd	s0,64(sp)
    80003b5e:	fc26                	sd	s1,56(sp)
    80003b60:	f84a                	sd	s2,48(sp)
    80003b62:	f44e                	sd	s3,40(sp)
    80003b64:	f052                	sd	s4,32(sp)
    80003b66:	ec56                	sd	s5,24(sp)
    80003b68:	e85a                	sd	s6,16(sp)
    80003b6a:	0880                	addi	s0,sp,80
    80003b6c:	84aa                	mv	s1,a0
    80003b6e:	892e                	mv	s2,a1
    80003b70:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003b72:	d72fd0ef          	jal	ra,800010e4 <myproc>
    80003b76:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003b78:	8526                	mv	a0,s1
    80003b7a:	609010ef          	jal	ra,80005982 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003b7e:	2184a703          	lw	a4,536(s1)
    80003b82:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003b86:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003b8a:	02f71363          	bne	a4,a5,80003bb0 <piperead+0x58>
    80003b8e:	2244a783          	lw	a5,548(s1)
    80003b92:	cf99                	beqz	a5,80003bb0 <piperead+0x58>
    if(killed(pr)){
    80003b94:	8552                	mv	a0,s4
    80003b96:	d53fd0ef          	jal	ra,800018e8 <killed>
    80003b9a:	e149                	bnez	a0,80003c1c <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003b9c:	85a6                	mv	a1,s1
    80003b9e:	854e                	mv	a0,s3
    80003ba0:	b11fd0ef          	jal	ra,800016b0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003ba4:	2184a703          	lw	a4,536(s1)
    80003ba8:	21c4a783          	lw	a5,540(s1)
    80003bac:	fef701e3          	beq	a4,a5,80003b8e <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003bb0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003bb2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003bb4:	05505263          	blez	s5,80003bf8 <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    80003bb8:	2184a783          	lw	a5,536(s1)
    80003bbc:	21c4a703          	lw	a4,540(s1)
    80003bc0:	02f70c63          	beq	a4,a5,80003bf8 <piperead+0xa0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003bc4:	0017871b          	addiw	a4,a5,1
    80003bc8:	20e4ac23          	sw	a4,536(s1)
    80003bcc:	1ff7f793          	andi	a5,a5,511
    80003bd0:	97a6                	add	a5,a5,s1
    80003bd2:	0187c783          	lbu	a5,24(a5)
    80003bd6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003bda:	4685                	li	a3,1
    80003bdc:	fbf40613          	addi	a2,s0,-65
    80003be0:	85ca                	mv	a1,s2
    80003be2:	050a3503          	ld	a0,80(s4)
    80003be6:	8a2fd0ef          	jal	ra,80000c88 <copyout>
    80003bea:	01650763          	beq	a0,s6,80003bf8 <piperead+0xa0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003bee:	2985                	addiw	s3,s3,1
    80003bf0:	0905                	addi	s2,s2,1
    80003bf2:	fd3a93e3          	bne	s5,s3,80003bb8 <piperead+0x60>
    80003bf6:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003bf8:	21c48513          	addi	a0,s1,540
    80003bfc:	b01fd0ef          	jal	ra,800016fc <wakeup>
  release(&pi->lock);
    80003c00:	8526                	mv	a0,s1
    80003c02:	619010ef          	jal	ra,80005a1a <release>
  return i;
}
    80003c06:	854e                	mv	a0,s3
    80003c08:	60a6                	ld	ra,72(sp)
    80003c0a:	6406                	ld	s0,64(sp)
    80003c0c:	74e2                	ld	s1,56(sp)
    80003c0e:	7942                	ld	s2,48(sp)
    80003c10:	79a2                	ld	s3,40(sp)
    80003c12:	7a02                	ld	s4,32(sp)
    80003c14:	6ae2                	ld	s5,24(sp)
    80003c16:	6b42                	ld	s6,16(sp)
    80003c18:	6161                	addi	sp,sp,80
    80003c1a:	8082                	ret
      release(&pi->lock);
    80003c1c:	8526                	mv	a0,s1
    80003c1e:	5fd010ef          	jal	ra,80005a1a <release>
      return -1;
    80003c22:	59fd                	li	s3,-1
    80003c24:	b7cd                	j	80003c06 <piperead+0xae>

0000000080003c26 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80003c26:	1141                	addi	sp,sp,-16
    80003c28:	e422                	sd	s0,8(sp)
    80003c2a:	0800                	addi	s0,sp,16
    80003c2c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003c2e:	8905                	andi	a0,a0,1
    80003c30:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003c32:	8b89                	andi	a5,a5,2
    80003c34:	c399                	beqz	a5,80003c3a <flags2perm+0x14>
      perm |= PTE_W;
    80003c36:	00456513          	ori	a0,a0,4
    return perm;
}
    80003c3a:	6422                	ld	s0,8(sp)
    80003c3c:	0141                	addi	sp,sp,16
    80003c3e:	8082                	ret

0000000080003c40 <exec>:

int
exec(char *path, char **argv)
{
    80003c40:	de010113          	addi	sp,sp,-544
    80003c44:	20113c23          	sd	ra,536(sp)
    80003c48:	20813823          	sd	s0,528(sp)
    80003c4c:	20913423          	sd	s1,520(sp)
    80003c50:	21213023          	sd	s2,512(sp)
    80003c54:	ffce                	sd	s3,504(sp)
    80003c56:	fbd2                	sd	s4,496(sp)
    80003c58:	f7d6                	sd	s5,488(sp)
    80003c5a:	f3da                	sd	s6,480(sp)
    80003c5c:	efde                	sd	s7,472(sp)
    80003c5e:	ebe2                	sd	s8,464(sp)
    80003c60:	e7e6                	sd	s9,456(sp)
    80003c62:	e3ea                	sd	s10,448(sp)
    80003c64:	ff6e                	sd	s11,440(sp)
    80003c66:	1400                	addi	s0,sp,544
    80003c68:	892a                	mv	s2,a0
    80003c6a:	dea43423          	sd	a0,-536(s0)
    80003c6e:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003c72:	c72fd0ef          	jal	ra,800010e4 <myproc>
    80003c76:	84aa                	mv	s1,a0

  begin_op();
    80003c78:	e0eff0ef          	jal	ra,80003286 <begin_op>

  if((ip = namei(path)) == 0){
    80003c7c:	854a                	mv	a0,s2
    80003c7e:	c2cff0ef          	jal	ra,800030aa <namei>
    80003c82:	c13d                	beqz	a0,80003ce8 <exec+0xa8>
    80003c84:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003c86:	d6dfe0ef          	jal	ra,800029f2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003c8a:	04000713          	li	a4,64
    80003c8e:	4681                	li	a3,0
    80003c90:	e5040613          	addi	a2,s0,-432
    80003c94:	4581                	li	a1,0
    80003c96:	8556                	mv	a0,s5
    80003c98:	fabfe0ef          	jal	ra,80002c42 <readi>
    80003c9c:	04000793          	li	a5,64
    80003ca0:	00f51a63          	bne	a0,a5,80003cb4 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80003ca4:	e5042703          	lw	a4,-432(s0)
    80003ca8:	464c47b7          	lui	a5,0x464c4
    80003cac:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003cb0:	04f70063          	beq	a4,a5,80003cf0 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003cb4:	8556                	mv	a0,s5
    80003cb6:	f43fe0ef          	jal	ra,80002bf8 <iunlockput>
    end_op();
    80003cba:	e3aff0ef          	jal	ra,800032f4 <end_op>
  }
  return -1;
    80003cbe:	557d                	li	a0,-1
}
    80003cc0:	21813083          	ld	ra,536(sp)
    80003cc4:	21013403          	ld	s0,528(sp)
    80003cc8:	20813483          	ld	s1,520(sp)
    80003ccc:	20013903          	ld	s2,512(sp)
    80003cd0:	79fe                	ld	s3,504(sp)
    80003cd2:	7a5e                	ld	s4,496(sp)
    80003cd4:	7abe                	ld	s5,488(sp)
    80003cd6:	7b1e                	ld	s6,480(sp)
    80003cd8:	6bfe                	ld	s7,472(sp)
    80003cda:	6c5e                	ld	s8,464(sp)
    80003cdc:	6cbe                	ld	s9,456(sp)
    80003cde:	6d1e                	ld	s10,448(sp)
    80003ce0:	7dfa                	ld	s11,440(sp)
    80003ce2:	22010113          	addi	sp,sp,544
    80003ce6:	8082                	ret
    end_op();
    80003ce8:	e0cff0ef          	jal	ra,800032f4 <end_op>
    return -1;
    80003cec:	557d                	li	a0,-1
    80003cee:	bfc9                	j	80003cc0 <exec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    80003cf0:	8526                	mv	a0,s1
    80003cf2:	c9afd0ef          	jal	ra,8000118c <proc_pagetable>
    80003cf6:	8b2a                	mv	s6,a0
    80003cf8:	dd55                	beqz	a0,80003cb4 <exec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003cfa:	e7042783          	lw	a5,-400(s0)
    80003cfe:	e8845703          	lhu	a4,-376(s0)
    80003d02:	c325                	beqz	a4,80003d62 <exec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003d04:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003d06:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80003d0a:	6a05                	lui	s4,0x1
    80003d0c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80003d10:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80003d14:	6d85                	lui	s11,0x1
    80003d16:	7d7d                	lui	s10,0xfffff
    80003d18:	a409                	j	80003f1a <exec+0x2da>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80003d1a:	00004517          	auipc	a0,0x4
    80003d1e:	afe50513          	addi	a0,a0,-1282 # 80007818 <syscalls+0x2e8>
    80003d22:	151010ef          	jal	ra,80005672 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003d26:	874a                	mv	a4,s2
    80003d28:	009c86bb          	addw	a3,s9,s1
    80003d2c:	4581                	li	a1,0
    80003d2e:	8556                	mv	a0,s5
    80003d30:	f13fe0ef          	jal	ra,80002c42 <readi>
    80003d34:	2501                	sext.w	a0,a0
    80003d36:	18a91163          	bne	s2,a0,80003eb8 <exec+0x278>
  for(i = 0; i < sz; i += PGSIZE){
    80003d3a:	009d84bb          	addw	s1,s11,s1
    80003d3e:	013d09bb          	addw	s3,s10,s3
    80003d42:	1b74fc63          	bgeu	s1,s7,80003efa <exec+0x2ba>
    pa = walkaddr(pagetable, va + i);
    80003d46:	02049593          	slli	a1,s1,0x20
    80003d4a:	9181                	srli	a1,a1,0x20
    80003d4c:	95e2                	add	a1,a1,s8
    80003d4e:	855a                	mv	a0,s6
    80003d50:	8fffc0ef          	jal	ra,8000064e <walkaddr>
    80003d54:	862a                	mv	a2,a0
    if(pa == 0)
    80003d56:	d171                	beqz	a0,80003d1a <exec+0xda>
      n = PGSIZE;
    80003d58:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80003d5a:	fd49f6e3          	bgeu	s3,s4,80003d26 <exec+0xe6>
      n = sz - i;
    80003d5e:	894e                	mv	s2,s3
    80003d60:	b7d9                	j	80003d26 <exec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003d62:	4901                	li	s2,0
  iunlockput(ip);
    80003d64:	8556                	mv	a0,s5
    80003d66:	e93fe0ef          	jal	ra,80002bf8 <iunlockput>
  end_op();
    80003d6a:	d8aff0ef          	jal	ra,800032f4 <end_op>
  p = myproc();
    80003d6e:	b76fd0ef          	jal	ra,800010e4 <myproc>
    80003d72:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80003d74:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80003d78:	6785                	lui	a5,0x1
    80003d7a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80003d7c:	97ca                	add	a5,a5,s2
    80003d7e:	777d                	lui	a4,0xfffff
    80003d80:	8ff9                	and	a5,a5,a4
    80003d82:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003d86:	4691                	li	a3,4
    80003d88:	6609                	lui	a2,0x2
    80003d8a:	963e                	add	a2,a2,a5
    80003d8c:	85be                	mv	a1,a5
    80003d8e:	855a                	mv	a0,s6
    80003d90:	c85fc0ef          	jal	ra,80000a14 <uvmalloc>
    80003d94:	8c2a                	mv	s8,a0
  ip = 0;
    80003d96:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003d98:	12050063          	beqz	a0,80003eb8 <exec+0x278>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003d9c:	75f9                	lui	a1,0xffffe
    80003d9e:	95aa                	add	a1,a1,a0
    80003da0:	855a                	mv	a0,s6
    80003da2:	ebdfc0ef          	jal	ra,80000c5e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003da6:	7afd                	lui	s5,0xfffff
    80003da8:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80003daa:	df043783          	ld	a5,-528(s0)
    80003dae:	6388                	ld	a0,0(a5)
    80003db0:	c135                	beqz	a0,80003e14 <exec+0x1d4>
    80003db2:	e9040993          	addi	s3,s0,-368
    80003db6:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80003dba:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003dbc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003dbe:	e6cfc0ef          	jal	ra,8000042a <strlen>
    80003dc2:	0015079b          	addiw	a5,a0,1
    80003dc6:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003dca:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003dce:	11596a63          	bltu	s2,s5,80003ee2 <exec+0x2a2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003dd2:	df043d83          	ld	s11,-528(s0)
    80003dd6:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80003dda:	8552                	mv	a0,s4
    80003ddc:	e4efc0ef          	jal	ra,8000042a <strlen>
    80003de0:	0015069b          	addiw	a3,a0,1
    80003de4:	8652                	mv	a2,s4
    80003de6:	85ca                	mv	a1,s2
    80003de8:	855a                	mv	a0,s6
    80003dea:	e9ffc0ef          	jal	ra,80000c88 <copyout>
    80003dee:	0e054e63          	bltz	a0,80003eea <exec+0x2aa>
    ustack[argc] = sp;
    80003df2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003df6:	0485                	addi	s1,s1,1
    80003df8:	008d8793          	addi	a5,s11,8
    80003dfc:	def43823          	sd	a5,-528(s0)
    80003e00:	008db503          	ld	a0,8(s11)
    80003e04:	c911                	beqz	a0,80003e18 <exec+0x1d8>
    if(argc >= MAXARG)
    80003e06:	09a1                	addi	s3,s3,8
    80003e08:	fb3c9be3          	bne	s9,s3,80003dbe <exec+0x17e>
  sz = sz1;
    80003e0c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003e10:	4a81                	li	s5,0
    80003e12:	a05d                	j	80003eb8 <exec+0x278>
  sp = sz;
    80003e14:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003e16:	4481                	li	s1,0
  ustack[argc] = 0;
    80003e18:	00349793          	slli	a5,s1,0x3
    80003e1c:	f9078793          	addi	a5,a5,-112
    80003e20:	97a2                	add	a5,a5,s0
    80003e22:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003e26:	00148693          	addi	a3,s1,1
    80003e2a:	068e                	slli	a3,a3,0x3
    80003e2c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003e30:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80003e34:	01597663          	bgeu	s2,s5,80003e40 <exec+0x200>
  sz = sz1;
    80003e38:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003e3c:	4a81                	li	s5,0
    80003e3e:	a8ad                	j	80003eb8 <exec+0x278>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003e40:	e9040613          	addi	a2,s0,-368
    80003e44:	85ca                	mv	a1,s2
    80003e46:	855a                	mv	a0,s6
    80003e48:	e41fc0ef          	jal	ra,80000c88 <copyout>
    80003e4c:	0a054363          	bltz	a0,80003ef2 <exec+0x2b2>
  p->trapframe->a1 = sp;
    80003e50:	058bb783          	ld	a5,88(s7)
    80003e54:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003e58:	de843783          	ld	a5,-536(s0)
    80003e5c:	0007c703          	lbu	a4,0(a5)
    80003e60:	cf11                	beqz	a4,80003e7c <exec+0x23c>
    80003e62:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003e64:	02f00693          	li	a3,47
    80003e68:	a039                	j	80003e76 <exec+0x236>
      last = s+1;
    80003e6a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80003e6e:	0785                	addi	a5,a5,1
    80003e70:	fff7c703          	lbu	a4,-1(a5)
    80003e74:	c701                	beqz	a4,80003e7c <exec+0x23c>
    if(*s == '/')
    80003e76:	fed71ce3          	bne	a4,a3,80003e6e <exec+0x22e>
    80003e7a:	bfc5                	j	80003e6a <exec+0x22a>
  safestrcpy(p->name, last, sizeof(p->name));
    80003e7c:	4641                	li	a2,16
    80003e7e:	de843583          	ld	a1,-536(s0)
    80003e82:	158b8513          	addi	a0,s7,344
    80003e86:	d72fc0ef          	jal	ra,800003f8 <safestrcpy>
  oldpagetable = p->pagetable;
    80003e8a:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80003e8e:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80003e92:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003e96:	058bb783          	ld	a5,88(s7)
    80003e9a:	e6843703          	ld	a4,-408(s0)
    80003e9e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003ea0:	058bb783          	ld	a5,88(s7)
    80003ea4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003ea8:	85ea                	mv	a1,s10
    80003eaa:	b66fd0ef          	jal	ra,80001210 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003eae:	0004851b          	sext.w	a0,s1
    80003eb2:	b539                	j	80003cc0 <exec+0x80>
    80003eb4:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80003eb8:	df843583          	ld	a1,-520(s0)
    80003ebc:	855a                	mv	a0,s6
    80003ebe:	b52fd0ef          	jal	ra,80001210 <proc_freepagetable>
  if(ip){
    80003ec2:	de0a99e3          	bnez	s5,80003cb4 <exec+0x74>
  return -1;
    80003ec6:	557d                	li	a0,-1
    80003ec8:	bbe5                	j	80003cc0 <exec+0x80>
    80003eca:	df243c23          	sd	s2,-520(s0)
    80003ece:	b7ed                	j	80003eb8 <exec+0x278>
    80003ed0:	df243c23          	sd	s2,-520(s0)
    80003ed4:	b7d5                	j	80003eb8 <exec+0x278>
    80003ed6:	df243c23          	sd	s2,-520(s0)
    80003eda:	bff9                	j	80003eb8 <exec+0x278>
    80003edc:	df243c23          	sd	s2,-520(s0)
    80003ee0:	bfe1                	j	80003eb8 <exec+0x278>
  sz = sz1;
    80003ee2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003ee6:	4a81                	li	s5,0
    80003ee8:	bfc1                	j	80003eb8 <exec+0x278>
  sz = sz1;
    80003eea:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003eee:	4a81                	li	s5,0
    80003ef0:	b7e1                	j	80003eb8 <exec+0x278>
  sz = sz1;
    80003ef2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003ef6:	4a81                	li	s5,0
    80003ef8:	b7c1                	j	80003eb8 <exec+0x278>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003efa:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003efe:	e0843783          	ld	a5,-504(s0)
    80003f02:	0017869b          	addiw	a3,a5,1
    80003f06:	e0d43423          	sd	a3,-504(s0)
    80003f0a:	e0043783          	ld	a5,-512(s0)
    80003f0e:	0387879b          	addiw	a5,a5,56
    80003f12:	e8845703          	lhu	a4,-376(s0)
    80003f16:	e4e6d7e3          	bge	a3,a4,80003d64 <exec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003f1a:	2781                	sext.w	a5,a5
    80003f1c:	e0f43023          	sd	a5,-512(s0)
    80003f20:	03800713          	li	a4,56
    80003f24:	86be                	mv	a3,a5
    80003f26:	e1840613          	addi	a2,s0,-488
    80003f2a:	4581                	li	a1,0
    80003f2c:	8556                	mv	a0,s5
    80003f2e:	d15fe0ef          	jal	ra,80002c42 <readi>
    80003f32:	03800793          	li	a5,56
    80003f36:	f6f51fe3          	bne	a0,a5,80003eb4 <exec+0x274>
    if(ph.type != ELF_PROG_LOAD)
    80003f3a:	e1842783          	lw	a5,-488(s0)
    80003f3e:	4705                	li	a4,1
    80003f40:	fae79fe3          	bne	a5,a4,80003efe <exec+0x2be>
    if(ph.memsz < ph.filesz)
    80003f44:	e4043483          	ld	s1,-448(s0)
    80003f48:	e3843783          	ld	a5,-456(s0)
    80003f4c:	f6f4efe3          	bltu	s1,a5,80003eca <exec+0x28a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003f50:	e2843783          	ld	a5,-472(s0)
    80003f54:	94be                	add	s1,s1,a5
    80003f56:	f6f4ede3          	bltu	s1,a5,80003ed0 <exec+0x290>
    if(ph.vaddr % PGSIZE != 0)
    80003f5a:	de043703          	ld	a4,-544(s0)
    80003f5e:	8ff9                	and	a5,a5,a4
    80003f60:	fbbd                	bnez	a5,80003ed6 <exec+0x296>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003f62:	e1c42503          	lw	a0,-484(s0)
    80003f66:	cc1ff0ef          	jal	ra,80003c26 <flags2perm>
    80003f6a:	86aa                	mv	a3,a0
    80003f6c:	8626                	mv	a2,s1
    80003f6e:	85ca                	mv	a1,s2
    80003f70:	855a                	mv	a0,s6
    80003f72:	aa3fc0ef          	jal	ra,80000a14 <uvmalloc>
    80003f76:	dea43c23          	sd	a0,-520(s0)
    80003f7a:	d12d                	beqz	a0,80003edc <exec+0x29c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003f7c:	e2843c03          	ld	s8,-472(s0)
    80003f80:	e2042c83          	lw	s9,-480(s0)
    80003f84:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003f88:	f60b89e3          	beqz	s7,80003efa <exec+0x2ba>
    80003f8c:	89de                	mv	s3,s7
    80003f8e:	4481                	li	s1,0
    80003f90:	bb5d                	j	80003d46 <exec+0x106>

0000000080003f92 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003f92:	7179                	addi	sp,sp,-48
    80003f94:	f406                	sd	ra,40(sp)
    80003f96:	f022                	sd	s0,32(sp)
    80003f98:	ec26                	sd	s1,24(sp)
    80003f9a:	e84a                	sd	s2,16(sp)
    80003f9c:	1800                	addi	s0,sp,48
    80003f9e:	892e                	mv	s2,a1
    80003fa0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003fa2:	fdc40593          	addi	a1,s0,-36
    80003fa6:	fedfd0ef          	jal	ra,80001f92 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003faa:	fdc42703          	lw	a4,-36(s0)
    80003fae:	47bd                	li	a5,15
    80003fb0:	02e7e963          	bltu	a5,a4,80003fe2 <argfd+0x50>
    80003fb4:	930fd0ef          	jal	ra,800010e4 <myproc>
    80003fb8:	fdc42703          	lw	a4,-36(s0)
    80003fbc:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffde04a>
    80003fc0:	078e                	slli	a5,a5,0x3
    80003fc2:	953e                	add	a0,a0,a5
    80003fc4:	611c                	ld	a5,0(a0)
    80003fc6:	c385                	beqz	a5,80003fe6 <argfd+0x54>
    return -1;
  if(pfd)
    80003fc8:	00090463          	beqz	s2,80003fd0 <argfd+0x3e>
    *pfd = fd;
    80003fcc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003fd0:	4501                	li	a0,0
  if(pf)
    80003fd2:	c091                	beqz	s1,80003fd6 <argfd+0x44>
    *pf = f;
    80003fd4:	e09c                	sd	a5,0(s1)
}
    80003fd6:	70a2                	ld	ra,40(sp)
    80003fd8:	7402                	ld	s0,32(sp)
    80003fda:	64e2                	ld	s1,24(sp)
    80003fdc:	6942                	ld	s2,16(sp)
    80003fde:	6145                	addi	sp,sp,48
    80003fe0:	8082                	ret
    return -1;
    80003fe2:	557d                	li	a0,-1
    80003fe4:	bfcd                	j	80003fd6 <argfd+0x44>
    80003fe6:	557d                	li	a0,-1
    80003fe8:	b7fd                	j	80003fd6 <argfd+0x44>

0000000080003fea <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003fea:	1101                	addi	sp,sp,-32
    80003fec:	ec06                	sd	ra,24(sp)
    80003fee:	e822                	sd	s0,16(sp)
    80003ff0:	e426                	sd	s1,8(sp)
    80003ff2:	1000                	addi	s0,sp,32
    80003ff4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003ff6:	8eefd0ef          	jal	ra,800010e4 <myproc>
    80003ffa:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003ffc:	0d050793          	addi	a5,a0,208
    80004000:	4501                	li	a0,0
    80004002:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004004:	6398                	ld	a4,0(a5)
    80004006:	cb19                	beqz	a4,8000401c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004008:	2505                	addiw	a0,a0,1
    8000400a:	07a1                	addi	a5,a5,8
    8000400c:	fed51ce3          	bne	a0,a3,80004004 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004010:	557d                	li	a0,-1
}
    80004012:	60e2                	ld	ra,24(sp)
    80004014:	6442                	ld	s0,16(sp)
    80004016:	64a2                	ld	s1,8(sp)
    80004018:	6105                	addi	sp,sp,32
    8000401a:	8082                	ret
      p->ofile[fd] = f;
    8000401c:	01a50793          	addi	a5,a0,26
    80004020:	078e                	slli	a5,a5,0x3
    80004022:	963e                	add	a2,a2,a5
    80004024:	e204                	sd	s1,0(a2)
      return fd;
    80004026:	b7f5                	j	80004012 <fdalloc+0x28>

0000000080004028 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004028:	715d                	addi	sp,sp,-80
    8000402a:	e486                	sd	ra,72(sp)
    8000402c:	e0a2                	sd	s0,64(sp)
    8000402e:	fc26                	sd	s1,56(sp)
    80004030:	f84a                	sd	s2,48(sp)
    80004032:	f44e                	sd	s3,40(sp)
    80004034:	f052                	sd	s4,32(sp)
    80004036:	ec56                	sd	s5,24(sp)
    80004038:	e85a                	sd	s6,16(sp)
    8000403a:	0880                	addi	s0,sp,80
    8000403c:	8b2e                	mv	s6,a1
    8000403e:	89b2                	mv	s3,a2
    80004040:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004042:	fb040593          	addi	a1,s0,-80
    80004046:	87eff0ef          	jal	ra,800030c4 <nameiparent>
    8000404a:	84aa                	mv	s1,a0
    8000404c:	10050b63          	beqz	a0,80004162 <create+0x13a>
    return 0;

  ilock(dp);
    80004050:	9a3fe0ef          	jal	ra,800029f2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004054:	4601                	li	a2,0
    80004056:	fb040593          	addi	a1,s0,-80
    8000405a:	8526                	mv	a0,s1
    8000405c:	de3fe0ef          	jal	ra,80002e3e <dirlookup>
    80004060:	8aaa                	mv	s5,a0
    80004062:	c521                	beqz	a0,800040aa <create+0x82>
    iunlockput(dp);
    80004064:	8526                	mv	a0,s1
    80004066:	b93fe0ef          	jal	ra,80002bf8 <iunlockput>
    ilock(ip);
    8000406a:	8556                	mv	a0,s5
    8000406c:	987fe0ef          	jal	ra,800029f2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004070:	000b059b          	sext.w	a1,s6
    80004074:	4789                	li	a5,2
    80004076:	02f59563          	bne	a1,a5,800040a0 <create+0x78>
    8000407a:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffde074>
    8000407e:	37f9                	addiw	a5,a5,-2
    80004080:	17c2                	slli	a5,a5,0x30
    80004082:	93c1                	srli	a5,a5,0x30
    80004084:	4705                	li	a4,1
    80004086:	00f76d63          	bltu	a4,a5,800040a0 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000408a:	8556                	mv	a0,s5
    8000408c:	60a6                	ld	ra,72(sp)
    8000408e:	6406                	ld	s0,64(sp)
    80004090:	74e2                	ld	s1,56(sp)
    80004092:	7942                	ld	s2,48(sp)
    80004094:	79a2                	ld	s3,40(sp)
    80004096:	7a02                	ld	s4,32(sp)
    80004098:	6ae2                	ld	s5,24(sp)
    8000409a:	6b42                	ld	s6,16(sp)
    8000409c:	6161                	addi	sp,sp,80
    8000409e:	8082                	ret
    iunlockput(ip);
    800040a0:	8556                	mv	a0,s5
    800040a2:	b57fe0ef          	jal	ra,80002bf8 <iunlockput>
    return 0;
    800040a6:	4a81                	li	s5,0
    800040a8:	b7cd                	j	8000408a <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    800040aa:	85da                	mv	a1,s6
    800040ac:	4088                	lw	a0,0(s1)
    800040ae:	fdafe0ef          	jal	ra,80002888 <ialloc>
    800040b2:	8a2a                	mv	s4,a0
    800040b4:	cd1d                	beqz	a0,800040f2 <create+0xca>
  ilock(ip);
    800040b6:	93dfe0ef          	jal	ra,800029f2 <ilock>
  ip->major = major;
    800040ba:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800040be:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800040c2:	4905                	li	s2,1
    800040c4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800040c8:	8552                	mv	a0,s4
    800040ca:	875fe0ef          	jal	ra,8000293e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800040ce:	000b059b          	sext.w	a1,s6
    800040d2:	03258563          	beq	a1,s2,800040fc <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    800040d6:	004a2603          	lw	a2,4(s4)
    800040da:	fb040593          	addi	a1,s0,-80
    800040de:	8526                	mv	a0,s1
    800040e0:	f31fe0ef          	jal	ra,80003010 <dirlink>
    800040e4:	06054363          	bltz	a0,8000414a <create+0x122>
  iunlockput(dp);
    800040e8:	8526                	mv	a0,s1
    800040ea:	b0ffe0ef          	jal	ra,80002bf8 <iunlockput>
  return ip;
    800040ee:	8ad2                	mv	s5,s4
    800040f0:	bf69                	j	8000408a <create+0x62>
    iunlockput(dp);
    800040f2:	8526                	mv	a0,s1
    800040f4:	b05fe0ef          	jal	ra,80002bf8 <iunlockput>
    return 0;
    800040f8:	8ad2                	mv	s5,s4
    800040fa:	bf41                	j	8000408a <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800040fc:	004a2603          	lw	a2,4(s4)
    80004100:	00003597          	auipc	a1,0x3
    80004104:	73858593          	addi	a1,a1,1848 # 80007838 <syscalls+0x308>
    80004108:	8552                	mv	a0,s4
    8000410a:	f07fe0ef          	jal	ra,80003010 <dirlink>
    8000410e:	02054e63          	bltz	a0,8000414a <create+0x122>
    80004112:	40d0                	lw	a2,4(s1)
    80004114:	00003597          	auipc	a1,0x3
    80004118:	72c58593          	addi	a1,a1,1836 # 80007840 <syscalls+0x310>
    8000411c:	8552                	mv	a0,s4
    8000411e:	ef3fe0ef          	jal	ra,80003010 <dirlink>
    80004122:	02054463          	bltz	a0,8000414a <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004126:	004a2603          	lw	a2,4(s4)
    8000412a:	fb040593          	addi	a1,s0,-80
    8000412e:	8526                	mv	a0,s1
    80004130:	ee1fe0ef          	jal	ra,80003010 <dirlink>
    80004134:	00054b63          	bltz	a0,8000414a <create+0x122>
    dp->nlink++;  // for ".."
    80004138:	04a4d783          	lhu	a5,74(s1)
    8000413c:	2785                	addiw	a5,a5,1
    8000413e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004142:	8526                	mv	a0,s1
    80004144:	ffafe0ef          	jal	ra,8000293e <iupdate>
    80004148:	b745                	j	800040e8 <create+0xc0>
  ip->nlink = 0;
    8000414a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000414e:	8552                	mv	a0,s4
    80004150:	feefe0ef          	jal	ra,8000293e <iupdate>
  iunlockput(ip);
    80004154:	8552                	mv	a0,s4
    80004156:	aa3fe0ef          	jal	ra,80002bf8 <iunlockput>
  iunlockput(dp);
    8000415a:	8526                	mv	a0,s1
    8000415c:	a9dfe0ef          	jal	ra,80002bf8 <iunlockput>
  return 0;
    80004160:	b72d                	j	8000408a <create+0x62>
    return 0;
    80004162:	8aaa                	mv	s5,a0
    80004164:	b71d                	j	8000408a <create+0x62>

0000000080004166 <sys_dup>:
{
    80004166:	7179                	addi	sp,sp,-48
    80004168:	f406                	sd	ra,40(sp)
    8000416a:	f022                	sd	s0,32(sp)
    8000416c:	ec26                	sd	s1,24(sp)
    8000416e:	e84a                	sd	s2,16(sp)
    80004170:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004172:	fd840613          	addi	a2,s0,-40
    80004176:	4581                	li	a1,0
    80004178:	4501                	li	a0,0
    8000417a:	e19ff0ef          	jal	ra,80003f92 <argfd>
    return -1;
    8000417e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004180:	00054f63          	bltz	a0,8000419e <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    80004184:	fd843903          	ld	s2,-40(s0)
    80004188:	854a                	mv	a0,s2
    8000418a:	e61ff0ef          	jal	ra,80003fea <fdalloc>
    8000418e:	84aa                	mv	s1,a0
    return -1;
    80004190:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004192:	00054663          	bltz	a0,8000419e <sys_dup+0x38>
  filedup(f);
    80004196:	854a                	mv	a0,s2
    80004198:	cc0ff0ef          	jal	ra,80003658 <filedup>
  return fd;
    8000419c:	87a6                	mv	a5,s1
}
    8000419e:	853e                	mv	a0,a5
    800041a0:	70a2                	ld	ra,40(sp)
    800041a2:	7402                	ld	s0,32(sp)
    800041a4:	64e2                	ld	s1,24(sp)
    800041a6:	6942                	ld	s2,16(sp)
    800041a8:	6145                	addi	sp,sp,48
    800041aa:	8082                	ret

00000000800041ac <sys_read>:
{
    800041ac:	7179                	addi	sp,sp,-48
    800041ae:	f406                	sd	ra,40(sp)
    800041b0:	f022                	sd	s0,32(sp)
    800041b2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800041b4:	fd840593          	addi	a1,s0,-40
    800041b8:	4505                	li	a0,1
    800041ba:	df5fd0ef          	jal	ra,80001fae <argaddr>
  argint(2, &n);
    800041be:	fe440593          	addi	a1,s0,-28
    800041c2:	4509                	li	a0,2
    800041c4:	dcffd0ef          	jal	ra,80001f92 <argint>
  if(argfd(0, 0, &f) < 0)
    800041c8:	fe840613          	addi	a2,s0,-24
    800041cc:	4581                	li	a1,0
    800041ce:	4501                	li	a0,0
    800041d0:	dc3ff0ef          	jal	ra,80003f92 <argfd>
    800041d4:	87aa                	mv	a5,a0
    return -1;
    800041d6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800041d8:	0007ca63          	bltz	a5,800041ec <sys_read+0x40>
  return fileread(f, p, n);
    800041dc:	fe442603          	lw	a2,-28(s0)
    800041e0:	fd843583          	ld	a1,-40(s0)
    800041e4:	fe843503          	ld	a0,-24(s0)
    800041e8:	dbcff0ef          	jal	ra,800037a4 <fileread>
}
    800041ec:	70a2                	ld	ra,40(sp)
    800041ee:	7402                	ld	s0,32(sp)
    800041f0:	6145                	addi	sp,sp,48
    800041f2:	8082                	ret

00000000800041f4 <sys_write>:
{
    800041f4:	7179                	addi	sp,sp,-48
    800041f6:	f406                	sd	ra,40(sp)
    800041f8:	f022                	sd	s0,32(sp)
    800041fa:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800041fc:	fd840593          	addi	a1,s0,-40
    80004200:	4505                	li	a0,1
    80004202:	dadfd0ef          	jal	ra,80001fae <argaddr>
  argint(2, &n);
    80004206:	fe440593          	addi	a1,s0,-28
    8000420a:	4509                	li	a0,2
    8000420c:	d87fd0ef          	jal	ra,80001f92 <argint>
  if(argfd(0, 0, &f) < 0)
    80004210:	fe840613          	addi	a2,s0,-24
    80004214:	4581                	li	a1,0
    80004216:	4501                	li	a0,0
    80004218:	d7bff0ef          	jal	ra,80003f92 <argfd>
    8000421c:	87aa                	mv	a5,a0
    return -1;
    8000421e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004220:	0007ca63          	bltz	a5,80004234 <sys_write+0x40>
  return filewrite(f, p, n);
    80004224:	fe442603          	lw	a2,-28(s0)
    80004228:	fd843583          	ld	a1,-40(s0)
    8000422c:	fe843503          	ld	a0,-24(s0)
    80004230:	e22ff0ef          	jal	ra,80003852 <filewrite>
}
    80004234:	70a2                	ld	ra,40(sp)
    80004236:	7402                	ld	s0,32(sp)
    80004238:	6145                	addi	sp,sp,48
    8000423a:	8082                	ret

000000008000423c <sys_close>:
{
    8000423c:	1101                	addi	sp,sp,-32
    8000423e:	ec06                	sd	ra,24(sp)
    80004240:	e822                	sd	s0,16(sp)
    80004242:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004244:	fe040613          	addi	a2,s0,-32
    80004248:	fec40593          	addi	a1,s0,-20
    8000424c:	4501                	li	a0,0
    8000424e:	d45ff0ef          	jal	ra,80003f92 <argfd>
    return -1;
    80004252:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004254:	02054063          	bltz	a0,80004274 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004258:	e8dfc0ef          	jal	ra,800010e4 <myproc>
    8000425c:	fec42783          	lw	a5,-20(s0)
    80004260:	07e9                	addi	a5,a5,26
    80004262:	078e                	slli	a5,a5,0x3
    80004264:	953e                	add	a0,a0,a5
    80004266:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000426a:	fe043503          	ld	a0,-32(s0)
    8000426e:	c30ff0ef          	jal	ra,8000369e <fileclose>
  return 0;
    80004272:	4781                	li	a5,0
}
    80004274:	853e                	mv	a0,a5
    80004276:	60e2                	ld	ra,24(sp)
    80004278:	6442                	ld	s0,16(sp)
    8000427a:	6105                	addi	sp,sp,32
    8000427c:	8082                	ret

000000008000427e <sys_fstat>:
{
    8000427e:	1101                	addi	sp,sp,-32
    80004280:	ec06                	sd	ra,24(sp)
    80004282:	e822                	sd	s0,16(sp)
    80004284:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004286:	fe040593          	addi	a1,s0,-32
    8000428a:	4505                	li	a0,1
    8000428c:	d23fd0ef          	jal	ra,80001fae <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004290:	fe840613          	addi	a2,s0,-24
    80004294:	4581                	li	a1,0
    80004296:	4501                	li	a0,0
    80004298:	cfbff0ef          	jal	ra,80003f92 <argfd>
    8000429c:	87aa                	mv	a5,a0
    return -1;
    8000429e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800042a0:	0007c863          	bltz	a5,800042b0 <sys_fstat+0x32>
  return filestat(f, st);
    800042a4:	fe043583          	ld	a1,-32(s0)
    800042a8:	fe843503          	ld	a0,-24(s0)
    800042ac:	c9aff0ef          	jal	ra,80003746 <filestat>
}
    800042b0:	60e2                	ld	ra,24(sp)
    800042b2:	6442                	ld	s0,16(sp)
    800042b4:	6105                	addi	sp,sp,32
    800042b6:	8082                	ret

00000000800042b8 <sys_link>:
{
    800042b8:	7169                	addi	sp,sp,-304
    800042ba:	f606                	sd	ra,296(sp)
    800042bc:	f222                	sd	s0,288(sp)
    800042be:	ee26                	sd	s1,280(sp)
    800042c0:	ea4a                	sd	s2,272(sp)
    800042c2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800042c4:	08000613          	li	a2,128
    800042c8:	ed040593          	addi	a1,s0,-304
    800042cc:	4501                	li	a0,0
    800042ce:	cfdfd0ef          	jal	ra,80001fca <argstr>
    return -1;
    800042d2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800042d4:	0c054663          	bltz	a0,800043a0 <sys_link+0xe8>
    800042d8:	08000613          	li	a2,128
    800042dc:	f5040593          	addi	a1,s0,-176
    800042e0:	4505                	li	a0,1
    800042e2:	ce9fd0ef          	jal	ra,80001fca <argstr>
    return -1;
    800042e6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800042e8:	0a054c63          	bltz	a0,800043a0 <sys_link+0xe8>
  begin_op();
    800042ec:	f9bfe0ef          	jal	ra,80003286 <begin_op>
  if((ip = namei(old)) == 0){
    800042f0:	ed040513          	addi	a0,s0,-304
    800042f4:	db7fe0ef          	jal	ra,800030aa <namei>
    800042f8:	84aa                	mv	s1,a0
    800042fa:	c525                	beqz	a0,80004362 <sys_link+0xaa>
  ilock(ip);
    800042fc:	ef6fe0ef          	jal	ra,800029f2 <ilock>
  if(ip->type == T_DIR){
    80004300:	04449703          	lh	a4,68(s1)
    80004304:	4785                	li	a5,1
    80004306:	06f70263          	beq	a4,a5,8000436a <sys_link+0xb2>
  ip->nlink++;
    8000430a:	04a4d783          	lhu	a5,74(s1)
    8000430e:	2785                	addiw	a5,a5,1
    80004310:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004314:	8526                	mv	a0,s1
    80004316:	e28fe0ef          	jal	ra,8000293e <iupdate>
  iunlock(ip);
    8000431a:	8526                	mv	a0,s1
    8000431c:	f80fe0ef          	jal	ra,80002a9c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004320:	fd040593          	addi	a1,s0,-48
    80004324:	f5040513          	addi	a0,s0,-176
    80004328:	d9dfe0ef          	jal	ra,800030c4 <nameiparent>
    8000432c:	892a                	mv	s2,a0
    8000432e:	c921                	beqz	a0,8000437e <sys_link+0xc6>
  ilock(dp);
    80004330:	ec2fe0ef          	jal	ra,800029f2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004334:	00092703          	lw	a4,0(s2)
    80004338:	409c                	lw	a5,0(s1)
    8000433a:	02f71f63          	bne	a4,a5,80004378 <sys_link+0xc0>
    8000433e:	40d0                	lw	a2,4(s1)
    80004340:	fd040593          	addi	a1,s0,-48
    80004344:	854a                	mv	a0,s2
    80004346:	ccbfe0ef          	jal	ra,80003010 <dirlink>
    8000434a:	02054763          	bltz	a0,80004378 <sys_link+0xc0>
  iunlockput(dp);
    8000434e:	854a                	mv	a0,s2
    80004350:	8a9fe0ef          	jal	ra,80002bf8 <iunlockput>
  iput(ip);
    80004354:	8526                	mv	a0,s1
    80004356:	81bfe0ef          	jal	ra,80002b70 <iput>
  end_op();
    8000435a:	f9bfe0ef          	jal	ra,800032f4 <end_op>
  return 0;
    8000435e:	4781                	li	a5,0
    80004360:	a081                	j	800043a0 <sys_link+0xe8>
    end_op();
    80004362:	f93fe0ef          	jal	ra,800032f4 <end_op>
    return -1;
    80004366:	57fd                	li	a5,-1
    80004368:	a825                	j	800043a0 <sys_link+0xe8>
    iunlockput(ip);
    8000436a:	8526                	mv	a0,s1
    8000436c:	88dfe0ef          	jal	ra,80002bf8 <iunlockput>
    end_op();
    80004370:	f85fe0ef          	jal	ra,800032f4 <end_op>
    return -1;
    80004374:	57fd                	li	a5,-1
    80004376:	a02d                	j	800043a0 <sys_link+0xe8>
    iunlockput(dp);
    80004378:	854a                	mv	a0,s2
    8000437a:	87ffe0ef          	jal	ra,80002bf8 <iunlockput>
  ilock(ip);
    8000437e:	8526                	mv	a0,s1
    80004380:	e72fe0ef          	jal	ra,800029f2 <ilock>
  ip->nlink--;
    80004384:	04a4d783          	lhu	a5,74(s1)
    80004388:	37fd                	addiw	a5,a5,-1
    8000438a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000438e:	8526                	mv	a0,s1
    80004390:	daefe0ef          	jal	ra,8000293e <iupdate>
  iunlockput(ip);
    80004394:	8526                	mv	a0,s1
    80004396:	863fe0ef          	jal	ra,80002bf8 <iunlockput>
  end_op();
    8000439a:	f5bfe0ef          	jal	ra,800032f4 <end_op>
  return -1;
    8000439e:	57fd                	li	a5,-1
}
    800043a0:	853e                	mv	a0,a5
    800043a2:	70b2                	ld	ra,296(sp)
    800043a4:	7412                	ld	s0,288(sp)
    800043a6:	64f2                	ld	s1,280(sp)
    800043a8:	6952                	ld	s2,272(sp)
    800043aa:	6155                	addi	sp,sp,304
    800043ac:	8082                	ret

00000000800043ae <sys_unlink>:
{
    800043ae:	7151                	addi	sp,sp,-240
    800043b0:	f586                	sd	ra,232(sp)
    800043b2:	f1a2                	sd	s0,224(sp)
    800043b4:	eda6                	sd	s1,216(sp)
    800043b6:	e9ca                	sd	s2,208(sp)
    800043b8:	e5ce                	sd	s3,200(sp)
    800043ba:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800043bc:	08000613          	li	a2,128
    800043c0:	f3040593          	addi	a1,s0,-208
    800043c4:	4501                	li	a0,0
    800043c6:	c05fd0ef          	jal	ra,80001fca <argstr>
    800043ca:	12054b63          	bltz	a0,80004500 <sys_unlink+0x152>
  begin_op();
    800043ce:	eb9fe0ef          	jal	ra,80003286 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800043d2:	fb040593          	addi	a1,s0,-80
    800043d6:	f3040513          	addi	a0,s0,-208
    800043da:	cebfe0ef          	jal	ra,800030c4 <nameiparent>
    800043de:	84aa                	mv	s1,a0
    800043e0:	c54d                	beqz	a0,8000448a <sys_unlink+0xdc>
  ilock(dp);
    800043e2:	e10fe0ef          	jal	ra,800029f2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800043e6:	00003597          	auipc	a1,0x3
    800043ea:	45258593          	addi	a1,a1,1106 # 80007838 <syscalls+0x308>
    800043ee:	fb040513          	addi	a0,s0,-80
    800043f2:	a37fe0ef          	jal	ra,80002e28 <namecmp>
    800043f6:	10050a63          	beqz	a0,8000450a <sys_unlink+0x15c>
    800043fa:	00003597          	auipc	a1,0x3
    800043fe:	44658593          	addi	a1,a1,1094 # 80007840 <syscalls+0x310>
    80004402:	fb040513          	addi	a0,s0,-80
    80004406:	a23fe0ef          	jal	ra,80002e28 <namecmp>
    8000440a:	10050063          	beqz	a0,8000450a <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000440e:	f2c40613          	addi	a2,s0,-212
    80004412:	fb040593          	addi	a1,s0,-80
    80004416:	8526                	mv	a0,s1
    80004418:	a27fe0ef          	jal	ra,80002e3e <dirlookup>
    8000441c:	892a                	mv	s2,a0
    8000441e:	0e050663          	beqz	a0,8000450a <sys_unlink+0x15c>
  ilock(ip);
    80004422:	dd0fe0ef          	jal	ra,800029f2 <ilock>
  if(ip->nlink < 1)
    80004426:	04a91783          	lh	a5,74(s2)
    8000442a:	06f05463          	blez	a5,80004492 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000442e:	04491703          	lh	a4,68(s2)
    80004432:	4785                	li	a5,1
    80004434:	06f70563          	beq	a4,a5,8000449e <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004438:	4641                	li	a2,16
    8000443a:	4581                	li	a1,0
    8000443c:	fc040513          	addi	a0,s0,-64
    80004440:	e73fb0ef          	jal	ra,800002b2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004444:	4741                	li	a4,16
    80004446:	f2c42683          	lw	a3,-212(s0)
    8000444a:	fc040613          	addi	a2,s0,-64
    8000444e:	4581                	li	a1,0
    80004450:	8526                	mv	a0,s1
    80004452:	8d5fe0ef          	jal	ra,80002d26 <writei>
    80004456:	47c1                	li	a5,16
    80004458:	08f51563          	bne	a0,a5,800044e2 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    8000445c:	04491703          	lh	a4,68(s2)
    80004460:	4785                	li	a5,1
    80004462:	08f70663          	beq	a4,a5,800044ee <sys_unlink+0x140>
  iunlockput(dp);
    80004466:	8526                	mv	a0,s1
    80004468:	f90fe0ef          	jal	ra,80002bf8 <iunlockput>
  ip->nlink--;
    8000446c:	04a95783          	lhu	a5,74(s2)
    80004470:	37fd                	addiw	a5,a5,-1
    80004472:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004476:	854a                	mv	a0,s2
    80004478:	cc6fe0ef          	jal	ra,8000293e <iupdate>
  iunlockput(ip);
    8000447c:	854a                	mv	a0,s2
    8000447e:	f7afe0ef          	jal	ra,80002bf8 <iunlockput>
  end_op();
    80004482:	e73fe0ef          	jal	ra,800032f4 <end_op>
  return 0;
    80004486:	4501                	li	a0,0
    80004488:	a079                	j	80004516 <sys_unlink+0x168>
    end_op();
    8000448a:	e6bfe0ef          	jal	ra,800032f4 <end_op>
    return -1;
    8000448e:	557d                	li	a0,-1
    80004490:	a059                	j	80004516 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004492:	00003517          	auipc	a0,0x3
    80004496:	3b650513          	addi	a0,a0,950 # 80007848 <syscalls+0x318>
    8000449a:	1d8010ef          	jal	ra,80005672 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000449e:	04c92703          	lw	a4,76(s2)
    800044a2:	02000793          	li	a5,32
    800044a6:	f8e7f9e3          	bgeu	a5,a4,80004438 <sys_unlink+0x8a>
    800044aa:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044ae:	4741                	li	a4,16
    800044b0:	86ce                	mv	a3,s3
    800044b2:	f1840613          	addi	a2,s0,-232
    800044b6:	4581                	li	a1,0
    800044b8:	854a                	mv	a0,s2
    800044ba:	f88fe0ef          	jal	ra,80002c42 <readi>
    800044be:	47c1                	li	a5,16
    800044c0:	00f51b63          	bne	a0,a5,800044d6 <sys_unlink+0x128>
    if(de.inum != 0)
    800044c4:	f1845783          	lhu	a5,-232(s0)
    800044c8:	ef95                	bnez	a5,80004504 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800044ca:	29c1                	addiw	s3,s3,16
    800044cc:	04c92783          	lw	a5,76(s2)
    800044d0:	fcf9efe3          	bltu	s3,a5,800044ae <sys_unlink+0x100>
    800044d4:	b795                	j	80004438 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800044d6:	00003517          	auipc	a0,0x3
    800044da:	38a50513          	addi	a0,a0,906 # 80007860 <syscalls+0x330>
    800044de:	194010ef          	jal	ra,80005672 <panic>
    panic("unlink: writei");
    800044e2:	00003517          	auipc	a0,0x3
    800044e6:	39650513          	addi	a0,a0,918 # 80007878 <syscalls+0x348>
    800044ea:	188010ef          	jal	ra,80005672 <panic>
    dp->nlink--;
    800044ee:	04a4d783          	lhu	a5,74(s1)
    800044f2:	37fd                	addiw	a5,a5,-1
    800044f4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800044f8:	8526                	mv	a0,s1
    800044fa:	c44fe0ef          	jal	ra,8000293e <iupdate>
    800044fe:	b7a5                	j	80004466 <sys_unlink+0xb8>
    return -1;
    80004500:	557d                	li	a0,-1
    80004502:	a811                	j	80004516 <sys_unlink+0x168>
    iunlockput(ip);
    80004504:	854a                	mv	a0,s2
    80004506:	ef2fe0ef          	jal	ra,80002bf8 <iunlockput>
  iunlockput(dp);
    8000450a:	8526                	mv	a0,s1
    8000450c:	eecfe0ef          	jal	ra,80002bf8 <iunlockput>
  end_op();
    80004510:	de5fe0ef          	jal	ra,800032f4 <end_op>
  return -1;
    80004514:	557d                	li	a0,-1
}
    80004516:	70ae                	ld	ra,232(sp)
    80004518:	740e                	ld	s0,224(sp)
    8000451a:	64ee                	ld	s1,216(sp)
    8000451c:	694e                	ld	s2,208(sp)
    8000451e:	69ae                	ld	s3,200(sp)
    80004520:	616d                	addi	sp,sp,240
    80004522:	8082                	ret

0000000080004524 <sys_open>:

uint64
sys_open(void)
{
    80004524:	7131                	addi	sp,sp,-192
    80004526:	fd06                	sd	ra,184(sp)
    80004528:	f922                	sd	s0,176(sp)
    8000452a:	f526                	sd	s1,168(sp)
    8000452c:	f14a                	sd	s2,160(sp)
    8000452e:	ed4e                	sd	s3,152(sp)
    80004530:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004532:	f4c40593          	addi	a1,s0,-180
    80004536:	4505                	li	a0,1
    80004538:	a5bfd0ef          	jal	ra,80001f92 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000453c:	08000613          	li	a2,128
    80004540:	f5040593          	addi	a1,s0,-176
    80004544:	4501                	li	a0,0
    80004546:	a85fd0ef          	jal	ra,80001fca <argstr>
    8000454a:	87aa                	mv	a5,a0
    return -1;
    8000454c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000454e:	0807cd63          	bltz	a5,800045e8 <sys_open+0xc4>

  begin_op();
    80004552:	d35fe0ef          	jal	ra,80003286 <begin_op>

  if(omode & O_CREATE){
    80004556:	f4c42783          	lw	a5,-180(s0)
    8000455a:	2007f793          	andi	a5,a5,512
    8000455e:	c3c5                	beqz	a5,800045fe <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004560:	4681                	li	a3,0
    80004562:	4601                	li	a2,0
    80004564:	4589                	li	a1,2
    80004566:	f5040513          	addi	a0,s0,-176
    8000456a:	abfff0ef          	jal	ra,80004028 <create>
    8000456e:	84aa                	mv	s1,a0
    if(ip == 0){
    80004570:	c159                	beqz	a0,800045f6 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004572:	04449703          	lh	a4,68(s1)
    80004576:	478d                	li	a5,3
    80004578:	00f71763          	bne	a4,a5,80004586 <sys_open+0x62>
    8000457c:	0464d703          	lhu	a4,70(s1)
    80004580:	47a5                	li	a5,9
    80004582:	0ae7e963          	bltu	a5,a4,80004634 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004586:	874ff0ef          	jal	ra,800035fa <filealloc>
    8000458a:	89aa                	mv	s3,a0
    8000458c:	0c050963          	beqz	a0,8000465e <sys_open+0x13a>
    80004590:	a5bff0ef          	jal	ra,80003fea <fdalloc>
    80004594:	892a                	mv	s2,a0
    80004596:	0c054163          	bltz	a0,80004658 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000459a:	04449703          	lh	a4,68(s1)
    8000459e:	478d                	li	a5,3
    800045a0:	0af70163          	beq	a4,a5,80004642 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800045a4:	4789                	li	a5,2
    800045a6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800045aa:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800045ae:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800045b2:	f4c42783          	lw	a5,-180(s0)
    800045b6:	0017c713          	xori	a4,a5,1
    800045ba:	8b05                	andi	a4,a4,1
    800045bc:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800045c0:	0037f713          	andi	a4,a5,3
    800045c4:	00e03733          	snez	a4,a4
    800045c8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800045cc:	4007f793          	andi	a5,a5,1024
    800045d0:	c791                	beqz	a5,800045dc <sys_open+0xb8>
    800045d2:	04449703          	lh	a4,68(s1)
    800045d6:	4789                	li	a5,2
    800045d8:	06f70c63          	beq	a4,a5,80004650 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    800045dc:	8526                	mv	a0,s1
    800045de:	cbefe0ef          	jal	ra,80002a9c <iunlock>
  end_op();
    800045e2:	d13fe0ef          	jal	ra,800032f4 <end_op>

  return fd;
    800045e6:	854a                	mv	a0,s2
}
    800045e8:	70ea                	ld	ra,184(sp)
    800045ea:	744a                	ld	s0,176(sp)
    800045ec:	74aa                	ld	s1,168(sp)
    800045ee:	790a                	ld	s2,160(sp)
    800045f0:	69ea                	ld	s3,152(sp)
    800045f2:	6129                	addi	sp,sp,192
    800045f4:	8082                	ret
      end_op();
    800045f6:	cfffe0ef          	jal	ra,800032f4 <end_op>
      return -1;
    800045fa:	557d                	li	a0,-1
    800045fc:	b7f5                	j	800045e8 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    800045fe:	f5040513          	addi	a0,s0,-176
    80004602:	aa9fe0ef          	jal	ra,800030aa <namei>
    80004606:	84aa                	mv	s1,a0
    80004608:	c115                	beqz	a0,8000462c <sys_open+0x108>
    ilock(ip);
    8000460a:	be8fe0ef          	jal	ra,800029f2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000460e:	04449703          	lh	a4,68(s1)
    80004612:	4785                	li	a5,1
    80004614:	f4f71fe3          	bne	a4,a5,80004572 <sys_open+0x4e>
    80004618:	f4c42783          	lw	a5,-180(s0)
    8000461c:	d7ad                	beqz	a5,80004586 <sys_open+0x62>
      iunlockput(ip);
    8000461e:	8526                	mv	a0,s1
    80004620:	dd8fe0ef          	jal	ra,80002bf8 <iunlockput>
      end_op();
    80004624:	cd1fe0ef          	jal	ra,800032f4 <end_op>
      return -1;
    80004628:	557d                	li	a0,-1
    8000462a:	bf7d                	j	800045e8 <sys_open+0xc4>
      end_op();
    8000462c:	cc9fe0ef          	jal	ra,800032f4 <end_op>
      return -1;
    80004630:	557d                	li	a0,-1
    80004632:	bf5d                	j	800045e8 <sys_open+0xc4>
    iunlockput(ip);
    80004634:	8526                	mv	a0,s1
    80004636:	dc2fe0ef          	jal	ra,80002bf8 <iunlockput>
    end_op();
    8000463a:	cbbfe0ef          	jal	ra,800032f4 <end_op>
    return -1;
    8000463e:	557d                	li	a0,-1
    80004640:	b765                	j	800045e8 <sys_open+0xc4>
    f->type = FD_DEVICE;
    80004642:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004646:	04649783          	lh	a5,70(s1)
    8000464a:	02f99223          	sh	a5,36(s3)
    8000464e:	b785                	j	800045ae <sys_open+0x8a>
    itrunc(ip);
    80004650:	8526                	mv	a0,s1
    80004652:	c8afe0ef          	jal	ra,80002adc <itrunc>
    80004656:	b759                	j	800045dc <sys_open+0xb8>
      fileclose(f);
    80004658:	854e                	mv	a0,s3
    8000465a:	844ff0ef          	jal	ra,8000369e <fileclose>
    iunlockput(ip);
    8000465e:	8526                	mv	a0,s1
    80004660:	d98fe0ef          	jal	ra,80002bf8 <iunlockput>
    end_op();
    80004664:	c91fe0ef          	jal	ra,800032f4 <end_op>
    return -1;
    80004668:	557d                	li	a0,-1
    8000466a:	bfbd                	j	800045e8 <sys_open+0xc4>

000000008000466c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000466c:	7175                	addi	sp,sp,-144
    8000466e:	e506                	sd	ra,136(sp)
    80004670:	e122                	sd	s0,128(sp)
    80004672:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004674:	c13fe0ef          	jal	ra,80003286 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004678:	08000613          	li	a2,128
    8000467c:	f7040593          	addi	a1,s0,-144
    80004680:	4501                	li	a0,0
    80004682:	949fd0ef          	jal	ra,80001fca <argstr>
    80004686:	02054363          	bltz	a0,800046ac <sys_mkdir+0x40>
    8000468a:	4681                	li	a3,0
    8000468c:	4601                	li	a2,0
    8000468e:	4585                	li	a1,1
    80004690:	f7040513          	addi	a0,s0,-144
    80004694:	995ff0ef          	jal	ra,80004028 <create>
    80004698:	c911                	beqz	a0,800046ac <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000469a:	d5efe0ef          	jal	ra,80002bf8 <iunlockput>
  end_op();
    8000469e:	c57fe0ef          	jal	ra,800032f4 <end_op>
  return 0;
    800046a2:	4501                	li	a0,0
}
    800046a4:	60aa                	ld	ra,136(sp)
    800046a6:	640a                	ld	s0,128(sp)
    800046a8:	6149                	addi	sp,sp,144
    800046aa:	8082                	ret
    end_op();
    800046ac:	c49fe0ef          	jal	ra,800032f4 <end_op>
    return -1;
    800046b0:	557d                	li	a0,-1
    800046b2:	bfcd                	j	800046a4 <sys_mkdir+0x38>

00000000800046b4 <sys_mknod>:

uint64
sys_mknod(void)
{
    800046b4:	7135                	addi	sp,sp,-160
    800046b6:	ed06                	sd	ra,152(sp)
    800046b8:	e922                	sd	s0,144(sp)
    800046ba:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800046bc:	bcbfe0ef          	jal	ra,80003286 <begin_op>
  argint(1, &major);
    800046c0:	f6c40593          	addi	a1,s0,-148
    800046c4:	4505                	li	a0,1
    800046c6:	8cdfd0ef          	jal	ra,80001f92 <argint>
  argint(2, &minor);
    800046ca:	f6840593          	addi	a1,s0,-152
    800046ce:	4509                	li	a0,2
    800046d0:	8c3fd0ef          	jal	ra,80001f92 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800046d4:	08000613          	li	a2,128
    800046d8:	f7040593          	addi	a1,s0,-144
    800046dc:	4501                	li	a0,0
    800046de:	8edfd0ef          	jal	ra,80001fca <argstr>
    800046e2:	02054563          	bltz	a0,8000470c <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800046e6:	f6841683          	lh	a3,-152(s0)
    800046ea:	f6c41603          	lh	a2,-148(s0)
    800046ee:	458d                	li	a1,3
    800046f0:	f7040513          	addi	a0,s0,-144
    800046f4:	935ff0ef          	jal	ra,80004028 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800046f8:	c911                	beqz	a0,8000470c <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800046fa:	cfefe0ef          	jal	ra,80002bf8 <iunlockput>
  end_op();
    800046fe:	bf7fe0ef          	jal	ra,800032f4 <end_op>
  return 0;
    80004702:	4501                	li	a0,0
}
    80004704:	60ea                	ld	ra,152(sp)
    80004706:	644a                	ld	s0,144(sp)
    80004708:	610d                	addi	sp,sp,160
    8000470a:	8082                	ret
    end_op();
    8000470c:	be9fe0ef          	jal	ra,800032f4 <end_op>
    return -1;
    80004710:	557d                	li	a0,-1
    80004712:	bfcd                	j	80004704 <sys_mknod+0x50>

0000000080004714 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004714:	7135                	addi	sp,sp,-160
    80004716:	ed06                	sd	ra,152(sp)
    80004718:	e922                	sd	s0,144(sp)
    8000471a:	e526                	sd	s1,136(sp)
    8000471c:	e14a                	sd	s2,128(sp)
    8000471e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004720:	9c5fc0ef          	jal	ra,800010e4 <myproc>
    80004724:	892a                	mv	s2,a0

  begin_op();
    80004726:	b61fe0ef          	jal	ra,80003286 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000472a:	08000613          	li	a2,128
    8000472e:	f6040593          	addi	a1,s0,-160
    80004732:	4501                	li	a0,0
    80004734:	897fd0ef          	jal	ra,80001fca <argstr>
    80004738:	04054163          	bltz	a0,8000477a <sys_chdir+0x66>
    8000473c:	f6040513          	addi	a0,s0,-160
    80004740:	96bfe0ef          	jal	ra,800030aa <namei>
    80004744:	84aa                	mv	s1,a0
    80004746:	c915                	beqz	a0,8000477a <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004748:	aaafe0ef          	jal	ra,800029f2 <ilock>
  if(ip->type != T_DIR){
    8000474c:	04449703          	lh	a4,68(s1)
    80004750:	4785                	li	a5,1
    80004752:	02f71863          	bne	a4,a5,80004782 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004756:	8526                	mv	a0,s1
    80004758:	b44fe0ef          	jal	ra,80002a9c <iunlock>
  iput(p->cwd);
    8000475c:	15093503          	ld	a0,336(s2)
    80004760:	c10fe0ef          	jal	ra,80002b70 <iput>
  end_op();
    80004764:	b91fe0ef          	jal	ra,800032f4 <end_op>
  p->cwd = ip;
    80004768:	14993823          	sd	s1,336(s2)
  return 0;
    8000476c:	4501                	li	a0,0
}
    8000476e:	60ea                	ld	ra,152(sp)
    80004770:	644a                	ld	s0,144(sp)
    80004772:	64aa                	ld	s1,136(sp)
    80004774:	690a                	ld	s2,128(sp)
    80004776:	610d                	addi	sp,sp,160
    80004778:	8082                	ret
    end_op();
    8000477a:	b7bfe0ef          	jal	ra,800032f4 <end_op>
    return -1;
    8000477e:	557d                	li	a0,-1
    80004780:	b7fd                	j	8000476e <sys_chdir+0x5a>
    iunlockput(ip);
    80004782:	8526                	mv	a0,s1
    80004784:	c74fe0ef          	jal	ra,80002bf8 <iunlockput>
    end_op();
    80004788:	b6dfe0ef          	jal	ra,800032f4 <end_op>
    return -1;
    8000478c:	557d                	li	a0,-1
    8000478e:	b7c5                	j	8000476e <sys_chdir+0x5a>

0000000080004790 <sys_exec>:

uint64
sys_exec(void)
{
    80004790:	7145                	addi	sp,sp,-464
    80004792:	e786                	sd	ra,456(sp)
    80004794:	e3a2                	sd	s0,448(sp)
    80004796:	ff26                	sd	s1,440(sp)
    80004798:	fb4a                	sd	s2,432(sp)
    8000479a:	f74e                	sd	s3,424(sp)
    8000479c:	f352                	sd	s4,416(sp)
    8000479e:	ef56                	sd	s5,408(sp)
    800047a0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800047a2:	e3840593          	addi	a1,s0,-456
    800047a6:	4505                	li	a0,1
    800047a8:	807fd0ef          	jal	ra,80001fae <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800047ac:	08000613          	li	a2,128
    800047b0:	f4040593          	addi	a1,s0,-192
    800047b4:	4501                	li	a0,0
    800047b6:	815fd0ef          	jal	ra,80001fca <argstr>
    800047ba:	87aa                	mv	a5,a0
    return -1;
    800047bc:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800047be:	0a07c563          	bltz	a5,80004868 <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    800047c2:	10000613          	li	a2,256
    800047c6:	4581                	li	a1,0
    800047c8:	e4040513          	addi	a0,s0,-448
    800047cc:	ae7fb0ef          	jal	ra,800002b2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800047d0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800047d4:	89a6                	mv	s3,s1
    800047d6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800047d8:	02000a13          	li	s4,32
    800047dc:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800047e0:	00391513          	slli	a0,s2,0x3
    800047e4:	e3040593          	addi	a1,s0,-464
    800047e8:	e3843783          	ld	a5,-456(s0)
    800047ec:	953e                	add	a0,a0,a5
    800047ee:	f1afd0ef          	jal	ra,80001f08 <fetchaddr>
    800047f2:	02054663          	bltz	a0,8000481e <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    800047f6:	e3043783          	ld	a5,-464(s0)
    800047fa:	cf8d                	beqz	a5,80004834 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800047fc:	969fb0ef          	jal	ra,80000164 <kalloc>
    80004800:	85aa                	mv	a1,a0
    80004802:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004806:	cd01                	beqz	a0,8000481e <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004808:	6605                	lui	a2,0x1
    8000480a:	e3043503          	ld	a0,-464(s0)
    8000480e:	f44fd0ef          	jal	ra,80001f52 <fetchstr>
    80004812:	00054663          	bltz	a0,8000481e <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80004816:	0905                	addi	s2,s2,1
    80004818:	09a1                	addi	s3,s3,8
    8000481a:	fd4911e3          	bne	s2,s4,800047dc <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000481e:	f4040913          	addi	s2,s0,-192
    80004822:	6088                	ld	a0,0(s1)
    80004824:	c129                	beqz	a0,80004866 <sys_exec+0xd6>
    kfree(argv[i]);
    80004826:	84bfb0ef          	jal	ra,80000070 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000482a:	04a1                	addi	s1,s1,8
    8000482c:	ff249be3          	bne	s1,s2,80004822 <sys_exec+0x92>
  return -1;
    80004830:	557d                	li	a0,-1
    80004832:	a81d                	j	80004868 <sys_exec+0xd8>
      argv[i] = 0;
    80004834:	0a8e                	slli	s5,s5,0x3
    80004836:	fc0a8793          	addi	a5,s5,-64
    8000483a:	00878ab3          	add	s5,a5,s0
    8000483e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80004842:	e4040593          	addi	a1,s0,-448
    80004846:	f4040513          	addi	a0,s0,-192
    8000484a:	bf6ff0ef          	jal	ra,80003c40 <exec>
    8000484e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004850:	f4040993          	addi	s3,s0,-192
    80004854:	6088                	ld	a0,0(s1)
    80004856:	c511                	beqz	a0,80004862 <sys_exec+0xd2>
    kfree(argv[i]);
    80004858:	819fb0ef          	jal	ra,80000070 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000485c:	04a1                	addi	s1,s1,8
    8000485e:	ff349be3          	bne	s1,s3,80004854 <sys_exec+0xc4>
  return ret;
    80004862:	854a                	mv	a0,s2
    80004864:	a011                	j	80004868 <sys_exec+0xd8>
  return -1;
    80004866:	557d                	li	a0,-1
}
    80004868:	60be                	ld	ra,456(sp)
    8000486a:	641e                	ld	s0,448(sp)
    8000486c:	74fa                	ld	s1,440(sp)
    8000486e:	795a                	ld	s2,432(sp)
    80004870:	79ba                	ld	s3,424(sp)
    80004872:	7a1a                	ld	s4,416(sp)
    80004874:	6afa                	ld	s5,408(sp)
    80004876:	6179                	addi	sp,sp,464
    80004878:	8082                	ret

000000008000487a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000487a:	7139                	addi	sp,sp,-64
    8000487c:	fc06                	sd	ra,56(sp)
    8000487e:	f822                	sd	s0,48(sp)
    80004880:	f426                	sd	s1,40(sp)
    80004882:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004884:	861fc0ef          	jal	ra,800010e4 <myproc>
    80004888:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000488a:	fd840593          	addi	a1,s0,-40
    8000488e:	4501                	li	a0,0
    80004890:	f1efd0ef          	jal	ra,80001fae <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004894:	fc840593          	addi	a1,s0,-56
    80004898:	fd040513          	addi	a0,s0,-48
    8000489c:	8ceff0ef          	jal	ra,8000396a <pipealloc>
    return -1;
    800048a0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800048a2:	0a054463          	bltz	a0,8000494a <sys_pipe+0xd0>
  fd0 = -1;
    800048a6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800048aa:	fd043503          	ld	a0,-48(s0)
    800048ae:	f3cff0ef          	jal	ra,80003fea <fdalloc>
    800048b2:	fca42223          	sw	a0,-60(s0)
    800048b6:	08054163          	bltz	a0,80004938 <sys_pipe+0xbe>
    800048ba:	fc843503          	ld	a0,-56(s0)
    800048be:	f2cff0ef          	jal	ra,80003fea <fdalloc>
    800048c2:	fca42023          	sw	a0,-64(s0)
    800048c6:	06054063          	bltz	a0,80004926 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800048ca:	4691                	li	a3,4
    800048cc:	fc440613          	addi	a2,s0,-60
    800048d0:	fd843583          	ld	a1,-40(s0)
    800048d4:	68a8                	ld	a0,80(s1)
    800048d6:	bb2fc0ef          	jal	ra,80000c88 <copyout>
    800048da:	00054e63          	bltz	a0,800048f6 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800048de:	4691                	li	a3,4
    800048e0:	fc040613          	addi	a2,s0,-64
    800048e4:	fd843583          	ld	a1,-40(s0)
    800048e8:	0591                	addi	a1,a1,4
    800048ea:	68a8                	ld	a0,80(s1)
    800048ec:	b9cfc0ef          	jal	ra,80000c88 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800048f0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800048f2:	04055c63          	bgez	a0,8000494a <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800048f6:	fc442783          	lw	a5,-60(s0)
    800048fa:	07e9                	addi	a5,a5,26
    800048fc:	078e                	slli	a5,a5,0x3
    800048fe:	97a6                	add	a5,a5,s1
    80004900:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004904:	fc042783          	lw	a5,-64(s0)
    80004908:	07e9                	addi	a5,a5,26
    8000490a:	078e                	slli	a5,a5,0x3
    8000490c:	94be                	add	s1,s1,a5
    8000490e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80004912:	fd043503          	ld	a0,-48(s0)
    80004916:	d89fe0ef          	jal	ra,8000369e <fileclose>
    fileclose(wf);
    8000491a:	fc843503          	ld	a0,-56(s0)
    8000491e:	d81fe0ef          	jal	ra,8000369e <fileclose>
    return -1;
    80004922:	57fd                	li	a5,-1
    80004924:	a01d                	j	8000494a <sys_pipe+0xd0>
    if(fd0 >= 0)
    80004926:	fc442783          	lw	a5,-60(s0)
    8000492a:	0007c763          	bltz	a5,80004938 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000492e:	07e9                	addi	a5,a5,26
    80004930:	078e                	slli	a5,a5,0x3
    80004932:	97a6                	add	a5,a5,s1
    80004934:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80004938:	fd043503          	ld	a0,-48(s0)
    8000493c:	d63fe0ef          	jal	ra,8000369e <fileclose>
    fileclose(wf);
    80004940:	fc843503          	ld	a0,-56(s0)
    80004944:	d5bfe0ef          	jal	ra,8000369e <fileclose>
    return -1;
    80004948:	57fd                	li	a5,-1
}
    8000494a:	853e                	mv	a0,a5
    8000494c:	70e2                	ld	ra,56(sp)
    8000494e:	7442                	ld	s0,48(sp)
    80004950:	74a2                	ld	s1,40(sp)
    80004952:	6121                	addi	sp,sp,64
    80004954:	8082                	ret
	...

0000000080004960 <kernelvec>:
    80004960:	7111                	addi	sp,sp,-256
    80004962:	e006                	sd	ra,0(sp)
    80004964:	e40a                	sd	sp,8(sp)
    80004966:	e80e                	sd	gp,16(sp)
    80004968:	ec12                	sd	tp,24(sp)
    8000496a:	f016                	sd	t0,32(sp)
    8000496c:	f41a                	sd	t1,40(sp)
    8000496e:	f81e                	sd	t2,48(sp)
    80004970:	e4aa                	sd	a0,72(sp)
    80004972:	e8ae                	sd	a1,80(sp)
    80004974:	ecb2                	sd	a2,88(sp)
    80004976:	f0b6                	sd	a3,96(sp)
    80004978:	f4ba                	sd	a4,104(sp)
    8000497a:	f8be                	sd	a5,112(sp)
    8000497c:	fcc2                	sd	a6,120(sp)
    8000497e:	e146                	sd	a7,128(sp)
    80004980:	edf2                	sd	t3,216(sp)
    80004982:	f1f6                	sd	t4,224(sp)
    80004984:	f5fa                	sd	t5,232(sp)
    80004986:	f9fe                	sd	t6,240(sp)
    80004988:	c90fd0ef          	jal	ra,80001e18 <kerneltrap>
    8000498c:	6082                	ld	ra,0(sp)
    8000498e:	6122                	ld	sp,8(sp)
    80004990:	61c2                	ld	gp,16(sp)
    80004992:	7282                	ld	t0,32(sp)
    80004994:	7322                	ld	t1,40(sp)
    80004996:	73c2                	ld	t2,48(sp)
    80004998:	6526                	ld	a0,72(sp)
    8000499a:	65c6                	ld	a1,80(sp)
    8000499c:	6666                	ld	a2,88(sp)
    8000499e:	7686                	ld	a3,96(sp)
    800049a0:	7726                	ld	a4,104(sp)
    800049a2:	77c6                	ld	a5,112(sp)
    800049a4:	7866                	ld	a6,120(sp)
    800049a6:	688a                	ld	a7,128(sp)
    800049a8:	6e6e                	ld	t3,216(sp)
    800049aa:	7e8e                	ld	t4,224(sp)
    800049ac:	7f2e                	ld	t5,232(sp)
    800049ae:	7fce                	ld	t6,240(sp)
    800049b0:	6111                	addi	sp,sp,256
    800049b2:	10200073          	sret
	...

00000000800049be <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800049be:	1141                	addi	sp,sp,-16
    800049c0:	e422                	sd	s0,8(sp)
    800049c2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800049c4:	0c0007b7          	lui	a5,0xc000
    800049c8:	4705                	li	a4,1
    800049ca:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800049cc:	c3d8                	sw	a4,4(a5)
}
    800049ce:	6422                	ld	s0,8(sp)
    800049d0:	0141                	addi	sp,sp,16
    800049d2:	8082                	ret

00000000800049d4 <plicinithart>:

void
plicinithart(void)
{
    800049d4:	1141                	addi	sp,sp,-16
    800049d6:	e406                	sd	ra,8(sp)
    800049d8:	e022                	sd	s0,0(sp)
    800049da:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800049dc:	edcfc0ef          	jal	ra,800010b8 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800049e0:	0085171b          	slliw	a4,a0,0x8
    800049e4:	0c0027b7          	lui	a5,0xc002
    800049e8:	97ba                	add	a5,a5,a4
    800049ea:	40200713          	li	a4,1026
    800049ee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800049f2:	00d5151b          	slliw	a0,a0,0xd
    800049f6:	0c2017b7          	lui	a5,0xc201
    800049fa:	97aa                	add	a5,a5,a0
    800049fc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80004a00:	60a2                	ld	ra,8(sp)
    80004a02:	6402                	ld	s0,0(sp)
    80004a04:	0141                	addi	sp,sp,16
    80004a06:	8082                	ret

0000000080004a08 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80004a08:	1141                	addi	sp,sp,-16
    80004a0a:	e406                	sd	ra,8(sp)
    80004a0c:	e022                	sd	s0,0(sp)
    80004a0e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004a10:	ea8fc0ef          	jal	ra,800010b8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80004a14:	00d5151b          	slliw	a0,a0,0xd
    80004a18:	0c2017b7          	lui	a5,0xc201
    80004a1c:	97aa                	add	a5,a5,a0
  return irq;
}
    80004a1e:	43c8                	lw	a0,4(a5)
    80004a20:	60a2                	ld	ra,8(sp)
    80004a22:	6402                	ld	s0,0(sp)
    80004a24:	0141                	addi	sp,sp,16
    80004a26:	8082                	ret

0000000080004a28 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80004a28:	1101                	addi	sp,sp,-32
    80004a2a:	ec06                	sd	ra,24(sp)
    80004a2c:	e822                	sd	s0,16(sp)
    80004a2e:	e426                	sd	s1,8(sp)
    80004a30:	1000                	addi	s0,sp,32
    80004a32:	84aa                	mv	s1,a0
  int hart = cpuid();
    80004a34:	e84fc0ef          	jal	ra,800010b8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80004a38:	00d5151b          	slliw	a0,a0,0xd
    80004a3c:	0c2017b7          	lui	a5,0xc201
    80004a40:	97aa                	add	a5,a5,a0
    80004a42:	c3c4                	sw	s1,4(a5)
}
    80004a44:	60e2                	ld	ra,24(sp)
    80004a46:	6442                	ld	s0,16(sp)
    80004a48:	64a2                	ld	s1,8(sp)
    80004a4a:	6105                	addi	sp,sp,32
    80004a4c:	8082                	ret

0000000080004a4e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80004a4e:	1141                	addi	sp,sp,-16
    80004a50:	e406                	sd	ra,8(sp)
    80004a52:	e022                	sd	s0,0(sp)
    80004a54:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80004a56:	479d                	li	a5,7
    80004a58:	04a7ca63          	blt	a5,a0,80004aac <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80004a5c:	00014797          	auipc	a5,0x14
    80004a60:	33478793          	addi	a5,a5,820 # 80018d90 <disk>
    80004a64:	97aa                	add	a5,a5,a0
    80004a66:	0187c783          	lbu	a5,24(a5)
    80004a6a:	e7b9                	bnez	a5,80004ab8 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004a6c:	00451693          	slli	a3,a0,0x4
    80004a70:	00014797          	auipc	a5,0x14
    80004a74:	32078793          	addi	a5,a5,800 # 80018d90 <disk>
    80004a78:	6398                	ld	a4,0(a5)
    80004a7a:	9736                	add	a4,a4,a3
    80004a7c:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004a80:	6398                	ld	a4,0(a5)
    80004a82:	9736                	add	a4,a4,a3
    80004a84:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80004a88:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004a8c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004a90:	97aa                	add	a5,a5,a0
    80004a92:	4705                	li	a4,1
    80004a94:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80004a98:	00014517          	auipc	a0,0x14
    80004a9c:	31050513          	addi	a0,a0,784 # 80018da8 <disk+0x18>
    80004aa0:	c5dfc0ef          	jal	ra,800016fc <wakeup>
}
    80004aa4:	60a2                	ld	ra,8(sp)
    80004aa6:	6402                	ld	s0,0(sp)
    80004aa8:	0141                	addi	sp,sp,16
    80004aaa:	8082                	ret
    panic("free_desc 1");
    80004aac:	00003517          	auipc	a0,0x3
    80004ab0:	ddc50513          	addi	a0,a0,-548 # 80007888 <syscalls+0x358>
    80004ab4:	3bf000ef          	jal	ra,80005672 <panic>
    panic("free_desc 2");
    80004ab8:	00003517          	auipc	a0,0x3
    80004abc:	de050513          	addi	a0,a0,-544 # 80007898 <syscalls+0x368>
    80004ac0:	3b3000ef          	jal	ra,80005672 <panic>

0000000080004ac4 <virtio_disk_init>:
{
    80004ac4:	1101                	addi	sp,sp,-32
    80004ac6:	ec06                	sd	ra,24(sp)
    80004ac8:	e822                	sd	s0,16(sp)
    80004aca:	e426                	sd	s1,8(sp)
    80004acc:	e04a                	sd	s2,0(sp)
    80004ace:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004ad0:	00003597          	auipc	a1,0x3
    80004ad4:	dd858593          	addi	a1,a1,-552 # 800078a8 <syscalls+0x378>
    80004ad8:	00014517          	auipc	a0,0x14
    80004adc:	3e050513          	addi	a0,a0,992 # 80018eb8 <disk+0x128>
    80004ae0:	623000ef          	jal	ra,80005902 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004ae4:	100017b7          	lui	a5,0x10001
    80004ae8:	4398                	lw	a4,0(a5)
    80004aea:	2701                	sext.w	a4,a4
    80004aec:	747277b7          	lui	a5,0x74727
    80004af0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004af4:	12f71f63          	bne	a4,a5,80004c32 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004af8:	100017b7          	lui	a5,0x10001
    80004afc:	43dc                	lw	a5,4(a5)
    80004afe:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004b00:	4709                	li	a4,2
    80004b02:	12e79863          	bne	a5,a4,80004c32 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004b06:	100017b7          	lui	a5,0x10001
    80004b0a:	479c                	lw	a5,8(a5)
    80004b0c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004b0e:	12e79263          	bne	a5,a4,80004c32 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80004b12:	100017b7          	lui	a5,0x10001
    80004b16:	47d8                	lw	a4,12(a5)
    80004b18:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004b1a:	554d47b7          	lui	a5,0x554d4
    80004b1e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004b22:	10f71863          	bne	a4,a5,80004c32 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004b26:	100017b7          	lui	a5,0x10001
    80004b2a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004b2e:	4705                	li	a4,1
    80004b30:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004b32:	470d                	li	a4,3
    80004b34:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004b36:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004b38:	c7ffe6b7          	lui	a3,0xc7ffe
    80004b3c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd78f>
    80004b40:	8f75                	and	a4,a4,a3
    80004b42:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004b44:	472d                	li	a4,11
    80004b46:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80004b48:	5bbc                	lw	a5,112(a5)
    80004b4a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004b4e:	8ba1                	andi	a5,a5,8
    80004b50:	0e078763          	beqz	a5,80004c3e <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004b54:	100017b7          	lui	a5,0x10001
    80004b58:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004b5c:	43fc                	lw	a5,68(a5)
    80004b5e:	2781                	sext.w	a5,a5
    80004b60:	0e079563          	bnez	a5,80004c4a <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004b64:	100017b7          	lui	a5,0x10001
    80004b68:	5bdc                	lw	a5,52(a5)
    80004b6a:	2781                	sext.w	a5,a5
  if(max == 0)
    80004b6c:	0e078563          	beqz	a5,80004c56 <virtio_disk_init+0x192>
  if(max < NUM)
    80004b70:	471d                	li	a4,7
    80004b72:	0ef77863          	bgeu	a4,a5,80004c62 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80004b76:	deefb0ef          	jal	ra,80000164 <kalloc>
    80004b7a:	00014497          	auipc	s1,0x14
    80004b7e:	21648493          	addi	s1,s1,534 # 80018d90 <disk>
    80004b82:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004b84:	de0fb0ef          	jal	ra,80000164 <kalloc>
    80004b88:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004b8a:	ddafb0ef          	jal	ra,80000164 <kalloc>
    80004b8e:	87aa                	mv	a5,a0
    80004b90:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004b92:	6088                	ld	a0,0(s1)
    80004b94:	cd69                	beqz	a0,80004c6e <virtio_disk_init+0x1aa>
    80004b96:	00014717          	auipc	a4,0x14
    80004b9a:	20273703          	ld	a4,514(a4) # 80018d98 <disk+0x8>
    80004b9e:	cb61                	beqz	a4,80004c6e <virtio_disk_init+0x1aa>
    80004ba0:	c7f9                	beqz	a5,80004c6e <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80004ba2:	6605                	lui	a2,0x1
    80004ba4:	4581                	li	a1,0
    80004ba6:	f0cfb0ef          	jal	ra,800002b2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80004baa:	00014497          	auipc	s1,0x14
    80004bae:	1e648493          	addi	s1,s1,486 # 80018d90 <disk>
    80004bb2:	6605                	lui	a2,0x1
    80004bb4:	4581                	li	a1,0
    80004bb6:	6488                	ld	a0,8(s1)
    80004bb8:	efafb0ef          	jal	ra,800002b2 <memset>
  memset(disk.used, 0, PGSIZE);
    80004bbc:	6605                	lui	a2,0x1
    80004bbe:	4581                	li	a1,0
    80004bc0:	6888                	ld	a0,16(s1)
    80004bc2:	ef0fb0ef          	jal	ra,800002b2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004bc6:	100017b7          	lui	a5,0x10001
    80004bca:	4721                	li	a4,8
    80004bcc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004bce:	4098                	lw	a4,0(s1)
    80004bd0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004bd4:	40d8                	lw	a4,4(s1)
    80004bd6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004bda:	6498                	ld	a4,8(s1)
    80004bdc:	0007069b          	sext.w	a3,a4
    80004be0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004be4:	9701                	srai	a4,a4,0x20
    80004be6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004bea:	6898                	ld	a4,16(s1)
    80004bec:	0007069b          	sext.w	a3,a4
    80004bf0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004bf4:	9701                	srai	a4,a4,0x20
    80004bf6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004bfa:	4705                	li	a4,1
    80004bfc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80004bfe:	00e48c23          	sb	a4,24(s1)
    80004c02:	00e48ca3          	sb	a4,25(s1)
    80004c06:	00e48d23          	sb	a4,26(s1)
    80004c0a:	00e48da3          	sb	a4,27(s1)
    80004c0e:	00e48e23          	sb	a4,28(s1)
    80004c12:	00e48ea3          	sb	a4,29(s1)
    80004c16:	00e48f23          	sb	a4,30(s1)
    80004c1a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004c1e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004c22:	0727a823          	sw	s2,112(a5)
}
    80004c26:	60e2                	ld	ra,24(sp)
    80004c28:	6442                	ld	s0,16(sp)
    80004c2a:	64a2                	ld	s1,8(sp)
    80004c2c:	6902                	ld	s2,0(sp)
    80004c2e:	6105                	addi	sp,sp,32
    80004c30:	8082                	ret
    panic("could not find virtio disk");
    80004c32:	00003517          	auipc	a0,0x3
    80004c36:	c8650513          	addi	a0,a0,-890 # 800078b8 <syscalls+0x388>
    80004c3a:	239000ef          	jal	ra,80005672 <panic>
    panic("virtio disk FEATURES_OK unset");
    80004c3e:	00003517          	auipc	a0,0x3
    80004c42:	c9a50513          	addi	a0,a0,-870 # 800078d8 <syscalls+0x3a8>
    80004c46:	22d000ef          	jal	ra,80005672 <panic>
    panic("virtio disk should not be ready");
    80004c4a:	00003517          	auipc	a0,0x3
    80004c4e:	cae50513          	addi	a0,a0,-850 # 800078f8 <syscalls+0x3c8>
    80004c52:	221000ef          	jal	ra,80005672 <panic>
    panic("virtio disk has no queue 0");
    80004c56:	00003517          	auipc	a0,0x3
    80004c5a:	cc250513          	addi	a0,a0,-830 # 80007918 <syscalls+0x3e8>
    80004c5e:	215000ef          	jal	ra,80005672 <panic>
    panic("virtio disk max queue too short");
    80004c62:	00003517          	auipc	a0,0x3
    80004c66:	cd650513          	addi	a0,a0,-810 # 80007938 <syscalls+0x408>
    80004c6a:	209000ef          	jal	ra,80005672 <panic>
    panic("virtio disk kalloc");
    80004c6e:	00003517          	auipc	a0,0x3
    80004c72:	cea50513          	addi	a0,a0,-790 # 80007958 <syscalls+0x428>
    80004c76:	1fd000ef          	jal	ra,80005672 <panic>

0000000080004c7a <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004c7a:	7119                	addi	sp,sp,-128
    80004c7c:	fc86                	sd	ra,120(sp)
    80004c7e:	f8a2                	sd	s0,112(sp)
    80004c80:	f4a6                	sd	s1,104(sp)
    80004c82:	f0ca                	sd	s2,96(sp)
    80004c84:	ecce                	sd	s3,88(sp)
    80004c86:	e8d2                	sd	s4,80(sp)
    80004c88:	e4d6                	sd	s5,72(sp)
    80004c8a:	e0da                	sd	s6,64(sp)
    80004c8c:	fc5e                	sd	s7,56(sp)
    80004c8e:	f862                	sd	s8,48(sp)
    80004c90:	f466                	sd	s9,40(sp)
    80004c92:	f06a                	sd	s10,32(sp)
    80004c94:	ec6e                	sd	s11,24(sp)
    80004c96:	0100                	addi	s0,sp,128
    80004c98:	8aaa                	mv	s5,a0
    80004c9a:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004c9c:	00c52d03          	lw	s10,12(a0)
    80004ca0:	001d1d1b          	slliw	s10,s10,0x1
    80004ca4:	1d02                	slli	s10,s10,0x20
    80004ca6:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80004caa:	00014517          	auipc	a0,0x14
    80004cae:	20e50513          	addi	a0,a0,526 # 80018eb8 <disk+0x128>
    80004cb2:	4d1000ef          	jal	ra,80005982 <acquire>
  for(int i = 0; i < 3; i++){
    80004cb6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004cb8:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004cba:	00014b97          	auipc	s7,0x14
    80004cbe:	0d6b8b93          	addi	s7,s7,214 # 80018d90 <disk>
  for(int i = 0; i < 3; i++){
    80004cc2:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004cc4:	00014c97          	auipc	s9,0x14
    80004cc8:	1f4c8c93          	addi	s9,s9,500 # 80018eb8 <disk+0x128>
    80004ccc:	a8a9                	j	80004d26 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004cce:	00fb8733          	add	a4,s7,a5
    80004cd2:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80004cd6:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004cd8:	0207c563          	bltz	a5,80004d02 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80004cdc:	2905                	addiw	s2,s2,1
    80004cde:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004ce0:	05690863          	beq	s2,s6,80004d30 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80004ce4:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004ce6:	00014717          	auipc	a4,0x14
    80004cea:	0aa70713          	addi	a4,a4,170 # 80018d90 <disk>
    80004cee:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004cf0:	01874683          	lbu	a3,24(a4)
    80004cf4:	fee9                	bnez	a3,80004cce <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80004cf6:	2785                	addiw	a5,a5,1
    80004cf8:	0705                	addi	a4,a4,1
    80004cfa:	fe979be3          	bne	a5,s1,80004cf0 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80004cfe:	57fd                	li	a5,-1
    80004d00:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004d02:	01205b63          	blez	s2,80004d18 <virtio_disk_rw+0x9e>
    80004d06:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80004d08:	000a2503          	lw	a0,0(s4)
    80004d0c:	d43ff0ef          	jal	ra,80004a4e <free_desc>
      for(int j = 0; j < i; j++)
    80004d10:	2d85                	addiw	s11,s11,1
    80004d12:	0a11                	addi	s4,s4,4
    80004d14:	ff2d9ae3          	bne	s11,s2,80004d08 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004d18:	85e6                	mv	a1,s9
    80004d1a:	00014517          	auipc	a0,0x14
    80004d1e:	08e50513          	addi	a0,a0,142 # 80018da8 <disk+0x18>
    80004d22:	98ffc0ef          	jal	ra,800016b0 <sleep>
  for(int i = 0; i < 3; i++){
    80004d26:	f8040a13          	addi	s4,s0,-128
{
    80004d2a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80004d2c:	894e                	mv	s2,s3
    80004d2e:	bf5d                	j	80004ce4 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004d30:	f8042503          	lw	a0,-128(s0)
    80004d34:	00a50713          	addi	a4,a0,10
    80004d38:	0712                	slli	a4,a4,0x4

  if(write)
    80004d3a:	00014797          	auipc	a5,0x14
    80004d3e:	05678793          	addi	a5,a5,86 # 80018d90 <disk>
    80004d42:	00e786b3          	add	a3,a5,a4
    80004d46:	01803633          	snez	a2,s8
    80004d4a:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004d4c:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80004d50:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004d54:	f6070613          	addi	a2,a4,-160
    80004d58:	6394                	ld	a3,0(a5)
    80004d5a:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004d5c:	00870593          	addi	a1,a4,8
    80004d60:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004d62:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004d64:	0007b803          	ld	a6,0(a5)
    80004d68:	9642                	add	a2,a2,a6
    80004d6a:	46c1                	li	a3,16
    80004d6c:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004d6e:	4585                	li	a1,1
    80004d70:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80004d74:	f8442683          	lw	a3,-124(s0)
    80004d78:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004d7c:	0692                	slli	a3,a3,0x4
    80004d7e:	9836                	add	a6,a6,a3
    80004d80:	058a8613          	addi	a2,s5,88
    80004d84:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80004d88:	0007b803          	ld	a6,0(a5)
    80004d8c:	96c2                	add	a3,a3,a6
    80004d8e:	40000613          	li	a2,1024
    80004d92:	c690                	sw	a2,8(a3)
  if(write)
    80004d94:	001c3613          	seqz	a2,s8
    80004d98:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004d9c:	00166613          	ori	a2,a2,1
    80004da0:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80004da4:	f8842603          	lw	a2,-120(s0)
    80004da8:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004dac:	00250693          	addi	a3,a0,2
    80004db0:	0692                	slli	a3,a3,0x4
    80004db2:	96be                	add	a3,a3,a5
    80004db4:	58fd                	li	a7,-1
    80004db6:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004dba:	0612                	slli	a2,a2,0x4
    80004dbc:	9832                	add	a6,a6,a2
    80004dbe:	f9070713          	addi	a4,a4,-112
    80004dc2:	973e                	add	a4,a4,a5
    80004dc4:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80004dc8:	6398                	ld	a4,0(a5)
    80004dca:	9732                	add	a4,a4,a2
    80004dcc:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004dce:	4609                	li	a2,2
    80004dd0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80004dd4:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004dd8:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80004ddc:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004de0:	6794                	ld	a3,8(a5)
    80004de2:	0026d703          	lhu	a4,2(a3)
    80004de6:	8b1d                	andi	a4,a4,7
    80004de8:	0706                	slli	a4,a4,0x1
    80004dea:	96ba                	add	a3,a3,a4
    80004dec:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004df0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004df4:	6798                	ld	a4,8(a5)
    80004df6:	00275783          	lhu	a5,2(a4)
    80004dfa:	2785                	addiw	a5,a5,1
    80004dfc:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004e00:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004e04:	100017b7          	lui	a5,0x10001
    80004e08:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004e0c:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80004e10:	00014917          	auipc	s2,0x14
    80004e14:	0a890913          	addi	s2,s2,168 # 80018eb8 <disk+0x128>
  while(b->disk == 1) {
    80004e18:	4485                	li	s1,1
    80004e1a:	00b79a63          	bne	a5,a1,80004e2e <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80004e1e:	85ca                	mv	a1,s2
    80004e20:	8556                	mv	a0,s5
    80004e22:	88ffc0ef          	jal	ra,800016b0 <sleep>
  while(b->disk == 1) {
    80004e26:	004aa783          	lw	a5,4(s5)
    80004e2a:	fe978ae3          	beq	a5,s1,80004e1e <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80004e2e:	f8042903          	lw	s2,-128(s0)
    80004e32:	00290713          	addi	a4,s2,2
    80004e36:	0712                	slli	a4,a4,0x4
    80004e38:	00014797          	auipc	a5,0x14
    80004e3c:	f5878793          	addi	a5,a5,-168 # 80018d90 <disk>
    80004e40:	97ba                	add	a5,a5,a4
    80004e42:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004e46:	00014997          	auipc	s3,0x14
    80004e4a:	f4a98993          	addi	s3,s3,-182 # 80018d90 <disk>
    80004e4e:	00491713          	slli	a4,s2,0x4
    80004e52:	0009b783          	ld	a5,0(s3)
    80004e56:	97ba                	add	a5,a5,a4
    80004e58:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004e5c:	854a                	mv	a0,s2
    80004e5e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004e62:	bedff0ef          	jal	ra,80004a4e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004e66:	8885                	andi	s1,s1,1
    80004e68:	f0fd                	bnez	s1,80004e4e <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004e6a:	00014517          	auipc	a0,0x14
    80004e6e:	04e50513          	addi	a0,a0,78 # 80018eb8 <disk+0x128>
    80004e72:	3a9000ef          	jal	ra,80005a1a <release>
}
    80004e76:	70e6                	ld	ra,120(sp)
    80004e78:	7446                	ld	s0,112(sp)
    80004e7a:	74a6                	ld	s1,104(sp)
    80004e7c:	7906                	ld	s2,96(sp)
    80004e7e:	69e6                	ld	s3,88(sp)
    80004e80:	6a46                	ld	s4,80(sp)
    80004e82:	6aa6                	ld	s5,72(sp)
    80004e84:	6b06                	ld	s6,64(sp)
    80004e86:	7be2                	ld	s7,56(sp)
    80004e88:	7c42                	ld	s8,48(sp)
    80004e8a:	7ca2                	ld	s9,40(sp)
    80004e8c:	7d02                	ld	s10,32(sp)
    80004e8e:	6de2                	ld	s11,24(sp)
    80004e90:	6109                	addi	sp,sp,128
    80004e92:	8082                	ret

0000000080004e94 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004e94:	1101                	addi	sp,sp,-32
    80004e96:	ec06                	sd	ra,24(sp)
    80004e98:	e822                	sd	s0,16(sp)
    80004e9a:	e426                	sd	s1,8(sp)
    80004e9c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004e9e:	00014497          	auipc	s1,0x14
    80004ea2:	ef248493          	addi	s1,s1,-270 # 80018d90 <disk>
    80004ea6:	00014517          	auipc	a0,0x14
    80004eaa:	01250513          	addi	a0,a0,18 # 80018eb8 <disk+0x128>
    80004eae:	2d5000ef          	jal	ra,80005982 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004eb2:	10001737          	lui	a4,0x10001
    80004eb6:	533c                	lw	a5,96(a4)
    80004eb8:	8b8d                	andi	a5,a5,3
    80004eba:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80004ebc:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004ec0:	689c                	ld	a5,16(s1)
    80004ec2:	0204d703          	lhu	a4,32(s1)
    80004ec6:	0027d783          	lhu	a5,2(a5)
    80004eca:	04f70663          	beq	a4,a5,80004f16 <virtio_disk_intr+0x82>
    __sync_synchronize();
    80004ece:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004ed2:	6898                	ld	a4,16(s1)
    80004ed4:	0204d783          	lhu	a5,32(s1)
    80004ed8:	8b9d                	andi	a5,a5,7
    80004eda:	078e                	slli	a5,a5,0x3
    80004edc:	97ba                	add	a5,a5,a4
    80004ede:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004ee0:	00278713          	addi	a4,a5,2
    80004ee4:	0712                	slli	a4,a4,0x4
    80004ee6:	9726                	add	a4,a4,s1
    80004ee8:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80004eec:	e321                	bnez	a4,80004f2c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004eee:	0789                	addi	a5,a5,2
    80004ef0:	0792                	slli	a5,a5,0x4
    80004ef2:	97a6                	add	a5,a5,s1
    80004ef4:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004ef6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004efa:	803fc0ef          	jal	ra,800016fc <wakeup>

    disk.used_idx += 1;
    80004efe:	0204d783          	lhu	a5,32(s1)
    80004f02:	2785                	addiw	a5,a5,1
    80004f04:	17c2                	slli	a5,a5,0x30
    80004f06:	93c1                	srli	a5,a5,0x30
    80004f08:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004f0c:	6898                	ld	a4,16(s1)
    80004f0e:	00275703          	lhu	a4,2(a4)
    80004f12:	faf71ee3          	bne	a4,a5,80004ece <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80004f16:	00014517          	auipc	a0,0x14
    80004f1a:	fa250513          	addi	a0,a0,-94 # 80018eb8 <disk+0x128>
    80004f1e:	2fd000ef          	jal	ra,80005a1a <release>
}
    80004f22:	60e2                	ld	ra,24(sp)
    80004f24:	6442                	ld	s0,16(sp)
    80004f26:	64a2                	ld	s1,8(sp)
    80004f28:	6105                	addi	sp,sp,32
    80004f2a:	8082                	ret
      panic("virtio_disk_intr status");
    80004f2c:	00003517          	auipc	a0,0x3
    80004f30:	a4450513          	addi	a0,a0,-1468 # 80007970 <syscalls+0x440>
    80004f34:	73e000ef          	jal	ra,80005672 <panic>

0000000080004f38 <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004f38:	1141                	addi	sp,sp,-16
    80004f3a:	e422                	sd	s0,8(sp)
    80004f3c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004f3e:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004f42:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004f46:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004f4a:	30a027f3          	csrr	a5,0x30a

  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63));
    80004f4e:	577d                	li	a4,-1
    80004f50:	177e                	slli	a4,a4,0x3f
    80004f52:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004f54:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004f58:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004f5c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004f60:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004f64:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004f68:	000f4737          	lui	a4,0xf4
    80004f6c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004f70:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004f72:	14d79073          	csrw	0x14d,a5
}
    80004f76:	6422                	ld	s0,8(sp)
    80004f78:	0141                	addi	sp,sp,16
    80004f7a:	8082                	ret

0000000080004f7c <start>:
{
    80004f7c:	1141                	addi	sp,sp,-16
    80004f7e:	e406                	sd	ra,8(sp)
    80004f80:	e022                	sd	s0,0(sp)
    80004f82:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004f84:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004f88:	7779                	lui	a4,0xffffe
    80004f8a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd82f>
    80004f8e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004f90:	6705                	lui	a4,0x1
    80004f92:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004f96:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004f98:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004f9c:	ffffb797          	auipc	a5,0xffffb
    80004fa0:	4b878793          	addi	a5,a5,1208 # 80000454 <main>
    80004fa4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004fa8:	4781                	li	a5,0
    80004faa:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004fae:	67c1                	lui	a5,0x10
    80004fb0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004fb2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004fb6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004fba:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004fbe:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004fc2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004fc6:	57fd                	li	a5,-1
    80004fc8:	83a9                	srli	a5,a5,0xa
    80004fca:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004fce:	47bd                	li	a5,15
    80004fd0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004fd4:	f65ff0ef          	jal	ra,80004f38 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004fd8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004fdc:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004fde:	823e                	mv	tp,a5
  asm volatile("mret");
    80004fe0:	30200073          	mret
}
    80004fe4:	60a2                	ld	ra,8(sp)
    80004fe6:	6402                	ld	s0,0(sp)
    80004fe8:	0141                	addi	sp,sp,16
    80004fea:	8082                	ret

0000000080004fec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004fec:	715d                	addi	sp,sp,-80
    80004fee:	e486                	sd	ra,72(sp)
    80004ff0:	e0a2                	sd	s0,64(sp)
    80004ff2:	fc26                	sd	s1,56(sp)
    80004ff4:	f84a                	sd	s2,48(sp)
    80004ff6:	f44e                	sd	s3,40(sp)
    80004ff8:	f052                	sd	s4,32(sp)
    80004ffa:	ec56                	sd	s5,24(sp)
    80004ffc:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004ffe:	04c05363          	blez	a2,80005044 <consolewrite+0x58>
    80005002:	8a2a                	mv	s4,a0
    80005004:	84ae                	mv	s1,a1
    80005006:	89b2                	mv	s3,a2
    80005008:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000500a:	5afd                	li	s5,-1
    8000500c:	4685                	li	a3,1
    8000500e:	8626                	mv	a2,s1
    80005010:	85d2                	mv	a1,s4
    80005012:	fbf40513          	addi	a0,s0,-65
    80005016:	a41fc0ef          	jal	ra,80001a56 <either_copyin>
    8000501a:	01550b63          	beq	a0,s5,80005030 <consolewrite+0x44>
      break;
    uartputc(c);
    8000501e:	fbf44503          	lbu	a0,-65(s0)
    80005022:	7da000ef          	jal	ra,800057fc <uartputc>
  for(i = 0; i < n; i++){
    80005026:	2905                	addiw	s2,s2,1
    80005028:	0485                	addi	s1,s1,1
    8000502a:	ff2991e3          	bne	s3,s2,8000500c <consolewrite+0x20>
    8000502e:	894e                	mv	s2,s3
  }

  return i;
}
    80005030:	854a                	mv	a0,s2
    80005032:	60a6                	ld	ra,72(sp)
    80005034:	6406                	ld	s0,64(sp)
    80005036:	74e2                	ld	s1,56(sp)
    80005038:	7942                	ld	s2,48(sp)
    8000503a:	79a2                	ld	s3,40(sp)
    8000503c:	7a02                	ld	s4,32(sp)
    8000503e:	6ae2                	ld	s5,24(sp)
    80005040:	6161                	addi	sp,sp,80
    80005042:	8082                	ret
  for(i = 0; i < n; i++){
    80005044:	4901                	li	s2,0
    80005046:	b7ed                	j	80005030 <consolewrite+0x44>

0000000080005048 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005048:	7159                	addi	sp,sp,-112
    8000504a:	f486                	sd	ra,104(sp)
    8000504c:	f0a2                	sd	s0,96(sp)
    8000504e:	eca6                	sd	s1,88(sp)
    80005050:	e8ca                	sd	s2,80(sp)
    80005052:	e4ce                	sd	s3,72(sp)
    80005054:	e0d2                	sd	s4,64(sp)
    80005056:	fc56                	sd	s5,56(sp)
    80005058:	f85a                	sd	s6,48(sp)
    8000505a:	f45e                	sd	s7,40(sp)
    8000505c:	f062                	sd	s8,32(sp)
    8000505e:	ec66                	sd	s9,24(sp)
    80005060:	e86a                	sd	s10,16(sp)
    80005062:	1880                	addi	s0,sp,112
    80005064:	8aaa                	mv	s5,a0
    80005066:	8a2e                	mv	s4,a1
    80005068:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000506a:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000506e:	0001c517          	auipc	a0,0x1c
    80005072:	e6250513          	addi	a0,a0,-414 # 80020ed0 <cons>
    80005076:	10d000ef          	jal	ra,80005982 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000507a:	0001c497          	auipc	s1,0x1c
    8000507e:	e5648493          	addi	s1,s1,-426 # 80020ed0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80005082:	0001c917          	auipc	s2,0x1c
    80005086:	ee690913          	addi	s2,s2,-282 # 80020f68 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    8000508a:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000508c:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000508e:	4ca9                	li	s9,10
  while(n > 0){
    80005090:	07305363          	blez	s3,800050f6 <consoleread+0xae>
    while(cons.r == cons.w){
    80005094:	0984a783          	lw	a5,152(s1)
    80005098:	09c4a703          	lw	a4,156(s1)
    8000509c:	02f71163          	bne	a4,a5,800050be <consoleread+0x76>
      if(killed(myproc())){
    800050a0:	844fc0ef          	jal	ra,800010e4 <myproc>
    800050a4:	845fc0ef          	jal	ra,800018e8 <killed>
    800050a8:	e125                	bnez	a0,80005108 <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800050aa:	85a6                	mv	a1,s1
    800050ac:	854a                	mv	a0,s2
    800050ae:	e02fc0ef          	jal	ra,800016b0 <sleep>
    while(cons.r == cons.w){
    800050b2:	0984a783          	lw	a5,152(s1)
    800050b6:	09c4a703          	lw	a4,156(s1)
    800050ba:	fef703e3          	beq	a4,a5,800050a0 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800050be:	0017871b          	addiw	a4,a5,1
    800050c2:	08e4ac23          	sw	a4,152(s1)
    800050c6:	07f7f713          	andi	a4,a5,127
    800050ca:	9726                	add	a4,a4,s1
    800050cc:	01874703          	lbu	a4,24(a4)
    800050d0:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800050d4:	057d0f63          	beq	s10,s7,80005132 <consoleread+0xea>
    cbuf = c;
    800050d8:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800050dc:	4685                	li	a3,1
    800050de:	f9f40613          	addi	a2,s0,-97
    800050e2:	85d2                	mv	a1,s4
    800050e4:	8556                	mv	a0,s5
    800050e6:	927fc0ef          	jal	ra,80001a0c <either_copyout>
    800050ea:	01850663          	beq	a0,s8,800050f6 <consoleread+0xae>
    dst++;
    800050ee:	0a05                	addi	s4,s4,1
    --n;
    800050f0:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800050f2:	f99d1fe3          	bne	s10,s9,80005090 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800050f6:	0001c517          	auipc	a0,0x1c
    800050fa:	dda50513          	addi	a0,a0,-550 # 80020ed0 <cons>
    800050fe:	11d000ef          	jal	ra,80005a1a <release>

  return target - n;
    80005102:	413b053b          	subw	a0,s6,s3
    80005106:	a801                	j	80005116 <consoleread+0xce>
        release(&cons.lock);
    80005108:	0001c517          	auipc	a0,0x1c
    8000510c:	dc850513          	addi	a0,a0,-568 # 80020ed0 <cons>
    80005110:	10b000ef          	jal	ra,80005a1a <release>
        return -1;
    80005114:	557d                	li	a0,-1
}
    80005116:	70a6                	ld	ra,104(sp)
    80005118:	7406                	ld	s0,96(sp)
    8000511a:	64e6                	ld	s1,88(sp)
    8000511c:	6946                	ld	s2,80(sp)
    8000511e:	69a6                	ld	s3,72(sp)
    80005120:	6a06                	ld	s4,64(sp)
    80005122:	7ae2                	ld	s5,56(sp)
    80005124:	7b42                	ld	s6,48(sp)
    80005126:	7ba2                	ld	s7,40(sp)
    80005128:	7c02                	ld	s8,32(sp)
    8000512a:	6ce2                	ld	s9,24(sp)
    8000512c:	6d42                	ld	s10,16(sp)
    8000512e:	6165                	addi	sp,sp,112
    80005130:	8082                	ret
      if(n < target){
    80005132:	0009871b          	sext.w	a4,s3
    80005136:	fd6770e3          	bgeu	a4,s6,800050f6 <consoleread+0xae>
        cons.r--;
    8000513a:	0001c717          	auipc	a4,0x1c
    8000513e:	e2f72723          	sw	a5,-466(a4) # 80020f68 <cons+0x98>
    80005142:	bf55                	j	800050f6 <consoleread+0xae>

0000000080005144 <consputc>:
{
    80005144:	1141                	addi	sp,sp,-16
    80005146:	e406                	sd	ra,8(sp)
    80005148:	e022                	sd	s0,0(sp)
    8000514a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000514c:	10000793          	li	a5,256
    80005150:	00f50863          	beq	a0,a5,80005160 <consputc+0x1c>
    uartputc_sync(c);
    80005154:	5d2000ef          	jal	ra,80005726 <uartputc_sync>
}
    80005158:	60a2                	ld	ra,8(sp)
    8000515a:	6402                	ld	s0,0(sp)
    8000515c:	0141                	addi	sp,sp,16
    8000515e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005160:	4521                	li	a0,8
    80005162:	5c4000ef          	jal	ra,80005726 <uartputc_sync>
    80005166:	02000513          	li	a0,32
    8000516a:	5bc000ef          	jal	ra,80005726 <uartputc_sync>
    8000516e:	4521                	li	a0,8
    80005170:	5b6000ef          	jal	ra,80005726 <uartputc_sync>
    80005174:	b7d5                	j	80005158 <consputc+0x14>

0000000080005176 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005176:	1101                	addi	sp,sp,-32
    80005178:	ec06                	sd	ra,24(sp)
    8000517a:	e822                	sd	s0,16(sp)
    8000517c:	e426                	sd	s1,8(sp)
    8000517e:	e04a                	sd	s2,0(sp)
    80005180:	1000                	addi	s0,sp,32
    80005182:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005184:	0001c517          	auipc	a0,0x1c
    80005188:	d4c50513          	addi	a0,a0,-692 # 80020ed0 <cons>
    8000518c:	7f6000ef          	jal	ra,80005982 <acquire>

  switch(c){
    80005190:	47d5                	li	a5,21
    80005192:	0af48063          	beq	s1,a5,80005232 <consoleintr+0xbc>
    80005196:	0297c663          	blt	a5,s1,800051c2 <consoleintr+0x4c>
    8000519a:	47a1                	li	a5,8
    8000519c:	0cf48f63          	beq	s1,a5,8000527a <consoleintr+0x104>
    800051a0:	47c1                	li	a5,16
    800051a2:	10f49063          	bne	s1,a5,800052a2 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    800051a6:	8fbfc0ef          	jal	ra,80001aa0 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800051aa:	0001c517          	auipc	a0,0x1c
    800051ae:	d2650513          	addi	a0,a0,-730 # 80020ed0 <cons>
    800051b2:	069000ef          	jal	ra,80005a1a <release>
}
    800051b6:	60e2                	ld	ra,24(sp)
    800051b8:	6442                	ld	s0,16(sp)
    800051ba:	64a2                	ld	s1,8(sp)
    800051bc:	6902                	ld	s2,0(sp)
    800051be:	6105                	addi	sp,sp,32
    800051c0:	8082                	ret
  switch(c){
    800051c2:	07f00793          	li	a5,127
    800051c6:	0af48a63          	beq	s1,a5,8000527a <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800051ca:	0001c717          	auipc	a4,0x1c
    800051ce:	d0670713          	addi	a4,a4,-762 # 80020ed0 <cons>
    800051d2:	0a072783          	lw	a5,160(a4)
    800051d6:	09872703          	lw	a4,152(a4)
    800051da:	9f99                	subw	a5,a5,a4
    800051dc:	07f00713          	li	a4,127
    800051e0:	fcf765e3          	bltu	a4,a5,800051aa <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    800051e4:	47b5                	li	a5,13
    800051e6:	0cf48163          	beq	s1,a5,800052a8 <consoleintr+0x132>
      consputc(c);
    800051ea:	8526                	mv	a0,s1
    800051ec:	f59ff0ef          	jal	ra,80005144 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800051f0:	0001c797          	auipc	a5,0x1c
    800051f4:	ce078793          	addi	a5,a5,-800 # 80020ed0 <cons>
    800051f8:	0a07a683          	lw	a3,160(a5)
    800051fc:	0016871b          	addiw	a4,a3,1
    80005200:	0007061b          	sext.w	a2,a4
    80005204:	0ae7a023          	sw	a4,160(a5)
    80005208:	07f6f693          	andi	a3,a3,127
    8000520c:	97b6                	add	a5,a5,a3
    8000520e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005212:	47a9                	li	a5,10
    80005214:	0af48f63          	beq	s1,a5,800052d2 <consoleintr+0x15c>
    80005218:	4791                	li	a5,4
    8000521a:	0af48c63          	beq	s1,a5,800052d2 <consoleintr+0x15c>
    8000521e:	0001c797          	auipc	a5,0x1c
    80005222:	d4a7a783          	lw	a5,-694(a5) # 80020f68 <cons+0x98>
    80005226:	9f1d                	subw	a4,a4,a5
    80005228:	08000793          	li	a5,128
    8000522c:	f6f71fe3          	bne	a4,a5,800051aa <consoleintr+0x34>
    80005230:	a04d                	j	800052d2 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80005232:	0001c717          	auipc	a4,0x1c
    80005236:	c9e70713          	addi	a4,a4,-866 # 80020ed0 <cons>
    8000523a:	0a072783          	lw	a5,160(a4)
    8000523e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005242:	0001c497          	auipc	s1,0x1c
    80005246:	c8e48493          	addi	s1,s1,-882 # 80020ed0 <cons>
    while(cons.e != cons.w &&
    8000524a:	4929                	li	s2,10
    8000524c:	f4f70fe3          	beq	a4,a5,800051aa <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005250:	37fd                	addiw	a5,a5,-1
    80005252:	07f7f713          	andi	a4,a5,127
    80005256:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005258:	01874703          	lbu	a4,24(a4)
    8000525c:	f52707e3          	beq	a4,s2,800051aa <consoleintr+0x34>
      cons.e--;
    80005260:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005264:	10000513          	li	a0,256
    80005268:	eddff0ef          	jal	ra,80005144 <consputc>
    while(cons.e != cons.w &&
    8000526c:	0a04a783          	lw	a5,160(s1)
    80005270:	09c4a703          	lw	a4,156(s1)
    80005274:	fcf71ee3          	bne	a4,a5,80005250 <consoleintr+0xda>
    80005278:	bf0d                	j	800051aa <consoleintr+0x34>
    if(cons.e != cons.w){
    8000527a:	0001c717          	auipc	a4,0x1c
    8000527e:	c5670713          	addi	a4,a4,-938 # 80020ed0 <cons>
    80005282:	0a072783          	lw	a5,160(a4)
    80005286:	09c72703          	lw	a4,156(a4)
    8000528a:	f2f700e3          	beq	a4,a5,800051aa <consoleintr+0x34>
      cons.e--;
    8000528e:	37fd                	addiw	a5,a5,-1
    80005290:	0001c717          	auipc	a4,0x1c
    80005294:	cef72023          	sw	a5,-800(a4) # 80020f70 <cons+0xa0>
      consputc(BACKSPACE);
    80005298:	10000513          	li	a0,256
    8000529c:	ea9ff0ef          	jal	ra,80005144 <consputc>
    800052a0:	b729                	j	800051aa <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800052a2:	f00484e3          	beqz	s1,800051aa <consoleintr+0x34>
    800052a6:	b715                	j	800051ca <consoleintr+0x54>
      consputc(c);
    800052a8:	4529                	li	a0,10
    800052aa:	e9bff0ef          	jal	ra,80005144 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800052ae:	0001c797          	auipc	a5,0x1c
    800052b2:	c2278793          	addi	a5,a5,-990 # 80020ed0 <cons>
    800052b6:	0a07a703          	lw	a4,160(a5)
    800052ba:	0017069b          	addiw	a3,a4,1
    800052be:	0006861b          	sext.w	a2,a3
    800052c2:	0ad7a023          	sw	a3,160(a5)
    800052c6:	07f77713          	andi	a4,a4,127
    800052ca:	97ba                	add	a5,a5,a4
    800052cc:	4729                	li	a4,10
    800052ce:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800052d2:	0001c797          	auipc	a5,0x1c
    800052d6:	c8c7ad23          	sw	a2,-870(a5) # 80020f6c <cons+0x9c>
        wakeup(&cons.r);
    800052da:	0001c517          	auipc	a0,0x1c
    800052de:	c8e50513          	addi	a0,a0,-882 # 80020f68 <cons+0x98>
    800052e2:	c1afc0ef          	jal	ra,800016fc <wakeup>
    800052e6:	b5d1                	j	800051aa <consoleintr+0x34>

00000000800052e8 <consoleinit>:

void
consoleinit(void)
{
    800052e8:	1141                	addi	sp,sp,-16
    800052ea:	e406                	sd	ra,8(sp)
    800052ec:	e022                	sd	s0,0(sp)
    800052ee:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800052f0:	00002597          	auipc	a1,0x2
    800052f4:	69858593          	addi	a1,a1,1688 # 80007988 <syscalls+0x458>
    800052f8:	0001c517          	auipc	a0,0x1c
    800052fc:	bd850513          	addi	a0,a0,-1064 # 80020ed0 <cons>
    80005300:	602000ef          	jal	ra,80005902 <initlock>

  uartinit();
    80005304:	3d6000ef          	jal	ra,800056da <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005308:	00013797          	auipc	a5,0x13
    8000530c:	a3078793          	addi	a5,a5,-1488 # 80017d38 <devsw>
    80005310:	00000717          	auipc	a4,0x0
    80005314:	d3870713          	addi	a4,a4,-712 # 80005048 <consoleread>
    80005318:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000531a:	00000717          	auipc	a4,0x0
    8000531e:	cd270713          	addi	a4,a4,-814 # 80004fec <consolewrite>
    80005322:	ef98                	sd	a4,24(a5)
}
    80005324:	60a2                	ld	ra,8(sp)
    80005326:	6402                	ld	s0,0(sp)
    80005328:	0141                	addi	sp,sp,16
    8000532a:	8082                	ret

000000008000532c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000532c:	7179                	addi	sp,sp,-48
    8000532e:	f406                	sd	ra,40(sp)
    80005330:	f022                	sd	s0,32(sp)
    80005332:	ec26                	sd	s1,24(sp)
    80005334:	e84a                	sd	s2,16(sp)
    80005336:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80005338:	c219                	beqz	a2,8000533e <printint+0x12>
    8000533a:	06054e63          	bltz	a0,800053b6 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000533e:	4881                	li	a7,0
    80005340:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005344:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80005346:	00002617          	auipc	a2,0x2
    8000534a:	66a60613          	addi	a2,a2,1642 # 800079b0 <digits>
    8000534e:	883e                	mv	a6,a5
    80005350:	2785                	addiw	a5,a5,1
    80005352:	02b57733          	remu	a4,a0,a1
    80005356:	9732                	add	a4,a4,a2
    80005358:	00074703          	lbu	a4,0(a4)
    8000535c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80005360:	872a                	mv	a4,a0
    80005362:	02b55533          	divu	a0,a0,a1
    80005366:	0685                	addi	a3,a3,1
    80005368:	feb773e3          	bgeu	a4,a1,8000534e <printint+0x22>

  if(sign)
    8000536c:	00088a63          	beqz	a7,80005380 <printint+0x54>
    buf[i++] = '-';
    80005370:	1781                	addi	a5,a5,-32
    80005372:	97a2                	add	a5,a5,s0
    80005374:	02d00713          	li	a4,45
    80005378:	fee78823          	sb	a4,-16(a5)
    8000537c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80005380:	02f05563          	blez	a5,800053aa <printint+0x7e>
    80005384:	fd040713          	addi	a4,s0,-48
    80005388:	00f704b3          	add	s1,a4,a5
    8000538c:	fff70913          	addi	s2,a4,-1
    80005390:	993e                	add	s2,s2,a5
    80005392:	37fd                	addiw	a5,a5,-1
    80005394:	1782                	slli	a5,a5,0x20
    80005396:	9381                	srli	a5,a5,0x20
    80005398:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    8000539c:	fff4c503          	lbu	a0,-1(s1)
    800053a0:	da5ff0ef          	jal	ra,80005144 <consputc>
  while(--i >= 0)
    800053a4:	14fd                	addi	s1,s1,-1
    800053a6:	ff249be3          	bne	s1,s2,8000539c <printint+0x70>
}
    800053aa:	70a2                	ld	ra,40(sp)
    800053ac:	7402                	ld	s0,32(sp)
    800053ae:	64e2                	ld	s1,24(sp)
    800053b0:	6942                	ld	s2,16(sp)
    800053b2:	6145                	addi	sp,sp,48
    800053b4:	8082                	ret
    x = -xx;
    800053b6:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800053ba:	4885                	li	a7,1
    x = -xx;
    800053bc:	b751                	j	80005340 <printint+0x14>

00000000800053be <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800053be:	7155                	addi	sp,sp,-208
    800053c0:	e506                	sd	ra,136(sp)
    800053c2:	e122                	sd	s0,128(sp)
    800053c4:	fca6                	sd	s1,120(sp)
    800053c6:	f8ca                	sd	s2,112(sp)
    800053c8:	f4ce                	sd	s3,104(sp)
    800053ca:	f0d2                	sd	s4,96(sp)
    800053cc:	ecd6                	sd	s5,88(sp)
    800053ce:	e8da                	sd	s6,80(sp)
    800053d0:	e4de                	sd	s7,72(sp)
    800053d2:	e0e2                	sd	s8,64(sp)
    800053d4:	fc66                	sd	s9,56(sp)
    800053d6:	f86a                	sd	s10,48(sp)
    800053d8:	f46e                	sd	s11,40(sp)
    800053da:	0900                	addi	s0,sp,144
    800053dc:	8a2a                	mv	s4,a0
    800053de:	e40c                	sd	a1,8(s0)
    800053e0:	e810                	sd	a2,16(s0)
    800053e2:	ec14                	sd	a3,24(s0)
    800053e4:	f018                	sd	a4,32(s0)
    800053e6:	f41c                	sd	a5,40(s0)
    800053e8:	03043823          	sd	a6,48(s0)
    800053ec:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800053f0:	0001c797          	auipc	a5,0x1c
    800053f4:	ba07a783          	lw	a5,-1120(a5) # 80020f90 <pr+0x18>
    800053f8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800053fc:	eb9d                	bnez	a5,80005432 <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800053fe:	00840793          	addi	a5,s0,8
    80005402:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005406:	00054503          	lbu	a0,0(a0)
    8000540a:	24050463          	beqz	a0,80005652 <printf+0x294>
    8000540e:	4981                	li	s3,0
    if(cx != '%'){
    80005410:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005414:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80005418:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000541c:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005420:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005424:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005428:	00002b97          	auipc	s7,0x2
    8000542c:	588b8b93          	addi	s7,s7,1416 # 800079b0 <digits>
    80005430:	a081                	j	80005470 <printf+0xb2>
    acquire(&pr.lock);
    80005432:	0001c517          	auipc	a0,0x1c
    80005436:	b4650513          	addi	a0,a0,-1210 # 80020f78 <pr>
    8000543a:	548000ef          	jal	ra,80005982 <acquire>
  va_start(ap, fmt);
    8000543e:	00840793          	addi	a5,s0,8
    80005442:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005446:	000a4503          	lbu	a0,0(s4)
    8000544a:	f171                	bnez	a0,8000540e <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    8000544c:	0001c517          	auipc	a0,0x1c
    80005450:	b2c50513          	addi	a0,a0,-1236 # 80020f78 <pr>
    80005454:	5c6000ef          	jal	ra,80005a1a <release>
    80005458:	aaed                	j	80005652 <printf+0x294>
      consputc(cx);
    8000545a:	cebff0ef          	jal	ra,80005144 <consputc>
      continue;
    8000545e:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005460:	0014899b          	addiw	s3,s1,1
    80005464:	013a07b3          	add	a5,s4,s3
    80005468:	0007c503          	lbu	a0,0(a5)
    8000546c:	1c050f63          	beqz	a0,8000564a <printf+0x28c>
    if(cx != '%'){
    80005470:	ff5515e3          	bne	a0,s5,8000545a <printf+0x9c>
    i++;
    80005474:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80005478:	009a07b3          	add	a5,s4,s1
    8000547c:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80005480:	1c090563          	beqz	s2,8000564a <printf+0x28c>
    80005484:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80005488:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000548a:	c789                	beqz	a5,80005494 <printf+0xd6>
    8000548c:	009a0733          	add	a4,s4,s1
    80005490:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005494:	03690463          	beq	s2,s6,800054bc <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    80005498:	03890e63          	beq	s2,s8,800054d4 <printf+0x116>
    } else if(c0 == 'u'){
    8000549c:	0b990d63          	beq	s2,s9,80005556 <printf+0x198>
    } else if(c0 == 'x'){
    800054a0:	11a90363          	beq	s2,s10,800055a6 <printf+0x1e8>
    } else if(c0 == 'p'){
    800054a4:	13b90b63          	beq	s2,s11,800055da <printf+0x21c>
    } else if(c0 == 's'){
    800054a8:	07300793          	li	a5,115
    800054ac:	16f90363          	beq	s2,a5,80005612 <printf+0x254>
    } else if(c0 == '%'){
    800054b0:	03591c63          	bne	s2,s5,800054e8 <printf+0x12a>
      consputc('%');
    800054b4:	8556                	mv	a0,s5
    800054b6:	c8fff0ef          	jal	ra,80005144 <consputc>
    800054ba:	b75d                	j	80005460 <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    800054bc:	f8843783          	ld	a5,-120(s0)
    800054c0:	00878713          	addi	a4,a5,8
    800054c4:	f8e43423          	sd	a4,-120(s0)
    800054c8:	4605                	li	a2,1
    800054ca:	45a9                	li	a1,10
    800054cc:	4388                	lw	a0,0(a5)
    800054ce:	e5fff0ef          	jal	ra,8000532c <printint>
    800054d2:	b779                	j	80005460 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    800054d4:	03678163          	beq	a5,s6,800054f6 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800054d8:	03878d63          	beq	a5,s8,80005512 <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    800054dc:	09978963          	beq	a5,s9,8000556e <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800054e0:	03878b63          	beq	a5,s8,80005516 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    800054e4:	0da78d63          	beq	a5,s10,800055be <printf+0x200>
      consputc('%');
    800054e8:	8556                	mv	a0,s5
    800054ea:	c5bff0ef          	jal	ra,80005144 <consputc>
      consputc(c0);
    800054ee:	854a                	mv	a0,s2
    800054f0:	c55ff0ef          	jal	ra,80005144 <consputc>
    800054f4:	b7b5                	j	80005460 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800054f6:	f8843783          	ld	a5,-120(s0)
    800054fa:	00878713          	addi	a4,a5,8
    800054fe:	f8e43423          	sd	a4,-120(s0)
    80005502:	4605                	li	a2,1
    80005504:	45a9                	li	a1,10
    80005506:	6388                	ld	a0,0(a5)
    80005508:	e25ff0ef          	jal	ra,8000532c <printint>
      i += 1;
    8000550c:	0029849b          	addiw	s1,s3,2
    80005510:	bf81                	j	80005460 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80005512:	03668463          	beq	a3,s6,8000553a <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005516:	07968a63          	beq	a3,s9,8000558a <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000551a:	fda697e3          	bne	a3,s10,800054e8 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    8000551e:	f8843783          	ld	a5,-120(s0)
    80005522:	00878713          	addi	a4,a5,8
    80005526:	f8e43423          	sd	a4,-120(s0)
    8000552a:	4601                	li	a2,0
    8000552c:	45c1                	li	a1,16
    8000552e:	6388                	ld	a0,0(a5)
    80005530:	dfdff0ef          	jal	ra,8000532c <printint>
      i += 2;
    80005534:	0039849b          	addiw	s1,s3,3
    80005538:	b725                	j	80005460 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    8000553a:	f8843783          	ld	a5,-120(s0)
    8000553e:	00878713          	addi	a4,a5,8
    80005542:	f8e43423          	sd	a4,-120(s0)
    80005546:	4605                	li	a2,1
    80005548:	45a9                	li	a1,10
    8000554a:	6388                	ld	a0,0(a5)
    8000554c:	de1ff0ef          	jal	ra,8000532c <printint>
      i += 2;
    80005550:	0039849b          	addiw	s1,s3,3
    80005554:	b731                	j	80005460 <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    80005556:	f8843783          	ld	a5,-120(s0)
    8000555a:	00878713          	addi	a4,a5,8
    8000555e:	f8e43423          	sd	a4,-120(s0)
    80005562:	4601                	li	a2,0
    80005564:	45a9                	li	a1,10
    80005566:	4388                	lw	a0,0(a5)
    80005568:	dc5ff0ef          	jal	ra,8000532c <printint>
    8000556c:	bdd5                	j	80005460 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000556e:	f8843783          	ld	a5,-120(s0)
    80005572:	00878713          	addi	a4,a5,8
    80005576:	f8e43423          	sd	a4,-120(s0)
    8000557a:	4601                	li	a2,0
    8000557c:	45a9                	li	a1,10
    8000557e:	6388                	ld	a0,0(a5)
    80005580:	dadff0ef          	jal	ra,8000532c <printint>
      i += 1;
    80005584:	0029849b          	addiw	s1,s3,2
    80005588:	bde1                	j	80005460 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000558a:	f8843783          	ld	a5,-120(s0)
    8000558e:	00878713          	addi	a4,a5,8
    80005592:	f8e43423          	sd	a4,-120(s0)
    80005596:	4601                	li	a2,0
    80005598:	45a9                	li	a1,10
    8000559a:	6388                	ld	a0,0(a5)
    8000559c:	d91ff0ef          	jal	ra,8000532c <printint>
      i += 2;
    800055a0:	0039849b          	addiw	s1,s3,3
    800055a4:	bd75                	j	80005460 <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    800055a6:	f8843783          	ld	a5,-120(s0)
    800055aa:	00878713          	addi	a4,a5,8
    800055ae:	f8e43423          	sd	a4,-120(s0)
    800055b2:	4601                	li	a2,0
    800055b4:	45c1                	li	a1,16
    800055b6:	4388                	lw	a0,0(a5)
    800055b8:	d75ff0ef          	jal	ra,8000532c <printint>
    800055bc:	b555                	j	80005460 <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    800055be:	f8843783          	ld	a5,-120(s0)
    800055c2:	00878713          	addi	a4,a5,8
    800055c6:	f8e43423          	sd	a4,-120(s0)
    800055ca:	4601                	li	a2,0
    800055cc:	45c1                	li	a1,16
    800055ce:	6388                	ld	a0,0(a5)
    800055d0:	d5dff0ef          	jal	ra,8000532c <printint>
      i += 1;
    800055d4:	0029849b          	addiw	s1,s3,2
    800055d8:	b561                	j	80005460 <printf+0xa2>
      printptr(va_arg(ap, uint64));
    800055da:	f8843783          	ld	a5,-120(s0)
    800055de:	00878713          	addi	a4,a5,8
    800055e2:	f8e43423          	sd	a4,-120(s0)
    800055e6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800055ea:	03000513          	li	a0,48
    800055ee:	b57ff0ef          	jal	ra,80005144 <consputc>
  consputc('x');
    800055f2:	856a                	mv	a0,s10
    800055f4:	b51ff0ef          	jal	ra,80005144 <consputc>
    800055f8:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800055fa:	03c9d793          	srli	a5,s3,0x3c
    800055fe:	97de                	add	a5,a5,s7
    80005600:	0007c503          	lbu	a0,0(a5)
    80005604:	b41ff0ef          	jal	ra,80005144 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005608:	0992                	slli	s3,s3,0x4
    8000560a:	397d                	addiw	s2,s2,-1
    8000560c:	fe0917e3          	bnez	s2,800055fa <printf+0x23c>
    80005610:	bd81                	j	80005460 <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    80005612:	f8843783          	ld	a5,-120(s0)
    80005616:	00878713          	addi	a4,a5,8
    8000561a:	f8e43423          	sd	a4,-120(s0)
    8000561e:	0007b903          	ld	s2,0(a5)
    80005622:	00090d63          	beqz	s2,8000563c <printf+0x27e>
      for(; *s; s++)
    80005626:	00094503          	lbu	a0,0(s2)
    8000562a:	e2050be3          	beqz	a0,80005460 <printf+0xa2>
        consputc(*s);
    8000562e:	b17ff0ef          	jal	ra,80005144 <consputc>
      for(; *s; s++)
    80005632:	0905                	addi	s2,s2,1
    80005634:	00094503          	lbu	a0,0(s2)
    80005638:	f97d                	bnez	a0,8000562e <printf+0x270>
    8000563a:	b51d                	j	80005460 <printf+0xa2>
        s = "(null)";
    8000563c:	00002917          	auipc	s2,0x2
    80005640:	35490913          	addi	s2,s2,852 # 80007990 <syscalls+0x460>
      for(; *s; s++)
    80005644:	02800513          	li	a0,40
    80005648:	b7dd                	j	8000562e <printf+0x270>
  if(locking)
    8000564a:	f7843783          	ld	a5,-136(s0)
    8000564e:	de079fe3          	bnez	a5,8000544c <printf+0x8e>

  return 0;
}
    80005652:	4501                	li	a0,0
    80005654:	60aa                	ld	ra,136(sp)
    80005656:	640a                	ld	s0,128(sp)
    80005658:	74e6                	ld	s1,120(sp)
    8000565a:	7946                	ld	s2,112(sp)
    8000565c:	79a6                	ld	s3,104(sp)
    8000565e:	7a06                	ld	s4,96(sp)
    80005660:	6ae6                	ld	s5,88(sp)
    80005662:	6b46                	ld	s6,80(sp)
    80005664:	6ba6                	ld	s7,72(sp)
    80005666:	6c06                	ld	s8,64(sp)
    80005668:	7ce2                	ld	s9,56(sp)
    8000566a:	7d42                	ld	s10,48(sp)
    8000566c:	7da2                	ld	s11,40(sp)
    8000566e:	6169                	addi	sp,sp,208
    80005670:	8082                	ret

0000000080005672 <panic>:

void
panic(char *s)
{
    80005672:	1101                	addi	sp,sp,-32
    80005674:	ec06                	sd	ra,24(sp)
    80005676:	e822                	sd	s0,16(sp)
    80005678:	e426                	sd	s1,8(sp)
    8000567a:	1000                	addi	s0,sp,32
    8000567c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000567e:	0001c797          	auipc	a5,0x1c
    80005682:	9007a923          	sw	zero,-1774(a5) # 80020f90 <pr+0x18>
  printf("panic: ");
    80005686:	00002517          	auipc	a0,0x2
    8000568a:	31250513          	addi	a0,a0,786 # 80007998 <syscalls+0x468>
    8000568e:	d31ff0ef          	jal	ra,800053be <printf>
  printf("%s\n", s);
    80005692:	85a6                	mv	a1,s1
    80005694:	00002517          	auipc	a0,0x2
    80005698:	30c50513          	addi	a0,a0,780 # 800079a0 <syscalls+0x470>
    8000569c:	d23ff0ef          	jal	ra,800053be <printf>
  panicked = 1; // freeze uart output from other CPUs
    800056a0:	4785                	li	a5,1
    800056a2:	00002717          	auipc	a4,0x2
    800056a6:	3ef72523          	sw	a5,1002(a4) # 80007a8c <panicked>
  for(;;)
    800056aa:	a001                	j	800056aa <panic+0x38>

00000000800056ac <printfinit>:
    ;
}

void
printfinit(void)
{
    800056ac:	1101                	addi	sp,sp,-32
    800056ae:	ec06                	sd	ra,24(sp)
    800056b0:	e822                	sd	s0,16(sp)
    800056b2:	e426                	sd	s1,8(sp)
    800056b4:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800056b6:	0001c497          	auipc	s1,0x1c
    800056ba:	8c248493          	addi	s1,s1,-1854 # 80020f78 <pr>
    800056be:	00002597          	auipc	a1,0x2
    800056c2:	2ea58593          	addi	a1,a1,746 # 800079a8 <syscalls+0x478>
    800056c6:	8526                	mv	a0,s1
    800056c8:	23a000ef          	jal	ra,80005902 <initlock>
  pr.locking = 1;
    800056cc:	4785                	li	a5,1
    800056ce:	cc9c                	sw	a5,24(s1)
}
    800056d0:	60e2                	ld	ra,24(sp)
    800056d2:	6442                	ld	s0,16(sp)
    800056d4:	64a2                	ld	s1,8(sp)
    800056d6:	6105                	addi	sp,sp,32
    800056d8:	8082                	ret

00000000800056da <uartinit>:

void uartstart();

void
uartinit(void)
{
    800056da:	1141                	addi	sp,sp,-16
    800056dc:	e406                	sd	ra,8(sp)
    800056de:	e022                	sd	s0,0(sp)
    800056e0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800056e2:	100007b7          	lui	a5,0x10000
    800056e6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800056ea:	f8000713          	li	a4,-128
    800056ee:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800056f2:	470d                	li	a4,3
    800056f4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800056f8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800056fc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005700:	469d                	li	a3,7
    80005702:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005706:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000570a:	00002597          	auipc	a1,0x2
    8000570e:	2be58593          	addi	a1,a1,702 # 800079c8 <digits+0x18>
    80005712:	0001c517          	auipc	a0,0x1c
    80005716:	88650513          	addi	a0,a0,-1914 # 80020f98 <uart_tx_lock>
    8000571a:	1e8000ef          	jal	ra,80005902 <initlock>
}
    8000571e:	60a2                	ld	ra,8(sp)
    80005720:	6402                	ld	s0,0(sp)
    80005722:	0141                	addi	sp,sp,16
    80005724:	8082                	ret

0000000080005726 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005726:	1101                	addi	sp,sp,-32
    80005728:	ec06                	sd	ra,24(sp)
    8000572a:	e822                	sd	s0,16(sp)
    8000572c:	e426                	sd	s1,8(sp)
    8000572e:	1000                	addi	s0,sp,32
    80005730:	84aa                	mv	s1,a0
  push_off();
    80005732:	210000ef          	jal	ra,80005942 <push_off>

  if(panicked){
    80005736:	00002797          	auipc	a5,0x2
    8000573a:	3567a783          	lw	a5,854(a5) # 80007a8c <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000573e:	10000737          	lui	a4,0x10000
  if(panicked){
    80005742:	c391                	beqz	a5,80005746 <uartputc_sync+0x20>
    for(;;)
    80005744:	a001                	j	80005744 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005746:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000574a:	0207f793          	andi	a5,a5,32
    8000574e:	dfe5                	beqz	a5,80005746 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80005750:	0ff4f513          	zext.b	a0,s1
    80005754:	100007b7          	lui	a5,0x10000
    80005758:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000575c:	26a000ef          	jal	ra,800059c6 <pop_off>
}
    80005760:	60e2                	ld	ra,24(sp)
    80005762:	6442                	ld	s0,16(sp)
    80005764:	64a2                	ld	s1,8(sp)
    80005766:	6105                	addi	sp,sp,32
    80005768:	8082                	ret

000000008000576a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000576a:	00002797          	auipc	a5,0x2
    8000576e:	3267b783          	ld	a5,806(a5) # 80007a90 <uart_tx_r>
    80005772:	00002717          	auipc	a4,0x2
    80005776:	32673703          	ld	a4,806(a4) # 80007a98 <uart_tx_w>
    8000577a:	06f70c63          	beq	a4,a5,800057f2 <uartstart+0x88>
{
    8000577e:	7139                	addi	sp,sp,-64
    80005780:	fc06                	sd	ra,56(sp)
    80005782:	f822                	sd	s0,48(sp)
    80005784:	f426                	sd	s1,40(sp)
    80005786:	f04a                	sd	s2,32(sp)
    80005788:	ec4e                	sd	s3,24(sp)
    8000578a:	e852                	sd	s4,16(sp)
    8000578c:	e456                	sd	s5,8(sp)
    8000578e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }

    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005790:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }

    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005794:	0001ca17          	auipc	s4,0x1c
    80005798:	804a0a13          	addi	s4,s4,-2044 # 80020f98 <uart_tx_lock>
    uart_tx_r += 1;
    8000579c:	00002497          	auipc	s1,0x2
    800057a0:	2f448493          	addi	s1,s1,756 # 80007a90 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800057a4:	00002997          	auipc	s3,0x2
    800057a8:	2f498993          	addi	s3,s3,756 # 80007a98 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800057ac:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    800057b0:	02077713          	andi	a4,a4,32
    800057b4:	c715                	beqz	a4,800057e0 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800057b6:	01f7f713          	andi	a4,a5,31
    800057ba:	9752                	add	a4,a4,s4
    800057bc:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    800057c0:	0785                	addi	a5,a5,1
    800057c2:	e09c                	sd	a5,0(s1)

    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800057c4:	8526                	mv	a0,s1
    800057c6:	f37fb0ef          	jal	ra,800016fc <wakeup>

    WriteReg(THR, c);
    800057ca:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800057ce:	609c                	ld	a5,0(s1)
    800057d0:	0009b703          	ld	a4,0(s3)
    800057d4:	fcf71ce3          	bne	a4,a5,800057ac <uartstart+0x42>
      ReadReg(ISR);
    800057d8:	100007b7          	lui	a5,0x10000
    800057dc:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    800057e0:	70e2                	ld	ra,56(sp)
    800057e2:	7442                	ld	s0,48(sp)
    800057e4:	74a2                	ld	s1,40(sp)
    800057e6:	7902                	ld	s2,32(sp)
    800057e8:	69e2                	ld	s3,24(sp)
    800057ea:	6a42                	ld	s4,16(sp)
    800057ec:	6aa2                	ld	s5,8(sp)
    800057ee:	6121                	addi	sp,sp,64
    800057f0:	8082                	ret
      ReadReg(ISR);
    800057f2:	100007b7          	lui	a5,0x10000
    800057f6:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    800057fa:	8082                	ret

00000000800057fc <uartputc>:
{
    800057fc:	7179                	addi	sp,sp,-48
    800057fe:	f406                	sd	ra,40(sp)
    80005800:	f022                	sd	s0,32(sp)
    80005802:	ec26                	sd	s1,24(sp)
    80005804:	e84a                	sd	s2,16(sp)
    80005806:	e44e                	sd	s3,8(sp)
    80005808:	e052                	sd	s4,0(sp)
    8000580a:	1800                	addi	s0,sp,48
    8000580c:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000580e:	0001b517          	auipc	a0,0x1b
    80005812:	78a50513          	addi	a0,a0,1930 # 80020f98 <uart_tx_lock>
    80005816:	16c000ef          	jal	ra,80005982 <acquire>
  if(panicked){
    8000581a:	00002797          	auipc	a5,0x2
    8000581e:	2727a783          	lw	a5,626(a5) # 80007a8c <panicked>
    80005822:	efbd                	bnez	a5,800058a0 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005824:	00002717          	auipc	a4,0x2
    80005828:	27473703          	ld	a4,628(a4) # 80007a98 <uart_tx_w>
    8000582c:	00002797          	auipc	a5,0x2
    80005830:	2647b783          	ld	a5,612(a5) # 80007a90 <uart_tx_r>
    80005834:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80005838:	0001b997          	auipc	s3,0x1b
    8000583c:	76098993          	addi	s3,s3,1888 # 80020f98 <uart_tx_lock>
    80005840:	00002497          	auipc	s1,0x2
    80005844:	25048493          	addi	s1,s1,592 # 80007a90 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005848:	00002917          	auipc	s2,0x2
    8000584c:	25090913          	addi	s2,s2,592 # 80007a98 <uart_tx_w>
    80005850:	00e79d63          	bne	a5,a4,8000586a <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80005854:	85ce                	mv	a1,s3
    80005856:	8526                	mv	a0,s1
    80005858:	e59fb0ef          	jal	ra,800016b0 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000585c:	00093703          	ld	a4,0(s2)
    80005860:	609c                	ld	a5,0(s1)
    80005862:	02078793          	addi	a5,a5,32
    80005866:	fee787e3          	beq	a5,a4,80005854 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000586a:	0001b497          	auipc	s1,0x1b
    8000586e:	72e48493          	addi	s1,s1,1838 # 80020f98 <uart_tx_lock>
    80005872:	01f77793          	andi	a5,a4,31
    80005876:	97a6                	add	a5,a5,s1
    80005878:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    8000587c:	0705                	addi	a4,a4,1
    8000587e:	00002797          	auipc	a5,0x2
    80005882:	20e7bd23          	sd	a4,538(a5) # 80007a98 <uart_tx_w>
  uartstart();
    80005886:	ee5ff0ef          	jal	ra,8000576a <uartstart>
  release(&uart_tx_lock);
    8000588a:	8526                	mv	a0,s1
    8000588c:	18e000ef          	jal	ra,80005a1a <release>
}
    80005890:	70a2                	ld	ra,40(sp)
    80005892:	7402                	ld	s0,32(sp)
    80005894:	64e2                	ld	s1,24(sp)
    80005896:	6942                	ld	s2,16(sp)
    80005898:	69a2                	ld	s3,8(sp)
    8000589a:	6a02                	ld	s4,0(sp)
    8000589c:	6145                	addi	sp,sp,48
    8000589e:	8082                	ret
    for(;;)
    800058a0:	a001                	j	800058a0 <uartputc+0xa4>

00000000800058a2 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800058a2:	1141                	addi	sp,sp,-16
    800058a4:	e422                	sd	s0,8(sp)
    800058a6:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800058a8:	100007b7          	lui	a5,0x10000
    800058ac:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800058b0:	8b85                	andi	a5,a5,1
    800058b2:	cb81                	beqz	a5,800058c2 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    800058b4:	100007b7          	lui	a5,0x10000
    800058b8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800058bc:	6422                	ld	s0,8(sp)
    800058be:	0141                	addi	sp,sp,16
    800058c0:	8082                	ret
    return -1;
    800058c2:	557d                	li	a0,-1
    800058c4:	bfe5                	j	800058bc <uartgetc+0x1a>

00000000800058c6 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800058c6:	1101                	addi	sp,sp,-32
    800058c8:	ec06                	sd	ra,24(sp)
    800058ca:	e822                	sd	s0,16(sp)
    800058cc:	e426                	sd	s1,8(sp)
    800058ce:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800058d0:	54fd                	li	s1,-1
    800058d2:	a019                	j	800058d8 <uartintr+0x12>
      break;
    consoleintr(c);
    800058d4:	8a3ff0ef          	jal	ra,80005176 <consoleintr>
    int c = uartgetc();
    800058d8:	fcbff0ef          	jal	ra,800058a2 <uartgetc>
    if(c == -1)
    800058dc:	fe951ce3          	bne	a0,s1,800058d4 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800058e0:	0001b497          	auipc	s1,0x1b
    800058e4:	6b848493          	addi	s1,s1,1720 # 80020f98 <uart_tx_lock>
    800058e8:	8526                	mv	a0,s1
    800058ea:	098000ef          	jal	ra,80005982 <acquire>
  uartstart();
    800058ee:	e7dff0ef          	jal	ra,8000576a <uartstart>
  release(&uart_tx_lock);
    800058f2:	8526                	mv	a0,s1
    800058f4:	126000ef          	jal	ra,80005a1a <release>
}
    800058f8:	60e2                	ld	ra,24(sp)
    800058fa:	6442                	ld	s0,16(sp)
    800058fc:	64a2                	ld	s1,8(sp)
    800058fe:	6105                	addi	sp,sp,32
    80005900:	8082                	ret

0000000080005902 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005902:	1141                	addi	sp,sp,-16
    80005904:	e422                	sd	s0,8(sp)
    80005906:	0800                	addi	s0,sp,16
  lk->name = name;
    80005908:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    8000590a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000590e:	00053823          	sd	zero,16(a0)
}
    80005912:	6422                	ld	s0,8(sp)
    80005914:	0141                	addi	sp,sp,16
    80005916:	8082                	ret

0000000080005918 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005918:	411c                	lw	a5,0(a0)
    8000591a:	e399                	bnez	a5,80005920 <holding+0x8>
    8000591c:	4501                	li	a0,0
  return r;
}
    8000591e:	8082                	ret
{
    80005920:	1101                	addi	sp,sp,-32
    80005922:	ec06                	sd	ra,24(sp)
    80005924:	e822                	sd	s0,16(sp)
    80005926:	e426                	sd	s1,8(sp)
    80005928:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    8000592a:	6904                	ld	s1,16(a0)
    8000592c:	f9cfb0ef          	jal	ra,800010c8 <mycpu>
    80005930:	40a48533          	sub	a0,s1,a0
    80005934:	00153513          	seqz	a0,a0
}
    80005938:	60e2                	ld	ra,24(sp)
    8000593a:	6442                	ld	s0,16(sp)
    8000593c:	64a2                	ld	s1,8(sp)
    8000593e:	6105                	addi	sp,sp,32
    80005940:	8082                	ret

0000000080005942 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80005942:	1101                	addi	sp,sp,-32
    80005944:	ec06                	sd	ra,24(sp)
    80005946:	e822                	sd	s0,16(sp)
    80005948:	e426                	sd	s1,8(sp)
    8000594a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000594c:	100024f3          	csrr	s1,sstatus
    80005950:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80005954:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005956:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    8000595a:	f6efb0ef          	jal	ra,800010c8 <mycpu>
    8000595e:	5d3c                	lw	a5,120(a0)
    80005960:	cb99                	beqz	a5,80005976 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80005962:	f66fb0ef          	jal	ra,800010c8 <mycpu>
    80005966:	5d3c                	lw	a5,120(a0)
    80005968:	2785                	addiw	a5,a5,1
    8000596a:	dd3c                	sw	a5,120(a0)
}
    8000596c:	60e2                	ld	ra,24(sp)
    8000596e:	6442                	ld	s0,16(sp)
    80005970:	64a2                	ld	s1,8(sp)
    80005972:	6105                	addi	sp,sp,32
    80005974:	8082                	ret
    mycpu()->intena = old;
    80005976:	f52fb0ef          	jal	ra,800010c8 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    8000597a:	8085                	srli	s1,s1,0x1
    8000597c:	8885                	andi	s1,s1,1
    8000597e:	dd64                	sw	s1,124(a0)
    80005980:	b7cd                	j	80005962 <push_off+0x20>

0000000080005982 <acquire>:
{
    80005982:	1101                	addi	sp,sp,-32
    80005984:	ec06                	sd	ra,24(sp)
    80005986:	e822                	sd	s0,16(sp)
    80005988:	e426                	sd	s1,8(sp)
    8000598a:	1000                	addi	s0,sp,32
    8000598c:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    8000598e:	fb5ff0ef          	jal	ra,80005942 <push_off>
  if(holding(lk))
    80005992:	8526                	mv	a0,s1
    80005994:	f85ff0ef          	jal	ra,80005918 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005998:	4705                	li	a4,1
  if(holding(lk))
    8000599a:	e105                	bnez	a0,800059ba <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    8000599c:	87ba                	mv	a5,a4
    8000599e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800059a2:	2781                	sext.w	a5,a5
    800059a4:	ffe5                	bnez	a5,8000599c <acquire+0x1a>
  __sync_synchronize();
    800059a6:	0ff0000f          	fence
  lk->cpu = mycpu();
    800059aa:	f1efb0ef          	jal	ra,800010c8 <mycpu>
    800059ae:	e888                	sd	a0,16(s1)
}
    800059b0:	60e2                	ld	ra,24(sp)
    800059b2:	6442                	ld	s0,16(sp)
    800059b4:	64a2                	ld	s1,8(sp)
    800059b6:	6105                	addi	sp,sp,32
    800059b8:	8082                	ret
    panic("acquire");
    800059ba:	00002517          	auipc	a0,0x2
    800059be:	01650513          	addi	a0,a0,22 # 800079d0 <digits+0x20>
    800059c2:	cb1ff0ef          	jal	ra,80005672 <panic>

00000000800059c6 <pop_off>:

void
pop_off(void)
{
    800059c6:	1141                	addi	sp,sp,-16
    800059c8:	e406                	sd	ra,8(sp)
    800059ca:	e022                	sd	s0,0(sp)
    800059cc:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800059ce:	efafb0ef          	jal	ra,800010c8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800059d2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800059d6:	8b89                	andi	a5,a5,2
  if(intr_get())
    800059d8:	e78d                	bnez	a5,80005a02 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    800059da:	5d3c                	lw	a5,120(a0)
    800059dc:	02f05963          	blez	a5,80005a0e <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    800059e0:	37fd                	addiw	a5,a5,-1
    800059e2:	0007871b          	sext.w	a4,a5
    800059e6:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    800059e8:	eb09                	bnez	a4,800059fa <pop_off+0x34>
    800059ea:	5d7c                	lw	a5,124(a0)
    800059ec:	c799                	beqz	a5,800059fa <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800059ee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800059f2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800059f6:	10079073          	csrw	sstatus,a5
    intr_on();
}
    800059fa:	60a2                	ld	ra,8(sp)
    800059fc:	6402                	ld	s0,0(sp)
    800059fe:	0141                	addi	sp,sp,16
    80005a00:	8082                	ret
    panic("pop_off - interruptible");
    80005a02:	00002517          	auipc	a0,0x2
    80005a06:	fd650513          	addi	a0,a0,-42 # 800079d8 <digits+0x28>
    80005a0a:	c69ff0ef          	jal	ra,80005672 <panic>
    panic("pop_off");
    80005a0e:	00002517          	auipc	a0,0x2
    80005a12:	fe250513          	addi	a0,a0,-30 # 800079f0 <digits+0x40>
    80005a16:	c5dff0ef          	jal	ra,80005672 <panic>

0000000080005a1a <release>:
{
    80005a1a:	1101                	addi	sp,sp,-32
    80005a1c:	ec06                	sd	ra,24(sp)
    80005a1e:	e822                	sd	s0,16(sp)
    80005a20:	e426                	sd	s1,8(sp)
    80005a22:	1000                	addi	s0,sp,32
    80005a24:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005a26:	ef3ff0ef          	jal	ra,80005918 <holding>
    80005a2a:	c105                	beqz	a0,80005a4a <release+0x30>
  lk->cpu = 0;
    80005a2c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005a30:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80005a34:	0f50000f          	fence	iorw,ow
    80005a38:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80005a3c:	f8bff0ef          	jal	ra,800059c6 <pop_off>
}
    80005a40:	60e2                	ld	ra,24(sp)
    80005a42:	6442                	ld	s0,16(sp)
    80005a44:	64a2                	ld	s1,8(sp)
    80005a46:	6105                	addi	sp,sp,32
    80005a48:	8082                	ret
    panic("release");
    80005a4a:	00002517          	auipc	a0,0x2
    80005a4e:	fae50513          	addi	a0,a0,-82 # 800079f8 <digits+0x48>
    80005a52:	c21ff0ef          	jal	ra,80005672 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
