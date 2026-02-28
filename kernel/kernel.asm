
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
    80000016:	016050ef          	jal	ra,8000502c <start>

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
    80000034:	17f050ef          	jal	ra,800059b2 <initlock>
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
    800000b4:	17f050ef          	jal	ra,80005a32 <acquire>
  r->next = kmem.freelist;
    800000b8:	2189b783          	ld	a5,536(s3)
    800000bc:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800000be:	2099bc23          	sd	s1,536(s3)
  release(&kmem.lock);
    800000c2:	854a                	mv	a0,s2
    800000c4:	207050ef          	jal	ra,80005aca <release>
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
    800000de:	644050ef          	jal	ra,80005722 <panic>

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
    80000142:	071050ef          	jal	ra,800059b2 <initlock>
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
    80000176:	0bd050ef          	jal	ra,80005a32 <acquire>
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
    80000196:	135050ef          	jal	ra,80005aca <release>

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
    800001b8:	113050ef          	jal	ra,80005aca <release>
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
    800001d2:	061050ef          	jal	ra,80005a32 <acquire>
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
    800001f8:	0d3050ef          	jal	ra,80005aca <release>
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
    80000216:	0b5050ef          	jal	ra,80005aca <release>
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
    80000256:	7dc050ef          	jal	ra,80005a32 <acquire>
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
    8000027e:	04d050ef          	jal	ra,80005aca <release>
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
    80000296:	48c050ef          	jal	ra,80005722 <panic>
    panic("superfree: pa outside of superpage pool range");
    8000029a:	00007517          	auipc	a0,0x7
    8000029e:	db650513          	addi	a0,a0,-586 # 80007050 <etext+0x50>
    800002a2:	480050ef          	jal	ra,80005722 <panic>
    panic("superfree: superpage pool overflow");
    800002a6:	00007517          	auipc	a0,0x7
    800002aa:	dda50513          	addi	a0,a0,-550 # 80007080 <etext+0x80>
    800002ae:	474050ef          	jal	ra,80005722 <panic>

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
    8000045c:	515000ef          	jal	ra,80001170 <cpuid>
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
    80000474:	4fd000ef          	jal	ra,80001170 <cpuid>
    80000478:	85aa                	mv	a1,a0
    8000047a:	00007517          	auipc	a0,0x7
    8000047e:	c4650513          	addi	a0,a0,-954 # 800070c0 <etext+0xc0>
    80000482:	7ed040ef          	jal	ra,8000546e <printf>
    kvminithart();    // turn on paging
    80000486:	080000ef          	jal	ra,80000506 <kvminithart>
    trapinithart();   // install kernel trap vector
    8000048a:	001010ef          	jal	ra,80001c8a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000048e:	5f6040ef          	jal	ra,80004a84 <plicinithart>
  }

  scheduler();
    80000492:	13c010ef          	jal	ra,800015ce <scheduler>
    consoleinit();
    80000496:	703040ef          	jal	ra,80005398 <consoleinit>
    printfinit();
    8000049a:	2c2050ef          	jal	ra,8000575c <printfinit>
    printf("\n");
    8000049e:	00007517          	auipc	a0,0x7
    800004a2:	c3250513          	addi	a0,a0,-974 # 800070d0 <etext+0xd0>
    800004a6:	7c9040ef          	jal	ra,8000546e <printf>
    printf("xv6 kernel is booting\n");
    800004aa:	00007517          	auipc	a0,0x7
    800004ae:	bfe50513          	addi	a0,a0,-1026 # 800070a8 <etext+0xa8>
    800004b2:	7bd040ef          	jal	ra,8000546e <printf>
    printf("\n");
    800004b6:	00007517          	auipc	a0,0x7
    800004ba:	c1a50513          	addi	a0,a0,-998 # 800070d0 <etext+0xd0>
    800004be:	7b1040ef          	jal	ra,8000546e <printf>
    kinit();         // physical page allocator
    800004c2:	c69ff0ef          	jal	ra,8000012a <kinit>
    kvminit();       // create kernel page table
    800004c6:	350000ef          	jal	ra,80000816 <kvminit>
    kvminithart();   // turn on paging
    800004ca:	03c000ef          	jal	ra,80000506 <kvminithart>
    procinit();      // process table
    800004ce:	3fb000ef          	jal	ra,800010c8 <procinit>
    trapinit();      // trap vectors
    800004d2:	794010ef          	jal	ra,80001c66 <trapinit>
    trapinithart();  // install kernel trap vector
    800004d6:	7b4010ef          	jal	ra,80001c8a <trapinithart>
    plicinit();      // set up interrupt controller
    800004da:	594040ef          	jal	ra,80004a6e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800004de:	5a6040ef          	jal	ra,80004a84 <plicinithart>
    binit();         // buffer cache
    800004e2:	627010ef          	jal	ra,80002308 <binit>
    iinit();         // inode table
    800004e6:	402020ef          	jal	ra,800028e8 <iinit>
    fileinit();      // file table
    800004ea:	1a4030ef          	jal	ra,8000368e <fileinit>
    virtio_disk_init(); // emulated hard disk
    800004ee:	686040ef          	jal	ra,80004b74 <virtio_disk_init>
    userinit();      // first user process
    800004f2:	713000ef          	jal	ra,80001404 <userinit>
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
    8000055c:	1c6050ef          	jal	ra,80005722 <panic>
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
    80000626:	0fc050ef          	jal	ra,80005722 <panic>
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
    800006f8:	02a050ef          	jal	ra,80005722 <panic>
    panic("mappages: size not aligned");
    800006fc:	00007517          	auipc	a0,0x7
    80000700:	a1450513          	addi	a0,a0,-1516 # 80007110 <etext+0x110>
    80000704:	01e050ef          	jal	ra,80005722 <panic>
    panic("mappages: size");
    80000708:	00007517          	auipc	a0,0x7
    8000070c:	a2850513          	addi	a0,a0,-1496 # 80007130 <etext+0x130>
    80000710:	012050ef          	jal	ra,80005722 <panic>
      panic("mappages: remap");
    80000714:	00007517          	auipc	a0,0x7
    80000718:	a2c50513          	addi	a0,a0,-1492 # 80007140 <etext+0x140>
    8000071c:	006050ef          	jal	ra,80005722 <panic>
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
    80000760:	7c3040ef          	jal	ra,80005722 <panic>

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
    80000804:	03b000ef          	jal	ra,8000103e <proc_mapstacks>
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
    8000087c:	6a7040ef          	jal	ra,80005722 <panic>
    panic("supermappages: remap");
    80000880:	00007517          	auipc	a0,0x7
    80000884:	8f850513          	addi	a0,a0,-1800 # 80007178 <etext+0x178>
    80000888:	69b040ef          	jal	ra,80005722 <panic>
    return -1;
    8000088c:	557d                	li	a0,-1
    8000088e:	bfe9                	j	80000868 <supermappages+0x36>

0000000080000890 <uvmunmap>:

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000890:	711d                	addi	sp,sp,-96
    80000892:	ec86                	sd	ra,88(sp)
    80000894:	e8a2                	sd	s0,80(sp)
    80000896:	e4a6                	sd	s1,72(sp)
    80000898:	e0ca                	sd	s2,64(sp)
    8000089a:	fc4e                	sd	s3,56(sp)
    8000089c:	f852                	sd	s4,48(sp)
    8000089e:	f456                	sd	s5,40(sp)
    800008a0:	f05a                	sd	s6,32(sp)
    800008a2:	ec5e                	sd	s7,24(sp)
    800008a4:	e862                	sd	s8,16(sp)
    800008a6:	e466                	sd	s9,8(sp)
    800008a8:	e06a                	sd	s10,0(sp)
    800008aa:	1080                	addi	s0,sp,96
  uint64 a;
  pte_t *pte;
  int sz;

  if ((va % PGSIZE) != 0)
    800008ac:	03459793          	slli	a5,a1,0x34
    800008b0:	e38d                	bnez	a5,800008d2 <uvmunmap+0x42>
    800008b2:	89aa                	mv	s3,a0
    800008b4:	84ae                	mv	s1,a1
    800008b6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += sz)
    800008b8:	0632                	slli	a2,a2,0xc
    800008ba:	00b60a33          	add	s4,a2,a1
    800008be:	0d45f063          	bgeu	a1,s4,8000097e <uvmunmap+0xee>
  {
    sz = PGSIZE;

    if (a % SUPERPGSIZE == 0) { //check for superpage address alignment
    800008c2:	00200d37          	lui	s10,0x200
    800008c6:	fffd0b13          	addi	s6,s10,-1 # 1fffff <_entry-0x7fe00001>
    if ((*pte & PTE_V) == 0)
    {
      printf("va=%ld pte=%ld\n", a, *pte);
      panic("uvmunmap: not mapped");
    }
    if (PTE_FLAGS(*pte) == PTE_V)
    800008ca:	4c05                	li	s8,1
    sz = PGSIZE;
    800008cc:	6b85                	lui	s7,0x1
      if (spte != 0 && (*spte & PTE_V) && (*spte & PTE_R)) { //superpte validity check
    800008ce:	4c8d                	li	s9,3
    800008d0:	a099                	j	80000916 <uvmunmap+0x86>
    panic("uvmunmap: not aligned");
    800008d2:	00007517          	auipc	a0,0x7
    800008d6:	8be50513          	addi	a0,a0,-1858 # 80007190 <etext+0x190>
    800008da:	649040ef          	jal	ra,80005722 <panic>
          uint64 spa = PTE2PA(*spte);
    800008de:	8129                	srli	a0,a0,0xa
          superfree((void *)spa);
    800008e0:	0532                	slli	a0,a0,0xc
    800008e2:	93dff0ef          	jal	ra,8000021e <superfree>
    800008e6:	a889                	j	80000938 <uvmunmap+0xa8>
    if ((pte = walk(pagetable, a, 0)) == 0)
    800008e8:	4601                	li	a2,0
    800008ea:	85a6                	mv	a1,s1
    800008ec:	854e                	mv	a0,s3
    800008ee:	c41ff0ef          	jal	ra,8000052e <walk>
    800008f2:	892a                	mv	s2,a0
    800008f4:	c531                	beqz	a0,80000940 <uvmunmap+0xb0>
    if ((*pte & PTE_V) == 0)
    800008f6:	6110                	ld	a2,0(a0)
    800008f8:	00167793          	andi	a5,a2,1
    800008fc:	cba1                	beqz	a5,8000094c <uvmunmap+0xbc>
    if (PTE_FLAGS(*pte) == PTE_V)
    800008fe:	3ff67793          	andi	a5,a2,1023
    80000902:	07878263          	beq	a5,s8,80000966 <uvmunmap+0xd6>
      panic("uvmunmap: not a leaf");
    if (do_free)
    80000906:	060a9663          	bnez	s5,80000972 <uvmunmap+0xe2>
    {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    8000090a:	00093023          	sd	zero,0(s2)
    sz = PGSIZE;
    8000090e:	87de                	mv	a5,s7
  for (a = va; a < va + npages * PGSIZE; a += sz)
    80000910:	94be                	add	s1,s1,a5
    80000912:	0744f663          	bgeu	s1,s4,8000097e <uvmunmap+0xee>
    if (a % SUPERPGSIZE == 0) { //check for superpage address alignment
    80000916:	0164f7b3          	and	a5,s1,s6
    8000091a:	f7f9                	bnez	a5,800008e8 <uvmunmap+0x58>
      pte_t *spte = superwalk(pagetable, a, 0);
    8000091c:	4601                	li	a2,0
    8000091e:	85a6                	mv	a1,s1
    80000920:	854e                	mv	a0,s3
    80000922:	cb1ff0ef          	jal	ra,800005d2 <superwalk>
    80000926:	892a                	mv	s2,a0
      if (spte != 0 && (*spte & PTE_V) && (*spte & PTE_R)) { //superpte validity check
    80000928:	d161                	beqz	a0,800008e8 <uvmunmap+0x58>
    8000092a:	6108                	ld	a0,0(a0)
    8000092c:	00357793          	andi	a5,a0,3
    80000930:	fb979ce3          	bne	a5,s9,800008e8 <uvmunmap+0x58>
        if (do_free) {
    80000934:	fa0a95e3          	bnez	s5,800008de <uvmunmap+0x4e>
        *spte = 0;
    80000938:	00093023          	sd	zero,0(s2)
        sz = SUPERPGSIZE;
    8000093c:	87ea                	mv	a5,s10
        continue; //skip regular page unmapping
    8000093e:	bfc9                	j	80000910 <uvmunmap+0x80>
      panic("uvmunmap: walk");
    80000940:	00007517          	auipc	a0,0x7
    80000944:	86850513          	addi	a0,a0,-1944 # 800071a8 <etext+0x1a8>
    80000948:	5db040ef          	jal	ra,80005722 <panic>
      printf("va=%ld pte=%ld\n", a, *pte);
    8000094c:	85a6                	mv	a1,s1
    8000094e:	00007517          	auipc	a0,0x7
    80000952:	86a50513          	addi	a0,a0,-1942 # 800071b8 <etext+0x1b8>
    80000956:	319040ef          	jal	ra,8000546e <printf>
      panic("uvmunmap: not mapped");
    8000095a:	00007517          	auipc	a0,0x7
    8000095e:	86e50513          	addi	a0,a0,-1938 # 800071c8 <etext+0x1c8>
    80000962:	5c1040ef          	jal	ra,80005722 <panic>
      panic("uvmunmap: not a leaf");
    80000966:	00007517          	auipc	a0,0x7
    8000096a:	87a50513          	addi	a0,a0,-1926 # 800071e0 <etext+0x1e0>
    8000096e:	5b5040ef          	jal	ra,80005722 <panic>
      uint64 pa = PTE2PA(*pte);
    80000972:	8229                	srli	a2,a2,0xa
      kfree((void *)pa);
    80000974:	00c61513          	slli	a0,a2,0xc
    80000978:	ef8ff0ef          	jal	ra,80000070 <kfree>
    8000097c:	b779                	j	8000090a <uvmunmap+0x7a>
  }
}
    8000097e:	60e6                	ld	ra,88(sp)
    80000980:	6446                	ld	s0,80(sp)
    80000982:	64a6                	ld	s1,72(sp)
    80000984:	6906                	ld	s2,64(sp)
    80000986:	79e2                	ld	s3,56(sp)
    80000988:	7a42                	ld	s4,48(sp)
    8000098a:	7aa2                	ld	s5,40(sp)
    8000098c:	7b02                	ld	s6,32(sp)
    8000098e:	6be2                	ld	s7,24(sp)
    80000990:	6c42                	ld	s8,16(sp)
    80000992:	6ca2                	ld	s9,8(sp)
    80000994:	6d02                	ld	s10,0(sp)
    80000996:	6125                	addi	sp,sp,96
    80000998:	8082                	ret

000000008000099a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    800009a4:	fc0ff0ef          	jal	ra,80000164 <kalloc>
    800009a8:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800009aa:	c509                	beqz	a0,800009b4 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800009ac:	6605                	lui	a2,0x1
    800009ae:	4581                	li	a1,0
    800009b0:	903ff0ef          	jal	ra,800002b2 <memset>
  return pagetable;
}
    800009b4:	8526                	mv	a0,s1
    800009b6:	60e2                	ld	ra,24(sp)
    800009b8:	6442                	ld	s0,16(sp)
    800009ba:	64a2                	ld	s1,8(sp)
    800009bc:	6105                	addi	sp,sp,32
    800009be:	8082                	ret

00000000800009c0 <uvmfirst>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800009c0:	7179                	addi	sp,sp,-48
    800009c2:	f406                	sd	ra,40(sp)
    800009c4:	f022                	sd	s0,32(sp)
    800009c6:	ec26                	sd	s1,24(sp)
    800009c8:	e84a                	sd	s2,16(sp)
    800009ca:	e44e                	sd	s3,8(sp)
    800009cc:	e052                	sd	s4,0(sp)
    800009ce:	1800                	addi	s0,sp,48
  char *mem;

  if (sz >= PGSIZE)
    800009d0:	6785                	lui	a5,0x1
    800009d2:	04f67063          	bgeu	a2,a5,80000a12 <uvmfirst+0x52>
    800009d6:	8a2a                	mv	s4,a0
    800009d8:	89ae                	mv	s3,a1
    800009da:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800009dc:	f88ff0ef          	jal	ra,80000164 <kalloc>
    800009e0:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800009e2:	6605                	lui	a2,0x1
    800009e4:	4581                	li	a1,0
    800009e6:	8cdff0ef          	jal	ra,800002b2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    800009ea:	4779                	li	a4,30
    800009ec:	86ca                	mv	a3,s2
    800009ee:	6605                	lui	a2,0x1
    800009f0:	4581                	li	a1,0
    800009f2:	8552                	mv	a0,s4
    800009f4:	c99ff0ef          	jal	ra,8000068c <mappages>
  memmove(mem, src, sz);
    800009f8:	8626                	mv	a2,s1
    800009fa:	85ce                	mv	a1,s3
    800009fc:	854a                	mv	a0,s2
    800009fe:	911ff0ef          	jal	ra,8000030e <memmove>
}
    80000a02:	70a2                	ld	ra,40(sp)
    80000a04:	7402                	ld	s0,32(sp)
    80000a06:	64e2                	ld	s1,24(sp)
    80000a08:	6942                	ld	s2,16(sp)
    80000a0a:	69a2                	ld	s3,8(sp)
    80000a0c:	6a02                	ld	s4,0(sp)
    80000a0e:	6145                	addi	sp,sp,48
    80000a10:	8082                	ret
    panic("uvmfirst: more than a page");
    80000a12:	00006517          	auipc	a0,0x6
    80000a16:	7e650513          	addi	a0,a0,2022 # 800071f8 <etext+0x1f8>
    80000a1a:	509040ef          	jal	ra,80005722 <panic>

0000000080000a1e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80000a1e:	1101                	addi	sp,sp,-32
    80000a20:	ec06                	sd	ra,24(sp)
    80000a22:	e822                	sd	s0,16(sp)
    80000a24:	e426                	sd	s1,8(sp)
    80000a26:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    80000a28:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80000a2a:	00b67d63          	bgeu	a2,a1,80000a44 <uvmdealloc+0x26>
    80000a2e:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    80000a30:	6785                	lui	a5,0x1
    80000a32:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000a34:	00f60733          	add	a4,a2,a5
    80000a38:	76fd                	lui	a3,0xfffff
    80000a3a:	8f75                	and	a4,a4,a3
    80000a3c:	97ae                	add	a5,a5,a1
    80000a3e:	8ff5                	and	a5,a5,a3
    80000a40:	00f76863          	bltu	a4,a5,80000a50 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80000a44:	8526                	mv	a0,s1
    80000a46:	60e2                	ld	ra,24(sp)
    80000a48:	6442                	ld	s0,16(sp)
    80000a4a:	64a2                	ld	s1,8(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80000a50:	8f99                	sub	a5,a5,a4
    80000a52:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80000a54:	4685                	li	a3,1
    80000a56:	0007861b          	sext.w	a2,a5
    80000a5a:	85ba                	mv	a1,a4
    80000a5c:	e35ff0ef          	jal	ra,80000890 <uvmunmap>
    80000a60:	b7d5                	j	80000a44 <uvmdealloc+0x26>

0000000080000a62 <uvmalloc>:
{
    80000a62:	711d                	addi	sp,sp,-96
    80000a64:	ec86                	sd	ra,88(sp)
    80000a66:	e8a2                	sd	s0,80(sp)
    80000a68:	e4a6                	sd	s1,72(sp)
    80000a6a:	e0ca                	sd	s2,64(sp)
    80000a6c:	fc4e                	sd	s3,56(sp)
    80000a6e:	f852                	sd	s4,48(sp)
    80000a70:	f456                	sd	s5,40(sp)
    80000a72:	f05a                	sd	s6,32(sp)
    80000a74:	ec5e                	sd	s7,24(sp)
    80000a76:	e862                	sd	s8,16(sp)
    80000a78:	e466                	sd	s9,8(sp)
    80000a7a:	e06a                	sd	s10,0(sp)
    80000a7c:	1080                	addi	s0,sp,96
    return oldsz;
    80000a7e:	892e                	mv	s2,a1
  if (newsz < oldsz)
    80000a80:	0cb66363          	bltu	a2,a1,80000b46 <uvmalloc+0xe4>
    80000a84:	8a2a                	mv	s4,a0
    80000a86:	89b2                	mv	s3,a2
  oldsz = PGROUNDUP(oldsz);
    80000a88:	6785                	lui	a5,0x1
    80000a8a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000a8c:	95be                	add	a1,a1,a5
    80000a8e:	7cfd                	lui	s9,0xfffff
    80000a90:	0195fcb3          	and	s9,a1,s9
  for (a = oldsz; a < newsz; a += sz)
    80000a94:	0cccf863          	bgeu	s9,a2,80000b64 <uvmalloc+0x102>
    80000a98:	84e6                	mv	s1,s9
    if (a % SUPERPGSIZE == 0 && newsz - a >= SUPERPGSIZE) { //superpage
    80000a9a:	00200ab7          	lui	s5,0x200
    80000a9e:	fffa8b13          	addi	s6,s5,-1 # 1fffff <_entry-0x7fe00001>
      if (mappages(pagetable, a, sz, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80000aa2:	0126eb93          	ori	s7,a3,18
      if (supermappages(pagetable, a, (uint64)mem, PTE_R | PTE_W | PTE_U | xperm) != 0) {
    80000aa6:	0166ec13          	ori	s8,a3,22
    80000aaa:	a0a1                	j	80000af2 <uvmalloc+0x90>
        uvmdealloc(pagetable, a, oldsz);
    80000aac:	8666                	mv	a2,s9
    80000aae:	85a6                	mv	a1,s1
    80000ab0:	8552                	mv	a0,s4
    80000ab2:	f6dff0ef          	jal	ra,80000a1e <uvmdealloc>
        return 0;
    80000ab6:	a841                	j	80000b46 <uvmalloc+0xe4>
        superfree(mem);
    80000ab8:	856a                	mv	a0,s10
    80000aba:	f64ff0ef          	jal	ra,8000021e <superfree>
        uvmdealloc(pagetable, a, oldsz);
    80000abe:	8666                	mv	a2,s9
    80000ac0:	85a6                	mv	a1,s1
    80000ac2:	8552                	mv	a0,s4
    80000ac4:	f5bff0ef          	jal	ra,80000a1e <uvmdealloc>
        return 0;
    80000ac8:	a8bd                	j	80000b46 <uvmalloc+0xe4>
      mem = kalloc();
    80000aca:	e9aff0ef          	jal	ra,80000164 <kalloc>
    80000ace:	892a                	mv	s2,a0
      if (mem == 0)
    80000ad0:	c931                	beqz	a0,80000b24 <uvmalloc+0xc2>
      memset(mem, 0, sz);
    80000ad2:	6605                	lui	a2,0x1
    80000ad4:	4581                	li	a1,0
    80000ad6:	fdcff0ef          	jal	ra,800002b2 <memset>
      if (mappages(pagetable, a, sz, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80000ada:	875e                	mv	a4,s7
    80000adc:	86ca                	mv	a3,s2
    80000ade:	6605                	lui	a2,0x1
    80000ae0:	85a6                	mv	a1,s1
    80000ae2:	8552                	mv	a0,s4
    80000ae4:	ba9ff0ef          	jal	ra,8000068c <mappages>
    80000ae8:	e521                	bnez	a0,80000b30 <uvmalloc+0xce>
      sz = PGSIZE;
    80000aea:	6785                	lui	a5,0x1
  for (a = oldsz; a < newsz; a += sz)
    80000aec:	94be                	add	s1,s1,a5
    80000aee:	0534fb63          	bgeu	s1,s3,80000b44 <uvmalloc+0xe2>
    if (a % SUPERPGSIZE == 0 && newsz - a >= SUPERPGSIZE) { //superpage
    80000af2:	0164f933          	and	s2,s1,s6
    80000af6:	fc091ae3          	bnez	s2,80000aca <uvmalloc+0x68>
    80000afa:	409987b3          	sub	a5,s3,s1
    80000afe:	fd57e6e3          	bltu	a5,s5,80000aca <uvmalloc+0x68>
      mem = superalloc();
    80000b02:	ebcff0ef          	jal	ra,800001be <superalloc>
    80000b06:	8d2a                	mv	s10,a0
      if (mem == 0) {
    80000b08:	d155                	beqz	a0,80000aac <uvmalloc+0x4a>
      memset(mem, 0, sz);
    80000b0a:	8656                	mv	a2,s5
    80000b0c:	4581                	li	a1,0
    80000b0e:	fa4ff0ef          	jal	ra,800002b2 <memset>
      if (supermappages(pagetable, a, (uint64)mem, PTE_R | PTE_W | PTE_U | xperm) != 0) {
    80000b12:	86e2                	mv	a3,s8
    80000b14:	866a                	mv	a2,s10
    80000b16:	85a6                	mv	a1,s1
    80000b18:	8552                	mv	a0,s4
    80000b1a:	d19ff0ef          	jal	ra,80000832 <supermappages>
    80000b1e:	fd49                	bnez	a0,80000ab8 <uvmalloc+0x56>
      sz = SUPERPGSIZE;
    80000b20:	87d6                	mv	a5,s5
    80000b22:	b7e9                	j	80000aec <uvmalloc+0x8a>
        uvmdealloc(pagetable, a, oldsz);
    80000b24:	8666                	mv	a2,s9
    80000b26:	85a6                	mv	a1,s1
    80000b28:	8552                	mv	a0,s4
    80000b2a:	ef5ff0ef          	jal	ra,80000a1e <uvmdealloc>
        return 0;
    80000b2e:	a821                	j	80000b46 <uvmalloc+0xe4>
        kfree(mem);
    80000b30:	854a                	mv	a0,s2
    80000b32:	d3eff0ef          	jal	ra,80000070 <kfree>
        uvmdealloc(pagetable, a, oldsz);
    80000b36:	8666                	mv	a2,s9
    80000b38:	85a6                	mv	a1,s1
    80000b3a:	8552                	mv	a0,s4
    80000b3c:	ee3ff0ef          	jal	ra,80000a1e <uvmdealloc>
        return 0;
    80000b40:	4901                	li	s2,0
    80000b42:	a011                	j	80000b46 <uvmalloc+0xe4>
  return newsz;
    80000b44:	894e                	mv	s2,s3
}
    80000b46:	854a                	mv	a0,s2
    80000b48:	60e6                	ld	ra,88(sp)
    80000b4a:	6446                	ld	s0,80(sp)
    80000b4c:	64a6                	ld	s1,72(sp)
    80000b4e:	6906                	ld	s2,64(sp)
    80000b50:	79e2                	ld	s3,56(sp)
    80000b52:	7a42                	ld	s4,48(sp)
    80000b54:	7aa2                	ld	s5,40(sp)
    80000b56:	7b02                	ld	s6,32(sp)
    80000b58:	6be2                	ld	s7,24(sp)
    80000b5a:	6c42                	ld	s8,16(sp)
    80000b5c:	6ca2                	ld	s9,8(sp)
    80000b5e:	6d02                	ld	s10,0(sp)
    80000b60:	6125                	addi	sp,sp,96
    80000b62:	8082                	ret
  return newsz;
    80000b64:	8932                	mv	s2,a2
    80000b66:	b7c5                	j	80000b46 <uvmalloc+0xe4>

0000000080000b68 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    80000b68:	7179                	addi	sp,sp,-48
    80000b6a:	f406                	sd	ra,40(sp)
    80000b6c:	f022                	sd	s0,32(sp)
    80000b6e:	ec26                	sd	s1,24(sp)
    80000b70:	e84a                	sd	s2,16(sp)
    80000b72:	e44e                	sd	s3,8(sp)
    80000b74:	e052                	sd	s4,0(sp)
    80000b76:	1800                	addi	s0,sp,48
    80000b78:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++)
    80000b7a:	84aa                	mv	s1,a0
    80000b7c:	6905                	lui	s2,0x1
    80000b7e:	992a                	add	s2,s2,a0
  {
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000b80:	4985                	li	s3,1
    80000b82:	a819                	j	80000b98 <freewalk+0x30>
    {
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000b84:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80000b86:	00c79513          	slli	a0,a5,0xc
    80000b8a:	fdfff0ef          	jal	ra,80000b68 <freewalk>
      pagetable[i] = 0;
    80000b8e:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++)
    80000b92:	04a1                	addi	s1,s1,8
    80000b94:	01248f63          	beq	s1,s2,80000bb2 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80000b98:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000b9a:	00f7f713          	andi	a4,a5,15
    80000b9e:	ff3703e3          	beq	a4,s3,80000b84 <freewalk+0x1c>
    }
    else if (pte & PTE_V)
    80000ba2:	8b85                	andi	a5,a5,1
    80000ba4:	d7fd                	beqz	a5,80000b92 <freewalk+0x2a>
    {
      panic("freewalk: leaf");
    80000ba6:	00006517          	auipc	a0,0x6
    80000baa:	67250513          	addi	a0,a0,1650 # 80007218 <etext+0x218>
    80000bae:	375040ef          	jal	ra,80005722 <panic>
    }
  }
  kfree((void *)pagetable);
    80000bb2:	8552                	mv	a0,s4
    80000bb4:	cbcff0ef          	jal	ra,80000070 <kfree>
}
    80000bb8:	70a2                	ld	ra,40(sp)
    80000bba:	7402                	ld	s0,32(sp)
    80000bbc:	64e2                	ld	s1,24(sp)
    80000bbe:	6942                	ld	s2,16(sp)
    80000bc0:	69a2                	ld	s3,8(sp)
    80000bc2:	6a02                	ld	s4,0(sp)
    80000bc4:	6145                	addi	sp,sp,48
    80000bc6:	8082                	ret

0000000080000bc8 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000bc8:	1101                	addi	sp,sp,-32
    80000bca:	ec06                	sd	ra,24(sp)
    80000bcc:	e822                	sd	s0,16(sp)
    80000bce:	e426                	sd	s1,8(sp)
    80000bd0:	1000                	addi	s0,sp,32
    80000bd2:	84aa                	mv	s1,a0
  if (sz > 0)
    80000bd4:	e989                	bnez	a1,80000be6 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80000bd6:	8526                	mv	a0,s1
    80000bd8:	f91ff0ef          	jal	ra,80000b68 <freewalk>
}
    80000bdc:	60e2                	ld	ra,24(sp)
    80000bde:	6442                	ld	s0,16(sp)
    80000be0:	64a2                	ld	s1,8(sp)
    80000be2:	6105                	addi	sp,sp,32
    80000be4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80000be6:	6785                	lui	a5,0x1
    80000be8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000bea:	95be                	add	a1,a1,a5
    80000bec:	4685                	li	a3,1
    80000bee:	00c5d613          	srli	a2,a1,0xc
    80000bf2:	4581                	li	a1,0
    80000bf4:	c9dff0ef          	jal	ra,80000890 <uvmunmap>
    80000bf8:	bff9                	j	80000bd6 <uvmfree+0xe>

0000000080000bfa <uvmcopy>:
  uint64 pa, i;
  uint flags;
  char *mem;
  int szinc;

  for (i = 0; i < sz; i += szinc)
    80000bfa:	10060c63          	beqz	a2,80000d12 <uvmcopy+0x118>
{
    80000bfe:	711d                	addi	sp,sp,-96
    80000c00:	ec86                	sd	ra,88(sp)
    80000c02:	e8a2                	sd	s0,80(sp)
    80000c04:	e4a6                	sd	s1,72(sp)
    80000c06:	e0ca                	sd	s2,64(sp)
    80000c08:	fc4e                	sd	s3,56(sp)
    80000c0a:	f852                	sd	s4,48(sp)
    80000c0c:	f456                	sd	s5,40(sp)
    80000c0e:	f05a                	sd	s6,32(sp)
    80000c10:	ec5e                	sd	s7,24(sp)
    80000c12:	e862                	sd	s8,16(sp)
    80000c14:	e466                	sd	s9,8(sp)
    80000c16:	e06a                	sd	s10,0(sp)
    80000c18:	1080                	addi	s0,sp,96
    80000c1a:	8aaa                	mv	s5,a0
    80000c1c:	8bae                	mv	s7,a1
    80000c1e:	8b32                	mv	s6,a2
  for (i = 0; i < sz; i += szinc)
    80000c20:	4481                	li	s1,0
  {
    szinc = PGSIZE;

    if (i % SUPERPGSIZE == 0) {
    80000c22:	00200d37          	lui	s10,0x200
    80000c26:	fffd0c13          	addi	s8,s10,-1 # 1fffff <_entry-0x7fe00001>
      pte_t *spte = superwalk(old, i, 0);
      if ((spte != 0) && (*spte & PTE_V) && (*spte & PTE_R)) {
    80000c2a:	4c8d                	li	s9,3
    80000c2c:	a881                	j	80000c7c <uvmcopy+0x82>
        if (mem == 0) {
          goto err;
        }
        memmove(mem, (char *)spa, SUPERPGSIZE);
        if (supermappages(new, i, (uint64)mem, flags) != 0) {
          superfree(mem);
    80000c2e:	854e                	mv	a0,s3
    80000c30:	deeff0ef          	jal	ra,8000021e <superfree>
          goto err;
    80000c34:	a07d                	j	80000ce2 <uvmcopy+0xe8>
        }
        continue;
      }
    }

    if ((pte = walk(old, i, 0)) == 0)
    80000c36:	4601                	li	a2,0
    80000c38:	85a6                	mv	a1,s1
    80000c3a:	8556                	mv	a0,s5
    80000c3c:	8f3ff0ef          	jal	ra,8000052e <walk>
    80000c40:	c151                	beqz	a0,80000cc4 <uvmcopy+0xca>
      panic("uvmcopy: pte should exist");
    if ((*pte & PTE_V) == 0)
    80000c42:	6118                	ld	a4,0(a0)
    80000c44:	00177793          	andi	a5,a4,1
    80000c48:	c7c1                	beqz	a5,80000cd0 <uvmcopy+0xd6>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000c4a:	00a75a13          	srli	s4,a4,0xa
    80000c4e:	0a32                	slli	s4,s4,0xc
    flags = PTE_FLAGS(*pte);
    80000c50:	3ff77913          	andi	s2,a4,1023
    if ((mem = kalloc()) == 0)
    80000c54:	d10ff0ef          	jal	ra,80000164 <kalloc>
    80000c58:	89aa                	mv	s3,a0
    80000c5a:	c541                	beqz	a0,80000ce2 <uvmcopy+0xe8>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    80000c5c:	6605                	lui	a2,0x1
    80000c5e:	85d2                	mv	a1,s4
    80000c60:	eaeff0ef          	jal	ra,8000030e <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80000c64:	874a                	mv	a4,s2
    80000c66:	86ce                	mv	a3,s3
    80000c68:	6605                	lui	a2,0x1
    80000c6a:	85a6                	mv	a1,s1
    80000c6c:	855e                	mv	a0,s7
    80000c6e:	a1fff0ef          	jal	ra,8000068c <mappages>
    80000c72:	e52d                	bnez	a0,80000cdc <uvmcopy+0xe2>
    szinc = PGSIZE;
    80000c74:	6785                	lui	a5,0x1
  for (i = 0; i < sz; i += szinc)
    80000c76:	94be                	add	s1,s1,a5
    80000c78:	0964fb63          	bgeu	s1,s6,80000d0e <uvmcopy+0x114>
    if (i % SUPERPGSIZE == 0) {
    80000c7c:	0184f7b3          	and	a5,s1,s8
    80000c80:	fbdd                	bnez	a5,80000c36 <uvmcopy+0x3c>
      pte_t *spte = superwalk(old, i, 0);
    80000c82:	4601                	li	a2,0
    80000c84:	85a6                	mv	a1,s1
    80000c86:	8556                	mv	a0,s5
    80000c88:	94bff0ef          	jal	ra,800005d2 <superwalk>
      if ((spte != 0) && (*spte & PTE_V) && (*spte & PTE_R)) {
    80000c8c:	d54d                	beqz	a0,80000c36 <uvmcopy+0x3c>
    80000c8e:	6114                	ld	a3,0(a0)
    80000c90:	0036f793          	andi	a5,a3,3
    80000c94:	fb9791e3          	bne	a5,s9,80000c36 <uvmcopy+0x3c>
        uint64 spa = PTE2PA(*spte);
    80000c98:	00a6da13          	srli	s4,a3,0xa
    80000c9c:	0a32                	slli	s4,s4,0xc
        uint64 flags = PTE_FLAGS(*spte);
    80000c9e:	3ff6f913          	andi	s2,a3,1023
        char *mem = superalloc();
    80000ca2:	d1cff0ef          	jal	ra,800001be <superalloc>
    80000ca6:	89aa                	mv	s3,a0
        if (mem == 0) {
    80000ca8:	cd0d                	beqz	a0,80000ce2 <uvmcopy+0xe8>
        memmove(mem, (char *)spa, SUPERPGSIZE);
    80000caa:	866a                	mv	a2,s10
    80000cac:	85d2                	mv	a1,s4
    80000cae:	e60ff0ef          	jal	ra,8000030e <memmove>
        if (supermappages(new, i, (uint64)mem, flags) != 0) {
    80000cb2:	86ca                	mv	a3,s2
    80000cb4:	864e                	mv	a2,s3
    80000cb6:	85a6                	mv	a1,s1
    80000cb8:	855e                	mv	a0,s7
    80000cba:	b79ff0ef          	jal	ra,80000832 <supermappages>
    80000cbe:	f925                	bnez	a0,80000c2e <uvmcopy+0x34>
        szinc = SUPERPGSIZE;
    80000cc0:	87ea                	mv	a5,s10
    80000cc2:	bf55                	j	80000c76 <uvmcopy+0x7c>
      panic("uvmcopy: pte should exist");
    80000cc4:	00006517          	auipc	a0,0x6
    80000cc8:	56450513          	addi	a0,a0,1380 # 80007228 <etext+0x228>
    80000ccc:	257040ef          	jal	ra,80005722 <panic>
      panic("uvmcopy: page not present");
    80000cd0:	00006517          	auipc	a0,0x6
    80000cd4:	57850513          	addi	a0,a0,1400 # 80007248 <etext+0x248>
    80000cd8:	24b040ef          	jal	ra,80005722 <panic>
    {
      kfree(mem);
    80000cdc:	854e                	mv	a0,s3
    80000cde:	b92ff0ef          	jal	ra,80000070 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000ce2:	4685                	li	a3,1
    80000ce4:	00c4d613          	srli	a2,s1,0xc
    80000ce8:	4581                	li	a1,0
    80000cea:	855e                	mv	a0,s7
    80000cec:	ba5ff0ef          	jal	ra,80000890 <uvmunmap>
  return -1;
    80000cf0:	557d                	li	a0,-1
}
    80000cf2:	60e6                	ld	ra,88(sp)
    80000cf4:	6446                	ld	s0,80(sp)
    80000cf6:	64a6                	ld	s1,72(sp)
    80000cf8:	6906                	ld	s2,64(sp)
    80000cfa:	79e2                	ld	s3,56(sp)
    80000cfc:	7a42                	ld	s4,48(sp)
    80000cfe:	7aa2                	ld	s5,40(sp)
    80000d00:	7b02                	ld	s6,32(sp)
    80000d02:	6be2                	ld	s7,24(sp)
    80000d04:	6c42                	ld	s8,16(sp)
    80000d06:	6ca2                	ld	s9,8(sp)
    80000d08:	6d02                	ld	s10,0(sp)
    80000d0a:	6125                	addi	sp,sp,96
    80000d0c:	8082                	ret
  return 0;
    80000d0e:	4501                	li	a0,0
    80000d10:	b7cd                	j	80000cf2 <uvmcopy+0xf8>
    80000d12:	4501                	li	a0,0
}
    80000d14:	8082                	ret

0000000080000d16 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    80000d16:	1141                	addi	sp,sp,-16
    80000d18:	e406                	sd	ra,8(sp)
    80000d1a:	e022                	sd	s0,0(sp)
    80000d1c:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80000d1e:	4601                	li	a2,0
    80000d20:	80fff0ef          	jal	ra,8000052e <walk>
  if (pte == 0)
    80000d24:	c901                	beqz	a0,80000d34 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000d26:	611c                	ld	a5,0(a0)
    80000d28:	9bbd                	andi	a5,a5,-17
    80000d2a:	e11c                	sd	a5,0(a0)
}
    80000d2c:	60a2                	ld	ra,8(sp)
    80000d2e:	6402                	ld	s0,0(sp)
    80000d30:	0141                	addi	sp,sp,16
    80000d32:	8082                	ret
    panic("uvmclear");
    80000d34:	00006517          	auipc	a0,0x6
    80000d38:	53450513          	addi	a0,a0,1332 # 80007268 <etext+0x268>
    80000d3c:	1e7040ef          	jal	ra,80005722 <panic>

0000000080000d40 <copyout>:
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while (len > 0)
    80000d40:	c6c1                	beqz	a3,80000dc8 <copyout+0x88>
{
    80000d42:	711d                	addi	sp,sp,-96
    80000d44:	ec86                	sd	ra,88(sp)
    80000d46:	e8a2                	sd	s0,80(sp)
    80000d48:	e4a6                	sd	s1,72(sp)
    80000d4a:	e0ca                	sd	s2,64(sp)
    80000d4c:	fc4e                	sd	s3,56(sp)
    80000d4e:	f852                	sd	s4,48(sp)
    80000d50:	f456                	sd	s5,40(sp)
    80000d52:	f05a                	sd	s6,32(sp)
    80000d54:	ec5e                	sd	s7,24(sp)
    80000d56:	e862                	sd	s8,16(sp)
    80000d58:	e466                	sd	s9,8(sp)
    80000d5a:	1080                	addi	s0,sp,96
    80000d5c:	8b2a                	mv	s6,a0
    80000d5e:	8a2e                	mv	s4,a1
    80000d60:	8ab2                	mv	s5,a2
    80000d62:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(dstva);
    80000d64:	74fd                	lui	s1,0xfffff
    80000d66:	8ced                	and	s1,s1,a1
    if (va0 >= MAXVA)
    80000d68:	57fd                	li	a5,-1
    80000d6a:	83e9                	srli	a5,a5,0x1a
    80000d6c:	0697e063          	bltu	a5,s1,80000dcc <copyout+0x8c>
    80000d70:	6c05                	lui	s8,0x1
    80000d72:	8bbe                	mv	s7,a5
    80000d74:	a015                	j	80000d98 <copyout+0x58>
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000d76:	409a04b3          	sub	s1,s4,s1
    80000d7a:	0009061b          	sext.w	a2,s2
    80000d7e:	85d6                	mv	a1,s5
    80000d80:	9526                	add	a0,a0,s1
    80000d82:	d8cff0ef          	jal	ra,8000030e <memmove>

    len -= n;
    80000d86:	412989b3          	sub	s3,s3,s2
    src += n;
    80000d8a:	9aca                	add	s5,s5,s2
  while (len > 0)
    80000d8c:	02098c63          	beqz	s3,80000dc4 <copyout+0x84>
    if (va0 >= MAXVA)
    80000d90:	059be063          	bltu	s7,s9,80000dd0 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    80000d94:	84e6                	mv	s1,s9
    dstva = va0 + PGSIZE;
    80000d96:	8a66                	mv	s4,s9
    if ((pte = walk(pagetable, va0, 0)) == 0)
    80000d98:	4601                	li	a2,0
    80000d9a:	85a6                	mv	a1,s1
    80000d9c:	855a                	mv	a0,s6
    80000d9e:	f90ff0ef          	jal	ra,8000052e <walk>
    80000da2:	c90d                	beqz	a0,80000dd4 <copyout+0x94>
    if ((*pte & PTE_W) == 0)
    80000da4:	611c                	ld	a5,0(a0)
    80000da6:	8b91                	andi	a5,a5,4
    80000da8:	c7a1                	beqz	a5,80000df0 <copyout+0xb0>
    pa0 = walkaddr(pagetable, va0);
    80000daa:	85a6                	mv	a1,s1
    80000dac:	855a                	mv	a0,s6
    80000dae:	8a1ff0ef          	jal	ra,8000064e <walkaddr>
    if (pa0 == 0)
    80000db2:	c129                	beqz	a0,80000df4 <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    80000db4:	01848cb3          	add	s9,s1,s8
    80000db8:	414c8933          	sub	s2,s9,s4
    80000dbc:	fb29fde3          	bgeu	s3,s2,80000d76 <copyout+0x36>
    80000dc0:	894e                	mv	s2,s3
    80000dc2:	bf55                	j	80000d76 <copyout+0x36>
  }
  return 0;
    80000dc4:	4501                	li	a0,0
    80000dc6:	a801                	j	80000dd6 <copyout+0x96>
    80000dc8:	4501                	li	a0,0
}
    80000dca:	8082                	ret
      return -1;
    80000dcc:	557d                	li	a0,-1
    80000dce:	a021                	j	80000dd6 <copyout+0x96>
    80000dd0:	557d                	li	a0,-1
    80000dd2:	a011                	j	80000dd6 <copyout+0x96>
      return -1;
    80000dd4:	557d                	li	a0,-1
}
    80000dd6:	60e6                	ld	ra,88(sp)
    80000dd8:	6446                	ld	s0,80(sp)
    80000dda:	64a6                	ld	s1,72(sp)
    80000ddc:	6906                	ld	s2,64(sp)
    80000dde:	79e2                	ld	s3,56(sp)
    80000de0:	7a42                	ld	s4,48(sp)
    80000de2:	7aa2                	ld	s5,40(sp)
    80000de4:	7b02                	ld	s6,32(sp)
    80000de6:	6be2                	ld	s7,24(sp)
    80000de8:	6c42                	ld	s8,16(sp)
    80000dea:	6ca2                	ld	s9,8(sp)
    80000dec:	6125                	addi	sp,sp,96
    80000dee:	8082                	ret
      return -1;
    80000df0:	557d                	li	a0,-1
    80000df2:	b7d5                	j	80000dd6 <copyout+0x96>
      return -1;
    80000df4:	557d                	li	a0,-1
    80000df6:	b7c5                	j	80000dd6 <copyout+0x96>

0000000080000df8 <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    80000df8:	c6a5                	beqz	a3,80000e60 <copyin+0x68>
{
    80000dfa:	715d                	addi	sp,sp,-80
    80000dfc:	e486                	sd	ra,72(sp)
    80000dfe:	e0a2                	sd	s0,64(sp)
    80000e00:	fc26                	sd	s1,56(sp)
    80000e02:	f84a                	sd	s2,48(sp)
    80000e04:	f44e                	sd	s3,40(sp)
    80000e06:	f052                	sd	s4,32(sp)
    80000e08:	ec56                	sd	s5,24(sp)
    80000e0a:	e85a                	sd	s6,16(sp)
    80000e0c:	e45e                	sd	s7,8(sp)
    80000e0e:	e062                	sd	s8,0(sp)
    80000e10:	0880                	addi	s0,sp,80
    80000e12:	8b2a                	mv	s6,a0
    80000e14:	8a2e                	mv	s4,a1
    80000e16:	8c32                	mv	s8,a2
    80000e18:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80000e1a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000e1c:	6a85                	lui	s5,0x1
    80000e1e:	a00d                	j	80000e40 <copyin+0x48>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000e20:	018505b3          	add	a1,a0,s8
    80000e24:	0004861b          	sext.w	a2,s1
    80000e28:	412585b3          	sub	a1,a1,s2
    80000e2c:	8552                	mv	a0,s4
    80000e2e:	ce0ff0ef          	jal	ra,8000030e <memmove>

    len -= n;
    80000e32:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000e36:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000e38:	01590c33          	add	s8,s2,s5
  while (len > 0)
    80000e3c:	02098063          	beqz	s3,80000e5c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80000e40:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000e44:	85ca                	mv	a1,s2
    80000e46:	855a                	mv	a0,s6
    80000e48:	807ff0ef          	jal	ra,8000064e <walkaddr>
    if (pa0 == 0)
    80000e4c:	cd01                	beqz	a0,80000e64 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80000e4e:	418904b3          	sub	s1,s2,s8
    80000e52:	94d6                	add	s1,s1,s5
    80000e54:	fc99f6e3          	bgeu	s3,s1,80000e20 <copyin+0x28>
    80000e58:	84ce                	mv	s1,s3
    80000e5a:	b7d9                	j	80000e20 <copyin+0x28>
  }
  return 0;
    80000e5c:	4501                	li	a0,0
    80000e5e:	a021                	j	80000e66 <copyin+0x6e>
    80000e60:	4501                	li	a0,0
}
    80000e62:	8082                	ret
      return -1;
    80000e64:	557d                	li	a0,-1
}
    80000e66:	60a6                	ld	ra,72(sp)
    80000e68:	6406                	ld	s0,64(sp)
    80000e6a:	74e2                	ld	s1,56(sp)
    80000e6c:	7942                	ld	s2,48(sp)
    80000e6e:	79a2                	ld	s3,40(sp)
    80000e70:	7a02                	ld	s4,32(sp)
    80000e72:	6ae2                	ld	s5,24(sp)
    80000e74:	6b42                	ld	s6,16(sp)
    80000e76:	6ba2                	ld	s7,8(sp)
    80000e78:	6c02                	ld	s8,0(sp)
    80000e7a:	6161                	addi	sp,sp,80
    80000e7c:	8082                	ret

0000000080000e7e <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    80000e7e:	c2cd                	beqz	a3,80000f20 <copyinstr+0xa2>
{
    80000e80:	715d                	addi	sp,sp,-80
    80000e82:	e486                	sd	ra,72(sp)
    80000e84:	e0a2                	sd	s0,64(sp)
    80000e86:	fc26                	sd	s1,56(sp)
    80000e88:	f84a                	sd	s2,48(sp)
    80000e8a:	f44e                	sd	s3,40(sp)
    80000e8c:	f052                	sd	s4,32(sp)
    80000e8e:	ec56                	sd	s5,24(sp)
    80000e90:	e85a                	sd	s6,16(sp)
    80000e92:	e45e                	sd	s7,8(sp)
    80000e94:	0880                	addi	s0,sp,80
    80000e96:	8a2a                	mv	s4,a0
    80000e98:	8b2e                	mv	s6,a1
    80000e9a:	8bb2                	mv	s7,a2
    80000e9c:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80000e9e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000ea0:	6985                	lui	s3,0x1
    80000ea2:	a02d                	j	80000ecc <copyinstr+0x4e>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    80000ea4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000ea8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    80000eaa:	37fd                	addiw	a5,a5,-1
    80000eac:	0007851b          	sext.w	a0,a5
  }
  else
  {
    return -1;
  }
}
    80000eb0:	60a6                	ld	ra,72(sp)
    80000eb2:	6406                	ld	s0,64(sp)
    80000eb4:	74e2                	ld	s1,56(sp)
    80000eb6:	7942                	ld	s2,48(sp)
    80000eb8:	79a2                	ld	s3,40(sp)
    80000eba:	7a02                	ld	s4,32(sp)
    80000ebc:	6ae2                	ld	s5,24(sp)
    80000ebe:	6b42                	ld	s6,16(sp)
    80000ec0:	6ba2                	ld	s7,8(sp)
    80000ec2:	6161                	addi	sp,sp,80
    80000ec4:	8082                	ret
    srcva = va0 + PGSIZE;
    80000ec6:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    80000eca:	c4b9                	beqz	s1,80000f18 <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    80000ecc:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000ed0:	85ca                	mv	a1,s2
    80000ed2:	8552                	mv	a0,s4
    80000ed4:	f7aff0ef          	jal	ra,8000064e <walkaddr>
    if (pa0 == 0)
    80000ed8:	c131                	beqz	a0,80000f1c <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    80000eda:	417906b3          	sub	a3,s2,s7
    80000ede:	96ce                	add	a3,a3,s3
    80000ee0:	00d4f363          	bgeu	s1,a3,80000ee6 <copyinstr+0x68>
    80000ee4:	86a6                	mv	a3,s1
    char *p = (char *)(pa0 + (srcva - va0));
    80000ee6:	955e                	add	a0,a0,s7
    80000ee8:	41250533          	sub	a0,a0,s2
    while (n > 0)
    80000eec:	dee9                	beqz	a3,80000ec6 <copyinstr+0x48>
    80000eee:	87da                	mv	a5,s6
      if (*p == '\0')
    80000ef0:	41650633          	sub	a2,a0,s6
    80000ef4:	fff48593          	addi	a1,s1,-1 # ffffffffffffefff <end+0xffffffff7ffde02f>
    80000ef8:	95da                	add	a1,a1,s6
    while (n > 0)
    80000efa:	96da                	add	a3,a3,s6
      if (*p == '\0')
    80000efc:	00f60733          	add	a4,a2,a5
    80000f00:	00074703          	lbu	a4,0(a4)
    80000f04:	d345                	beqz	a4,80000ea4 <copyinstr+0x26>
        *dst = *p;
    80000f06:	00e78023          	sb	a4,0(a5)
      --max;
    80000f0a:	40f584b3          	sub	s1,a1,a5
      dst++;
    80000f0e:	0785                	addi	a5,a5,1
    while (n > 0)
    80000f10:	fed796e3          	bne	a5,a3,80000efc <copyinstr+0x7e>
      dst++;
    80000f14:	8b3e                	mv	s6,a5
    80000f16:	bf45                	j	80000ec6 <copyinstr+0x48>
    80000f18:	4781                	li	a5,0
    80000f1a:	bf41                	j	80000eaa <copyinstr+0x2c>
      return -1;
    80000f1c:	557d                	li	a0,-1
    80000f1e:	bf49                	j	80000eb0 <copyinstr+0x32>
  int got_null = 0;
    80000f20:	4781                	li	a5,0
  if (got_null)
    80000f22:	37fd                	addiw	a5,a5,-1
    80000f24:	0007851b          	sext.w	a0,a5
}
    80000f28:	8082                	ret

0000000080000f2a <vmprint_recurse>:
  vmprint_recurse(pagetable, 0, 0); // start the recursion with depth 0
}
#endif

void vmprint_recurse(pagetable_t pagetable, int depth, uint64 va_recursive)
{ // seperate function so we can keep track of depth using a parameter
    80000f2a:	7119                	addi	sp,sp,-128
    80000f2c:	fc86                	sd	ra,120(sp)
    80000f2e:	f8a2                	sd	s0,112(sp)
    80000f30:	f4a6                	sd	s1,104(sp)
    80000f32:	f0ca                	sd	s2,96(sp)
    80000f34:	ecce                	sd	s3,88(sp)
    80000f36:	e8d2                	sd	s4,80(sp)
    80000f38:	e4d6                	sd	s5,72(sp)
    80000f3a:	e0da                	sd	s6,64(sp)
    80000f3c:	fc5e                	sd	s7,56(sp)
    80000f3e:	f862                	sd	s8,48(sp)
    80000f40:	f466                	sd	s9,40(sp)
    80000f42:	f06a                	sd	s10,32(sp)
    80000f44:	ec6e                	sd	s11,24(sp)
    80000f46:	0100                	addi	s0,sp,128
    80000f48:	8aae                	mv	s5,a1
    80000f4a:	8d32                	mv	s10,a2
    { // skip the pte if it's not valid per lab spec
      continue;
    }

    // reconstruct va using i, px shift, and the previous va
    uint64 va = va_recursive | ((uint64)i << PXSHIFT(2 - depth));
    80000f4c:	4789                	li	a5,2
    80000f4e:	9f8d                	subw	a5,a5,a1
    80000f50:	00379c9b          	slliw	s9,a5,0x3
    80000f54:	00fc8cbb          	addw	s9,s9,a5
    80000f58:	2cb1                	addiw	s9,s9,12 # fffffffffffff00c <end+0xffffffff7ffde03c>
    80000f5a:	8a2a                	mv	s4,a0
    80000f5c:	4981                	li	s3,0
      printf(".. ");
    }
    printf("..%p: pte %p pa %p\n", (void *)va, (void *)pte, (void *)PTE2PA(pte));

    // recursive block
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000f5e:	4d85                	li	s11,1
    {
      uint64 child_pa = PTE2PA(pte); // get child pa to convert to a pagetable
      vmprint_recurse((pagetable_t)child_pa, depth + 1, va);
    80000f60:	0015879b          	addiw	a5,a1,1
    80000f64:	f8f43423          	sd	a5,-120(s0)
      printf(".. ");
    80000f68:	00006b17          	auipc	s6,0x6
    80000f6c:	318b0b13          	addi	s6,s6,792 # 80007280 <etext+0x280>
  for (int i = 0; i < 512; i++)
    80000f70:	20000c13          	li	s8,512
    80000f74:	a029                	j	80000f7e <vmprint_recurse+0x54>
    80000f76:	0985                	addi	s3,s3,1 # 1001 <_entry-0x7fffefff>
    80000f78:	0a21                	addi	s4,s4,8
    80000f7a:	07898163          	beq	s3,s8,80000fdc <vmprint_recurse+0xb2>
    pte_t pte = pagetable[i]; // store pte from page table
    80000f7e:	000a3903          	ld	s2,0(s4)
    if (!(pte & PTE_V))
    80000f82:	00197793          	andi	a5,s2,1
    80000f86:	dbe5                	beqz	a5,80000f76 <vmprint_recurse+0x4c>
    uint64 va = va_recursive | ((uint64)i << PXSHIFT(2 - depth));
    80000f88:	01999bb3          	sll	s7,s3,s9
    80000f8c:	01abebb3          	or	s7,s7,s10
    printf(" ");
    80000f90:	00006517          	auipc	a0,0x6
    80000f94:	2e850513          	addi	a0,a0,744 # 80007278 <etext+0x278>
    80000f98:	4d6040ef          	jal	ra,8000546e <printf>
    for (int j = 0; j < depth; j++)
    80000f9c:	01505963          	blez	s5,80000fae <vmprint_recurse+0x84>
    80000fa0:	4481                	li	s1,0
      printf(".. ");
    80000fa2:	855a                	mv	a0,s6
    80000fa4:	4ca040ef          	jal	ra,8000546e <printf>
    for (int j = 0; j < depth; j++)
    80000fa8:	2485                	addiw	s1,s1,1
    80000faa:	fe9a9ce3          	bne	s5,s1,80000fa2 <vmprint_recurse+0x78>
    printf("..%p: pte %p pa %p\n", (void *)va, (void *)pte, (void *)PTE2PA(pte));
    80000fae:	00a95493          	srli	s1,s2,0xa
    80000fb2:	04b2                	slli	s1,s1,0xc
    80000fb4:	86a6                	mv	a3,s1
    80000fb6:	864a                	mv	a2,s2
    80000fb8:	85de                	mv	a1,s7
    80000fba:	00006517          	auipc	a0,0x6
    80000fbe:	2ce50513          	addi	a0,a0,718 # 80007288 <etext+0x288>
    80000fc2:	4ac040ef          	jal	ra,8000546e <printf>
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000fc6:	00f97913          	andi	s2,s2,15
    80000fca:	fbb916e3          	bne	s2,s11,80000f76 <vmprint_recurse+0x4c>
      vmprint_recurse((pagetable_t)child_pa, depth + 1, va);
    80000fce:	865e                	mv	a2,s7
    80000fd0:	f8843583          	ld	a1,-120(s0)
    80000fd4:	8526                	mv	a0,s1
    80000fd6:	f55ff0ef          	jal	ra,80000f2a <vmprint_recurse>
    80000fda:	bf71                	j	80000f76 <vmprint_recurse+0x4c>
    }
  }
}
    80000fdc:	70e6                	ld	ra,120(sp)
    80000fde:	7446                	ld	s0,112(sp)
    80000fe0:	74a6                	ld	s1,104(sp)
    80000fe2:	7906                	ld	s2,96(sp)
    80000fe4:	69e6                	ld	s3,88(sp)
    80000fe6:	6a46                	ld	s4,80(sp)
    80000fe8:	6aa6                	ld	s5,72(sp)
    80000fea:	6b06                	ld	s6,64(sp)
    80000fec:	7be2                	ld	s7,56(sp)
    80000fee:	7c42                	ld	s8,48(sp)
    80000ff0:	7ca2                	ld	s9,40(sp)
    80000ff2:	7d02                	ld	s10,32(sp)
    80000ff4:	6de2                	ld	s11,24(sp)
    80000ff6:	6109                	addi	sp,sp,128
    80000ff8:	8082                	ret

0000000080000ffa <vmprint>:
{
    80000ffa:	1101                	addi	sp,sp,-32
    80000ffc:	ec06                	sd	ra,24(sp)
    80000ffe:	e822                	sd	s0,16(sp)
    80001000:	e426                	sd	s1,8(sp)
    80001002:	1000                	addi	s0,sp,32
    80001004:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    80001006:	85aa                	mv	a1,a0
    80001008:	00006517          	auipc	a0,0x6
    8000100c:	29850513          	addi	a0,a0,664 # 800072a0 <etext+0x2a0>
    80001010:	45e040ef          	jal	ra,8000546e <printf>
  vmprint_recurse(pagetable, 0, 0); // start the recursion with depth 0
    80001014:	4601                	li	a2,0
    80001016:	4581                	li	a1,0
    80001018:	8526                	mv	a0,s1
    8000101a:	f11ff0ef          	jal	ra,80000f2a <vmprint_recurse>
}
    8000101e:	60e2                	ld	ra,24(sp)
    80001020:	6442                	ld	s0,16(sp)
    80001022:	64a2                	ld	s1,8(sp)
    80001024:	6105                	addi	sp,sp,32
    80001026:	8082                	ret

0000000080001028 <pgpte>:

#ifdef LAB_PGTBL
pte_t *
pgpte(pagetable_t pagetable, uint64 va)
{
    80001028:	1141                	addi	sp,sp,-16
    8000102a:	e406                	sd	ra,8(sp)
    8000102c:	e022                	sd	s0,0(sp)
    8000102e:	0800                	addi	s0,sp,16
  return walk(pagetable, va, 0);
    80001030:	4601                	li	a2,0
    80001032:	cfcff0ef          	jal	ra,8000052e <walk>
}
    80001036:	60a2                	ld	ra,8(sp)
    80001038:	6402                	ld	s0,0(sp)
    8000103a:	0141                	addi	sp,sp,16
    8000103c:	8082                	ret

000000008000103e <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000103e:	7139                	addi	sp,sp,-64
    80001040:	fc06                	sd	ra,56(sp)
    80001042:	f822                	sd	s0,48(sp)
    80001044:	f426                	sd	s1,40(sp)
    80001046:	f04a                	sd	s2,32(sp)
    80001048:	ec4e                	sd	s3,24(sp)
    8000104a:	e852                	sd	s4,16(sp)
    8000104c:	e456                	sd	s5,8(sp)
    8000104e:	e05a                	sd	s6,0(sp)
    80001050:	0080                	addi	s0,sp,64
    80001052:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001054:	00007497          	auipc	s1,0x7
    80001058:	09c48493          	addi	s1,s1,156 # 800080f0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000105c:	8b26                	mv	s6,s1
    8000105e:	00006a97          	auipc	s5,0x6
    80001062:	fa2a8a93          	addi	s5,s5,-94 # 80007000 <etext>
    80001066:	04000937          	lui	s2,0x4000
    8000106a:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000106c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000106e:	0000da17          	auipc	s4,0xd
    80001072:	a82a0a13          	addi	s4,s4,-1406 # 8000daf0 <tickslock>
    char *pa = kalloc();
    80001076:	8eeff0ef          	jal	ra,80000164 <kalloc>
    8000107a:	862a                	mv	a2,a0
    if(pa == 0)
    8000107c:	c121                	beqz	a0,800010bc <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    8000107e:	416485b3          	sub	a1,s1,s6
    80001082:	858d                	srai	a1,a1,0x3
    80001084:	000ab783          	ld	a5,0(s5)
    80001088:	02f585b3          	mul	a1,a1,a5
    8000108c:	2585                	addiw	a1,a1,1
    8000108e:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001092:	4719                	li	a4,6
    80001094:	6685                	lui	a3,0x1
    80001096:	40b905b3          	sub	a1,s2,a1
    8000109a:	854e                	mv	a0,s3
    8000109c:	ea0ff0ef          	jal	ra,8000073c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800010a0:	16848493          	addi	s1,s1,360
    800010a4:	fd4499e3          	bne	s1,s4,80001076 <proc_mapstacks+0x38>
  }
}
    800010a8:	70e2                	ld	ra,56(sp)
    800010aa:	7442                	ld	s0,48(sp)
    800010ac:	74a2                	ld	s1,40(sp)
    800010ae:	7902                	ld	s2,32(sp)
    800010b0:	69e2                	ld	s3,24(sp)
    800010b2:	6a42                	ld	s4,16(sp)
    800010b4:	6aa2                	ld	s5,8(sp)
    800010b6:	6b02                	ld	s6,0(sp)
    800010b8:	6121                	addi	sp,sp,64
    800010ba:	8082                	ret
      panic("kalloc");
    800010bc:	00006517          	auipc	a0,0x6
    800010c0:	1f450513          	addi	a0,a0,500 # 800072b0 <etext+0x2b0>
    800010c4:	65e040ef          	jal	ra,80005722 <panic>

00000000800010c8 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800010c8:	7139                	addi	sp,sp,-64
    800010ca:	fc06                	sd	ra,56(sp)
    800010cc:	f822                	sd	s0,48(sp)
    800010ce:	f426                	sd	s1,40(sp)
    800010d0:	f04a                	sd	s2,32(sp)
    800010d2:	ec4e                	sd	s3,24(sp)
    800010d4:	e852                	sd	s4,16(sp)
    800010d6:	e456                	sd	s5,8(sp)
    800010d8:	e05a                	sd	s6,0(sp)
    800010da:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800010dc:	00006597          	auipc	a1,0x6
    800010e0:	1dc58593          	addi	a1,a1,476 # 800072b8 <etext+0x2b8>
    800010e4:	00007517          	auipc	a0,0x7
    800010e8:	bdc50513          	addi	a0,a0,-1060 # 80007cc0 <pid_lock>
    800010ec:	0c7040ef          	jal	ra,800059b2 <initlock>
  initlock(&wait_lock, "wait_lock");
    800010f0:	00006597          	auipc	a1,0x6
    800010f4:	1d058593          	addi	a1,a1,464 # 800072c0 <etext+0x2c0>
    800010f8:	00007517          	auipc	a0,0x7
    800010fc:	be050513          	addi	a0,a0,-1056 # 80007cd8 <wait_lock>
    80001100:	0b3040ef          	jal	ra,800059b2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001104:	00007497          	auipc	s1,0x7
    80001108:	fec48493          	addi	s1,s1,-20 # 800080f0 <proc>
      initlock(&p->lock, "proc");
    8000110c:	00006b17          	auipc	s6,0x6
    80001110:	1c4b0b13          	addi	s6,s6,452 # 800072d0 <etext+0x2d0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001114:	8aa6                	mv	s5,s1
    80001116:	00006a17          	auipc	s4,0x6
    8000111a:	eeaa0a13          	addi	s4,s4,-278 # 80007000 <etext>
    8000111e:	04000937          	lui	s2,0x4000
    80001122:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001124:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001126:	0000d997          	auipc	s3,0xd
    8000112a:	9ca98993          	addi	s3,s3,-1590 # 8000daf0 <tickslock>
      initlock(&p->lock, "proc");
    8000112e:	85da                	mv	a1,s6
    80001130:	8526                	mv	a0,s1
    80001132:	081040ef          	jal	ra,800059b2 <initlock>
      p->state = UNUSED;
    80001136:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000113a:	415487b3          	sub	a5,s1,s5
    8000113e:	878d                	srai	a5,a5,0x3
    80001140:	000a3703          	ld	a4,0(s4)
    80001144:	02e787b3          	mul	a5,a5,a4
    80001148:	2785                	addiw	a5,a5,1
    8000114a:	00d7979b          	slliw	a5,a5,0xd
    8000114e:	40f907b3          	sub	a5,s2,a5
    80001152:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001154:	16848493          	addi	s1,s1,360
    80001158:	fd349be3          	bne	s1,s3,8000112e <procinit+0x66>
  }
}
    8000115c:	70e2                	ld	ra,56(sp)
    8000115e:	7442                	ld	s0,48(sp)
    80001160:	74a2                	ld	s1,40(sp)
    80001162:	7902                	ld	s2,32(sp)
    80001164:	69e2                	ld	s3,24(sp)
    80001166:	6a42                	ld	s4,16(sp)
    80001168:	6aa2                	ld	s5,8(sp)
    8000116a:	6b02                	ld	s6,0(sp)
    8000116c:	6121                	addi	sp,sp,64
    8000116e:	8082                	ret

0000000080001170 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001170:	1141                	addi	sp,sp,-16
    80001172:	e422                	sd	s0,8(sp)
    80001174:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001176:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001178:	2501                	sext.w	a0,a0
    8000117a:	6422                	ld	s0,8(sp)
    8000117c:	0141                	addi	sp,sp,16
    8000117e:	8082                	ret

0000000080001180 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001180:	1141                	addi	sp,sp,-16
    80001182:	e422                	sd	s0,8(sp)
    80001184:	0800                	addi	s0,sp,16
    80001186:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001188:	2781                	sext.w	a5,a5
    8000118a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000118c:	00007517          	auipc	a0,0x7
    80001190:	b6450513          	addi	a0,a0,-1180 # 80007cf0 <cpus>
    80001194:	953e                	add	a0,a0,a5
    80001196:	6422                	ld	s0,8(sp)
    80001198:	0141                	addi	sp,sp,16
    8000119a:	8082                	ret

000000008000119c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    8000119c:	1101                	addi	sp,sp,-32
    8000119e:	ec06                	sd	ra,24(sp)
    800011a0:	e822                	sd	s0,16(sp)
    800011a2:	e426                	sd	s1,8(sp)
    800011a4:	1000                	addi	s0,sp,32
  push_off();
    800011a6:	04d040ef          	jal	ra,800059f2 <push_off>
    800011aa:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800011ac:	2781                	sext.w	a5,a5
    800011ae:	079e                	slli	a5,a5,0x7
    800011b0:	00007717          	auipc	a4,0x7
    800011b4:	b1070713          	addi	a4,a4,-1264 # 80007cc0 <pid_lock>
    800011b8:	97ba                	add	a5,a5,a4
    800011ba:	7b84                	ld	s1,48(a5)
  pop_off();
    800011bc:	0bb040ef          	jal	ra,80005a76 <pop_off>
  return p;
}
    800011c0:	8526                	mv	a0,s1
    800011c2:	60e2                	ld	ra,24(sp)
    800011c4:	6442                	ld	s0,16(sp)
    800011c6:	64a2                	ld	s1,8(sp)
    800011c8:	6105                	addi	sp,sp,32
    800011ca:	8082                	ret

00000000800011cc <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800011cc:	1141                	addi	sp,sp,-16
    800011ce:	e406                	sd	ra,8(sp)
    800011d0:	e022                	sd	s0,0(sp)
    800011d2:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800011d4:	fc9ff0ef          	jal	ra,8000119c <myproc>
    800011d8:	0f3040ef          	jal	ra,80005aca <release>

  if (first) {
    800011dc:	00007797          	auipc	a5,0x7
    800011e0:	8247a783          	lw	a5,-2012(a5) # 80007a00 <first.1>
    800011e4:	e799                	bnez	a5,800011f2 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    800011e6:	2bd000ef          	jal	ra,80001ca2 <usertrapret>
}
    800011ea:	60a2                	ld	ra,8(sp)
    800011ec:	6402                	ld	s0,0(sp)
    800011ee:	0141                	addi	sp,sp,16
    800011f0:	8082                	ret
    fsinit(ROOTDEV);
    800011f2:	4505                	li	a0,1
    800011f4:	688010ef          	jal	ra,8000287c <fsinit>
    first = 0;
    800011f8:	00007797          	auipc	a5,0x7
    800011fc:	8007a423          	sw	zero,-2040(a5) # 80007a00 <first.1>
    __sync_synchronize();
    80001200:	0ff0000f          	fence
    80001204:	b7cd                	j	800011e6 <forkret+0x1a>

0000000080001206 <allocpid>:
{
    80001206:	1101                	addi	sp,sp,-32
    80001208:	ec06                	sd	ra,24(sp)
    8000120a:	e822                	sd	s0,16(sp)
    8000120c:	e426                	sd	s1,8(sp)
    8000120e:	e04a                	sd	s2,0(sp)
    80001210:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001212:	00007917          	auipc	s2,0x7
    80001216:	aae90913          	addi	s2,s2,-1362 # 80007cc0 <pid_lock>
    8000121a:	854a                	mv	a0,s2
    8000121c:	017040ef          	jal	ra,80005a32 <acquire>
  pid = nextpid;
    80001220:	00006797          	auipc	a5,0x6
    80001224:	7e478793          	addi	a5,a5,2020 # 80007a04 <nextpid>
    80001228:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000122a:	0014871b          	addiw	a4,s1,1
    8000122e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001230:	854a                	mv	a0,s2
    80001232:	099040ef          	jal	ra,80005aca <release>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <proc_pagetable>:
{
    80001244:	1101                	addi	sp,sp,-32
    80001246:	ec06                	sd	ra,24(sp)
    80001248:	e822                	sd	s0,16(sp)
    8000124a:	e426                	sd	s1,8(sp)
    8000124c:	e04a                	sd	s2,0(sp)
    8000124e:	1000                	addi	s0,sp,32
    80001250:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001252:	f48ff0ef          	jal	ra,8000099a <uvmcreate>
    80001256:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001258:	cd05                	beqz	a0,80001290 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000125a:	4729                	li	a4,10
    8000125c:	00005697          	auipc	a3,0x5
    80001260:	da468693          	addi	a3,a3,-604 # 80006000 <_trampoline>
    80001264:	6605                	lui	a2,0x1
    80001266:	040005b7          	lui	a1,0x4000
    8000126a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000126c:	05b2                	slli	a1,a1,0xc
    8000126e:	c1eff0ef          	jal	ra,8000068c <mappages>
    80001272:	02054663          	bltz	a0,8000129e <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001276:	4719                	li	a4,6
    80001278:	05893683          	ld	a3,88(s2)
    8000127c:	6605                	lui	a2,0x1
    8000127e:	020005b7          	lui	a1,0x2000
    80001282:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001284:	05b6                	slli	a1,a1,0xd
    80001286:	8526                	mv	a0,s1
    80001288:	c04ff0ef          	jal	ra,8000068c <mappages>
    8000128c:	00054f63          	bltz	a0,800012aa <proc_pagetable+0x66>
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6902                	ld	s2,0(sp)
    8000129a:	6105                	addi	sp,sp,32
    8000129c:	8082                	ret
    uvmfree(pagetable, 0);
    8000129e:	4581                	li	a1,0
    800012a0:	8526                	mv	a0,s1
    800012a2:	927ff0ef          	jal	ra,80000bc8 <uvmfree>
    return 0;
    800012a6:	4481                	li	s1,0
    800012a8:	b7e5                	j	80001290 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800012aa:	4681                	li	a3,0
    800012ac:	4605                	li	a2,1
    800012ae:	040005b7          	lui	a1,0x4000
    800012b2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800012b4:	05b2                	slli	a1,a1,0xc
    800012b6:	8526                	mv	a0,s1
    800012b8:	dd8ff0ef          	jal	ra,80000890 <uvmunmap>
    uvmfree(pagetable, 0);
    800012bc:	4581                	li	a1,0
    800012be:	8526                	mv	a0,s1
    800012c0:	909ff0ef          	jal	ra,80000bc8 <uvmfree>
    return 0;
    800012c4:	4481                	li	s1,0
    800012c6:	b7e9                	j	80001290 <proc_pagetable+0x4c>

00000000800012c8 <proc_freepagetable>:
{
    800012c8:	1101                	addi	sp,sp,-32
    800012ca:	ec06                	sd	ra,24(sp)
    800012cc:	e822                	sd	s0,16(sp)
    800012ce:	e426                	sd	s1,8(sp)
    800012d0:	e04a                	sd	s2,0(sp)
    800012d2:	1000                	addi	s0,sp,32
    800012d4:	84aa                	mv	s1,a0
    800012d6:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800012d8:	4681                	li	a3,0
    800012da:	4605                	li	a2,1
    800012dc:	040005b7          	lui	a1,0x4000
    800012e0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800012e2:	05b2                	slli	a1,a1,0xc
    800012e4:	dacff0ef          	jal	ra,80000890 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800012e8:	4681                	li	a3,0
    800012ea:	4605                	li	a2,1
    800012ec:	020005b7          	lui	a1,0x2000
    800012f0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800012f2:	05b6                	slli	a1,a1,0xd
    800012f4:	8526                	mv	a0,s1
    800012f6:	d9aff0ef          	jal	ra,80000890 <uvmunmap>
  uvmfree(pagetable, sz);
    800012fa:	85ca                	mv	a1,s2
    800012fc:	8526                	mv	a0,s1
    800012fe:	8cbff0ef          	jal	ra,80000bc8 <uvmfree>
}
    80001302:	60e2                	ld	ra,24(sp)
    80001304:	6442                	ld	s0,16(sp)
    80001306:	64a2                	ld	s1,8(sp)
    80001308:	6902                	ld	s2,0(sp)
    8000130a:	6105                	addi	sp,sp,32
    8000130c:	8082                	ret

000000008000130e <freeproc>:
{
    8000130e:	1101                	addi	sp,sp,-32
    80001310:	ec06                	sd	ra,24(sp)
    80001312:	e822                	sd	s0,16(sp)
    80001314:	e426                	sd	s1,8(sp)
    80001316:	1000                	addi	s0,sp,32
    80001318:	84aa                	mv	s1,a0
  if(p->trapframe)
    8000131a:	6d28                	ld	a0,88(a0)
    8000131c:	c119                	beqz	a0,80001322 <freeproc+0x14>
    kfree((void*)p->trapframe);
    8000131e:	d53fe0ef          	jal	ra,80000070 <kfree>
  p->trapframe = 0;
    80001322:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001326:	68a8                	ld	a0,80(s1)
    80001328:	c501                	beqz	a0,80001330 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    8000132a:	64ac                	ld	a1,72(s1)
    8000132c:	f9dff0ef          	jal	ra,800012c8 <proc_freepagetable>
  p->pagetable = 0;
    80001330:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001334:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001338:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    8000133c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001340:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001344:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001348:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    8000134c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001350:	0004ac23          	sw	zero,24(s1)
}
    80001354:	60e2                	ld	ra,24(sp)
    80001356:	6442                	ld	s0,16(sp)
    80001358:	64a2                	ld	s1,8(sp)
    8000135a:	6105                	addi	sp,sp,32
    8000135c:	8082                	ret

000000008000135e <allocproc>:
{
    8000135e:	1101                	addi	sp,sp,-32
    80001360:	ec06                	sd	ra,24(sp)
    80001362:	e822                	sd	s0,16(sp)
    80001364:	e426                	sd	s1,8(sp)
    80001366:	e04a                	sd	s2,0(sp)
    80001368:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    8000136a:	00007497          	auipc	s1,0x7
    8000136e:	d8648493          	addi	s1,s1,-634 # 800080f0 <proc>
    80001372:	0000c917          	auipc	s2,0xc
    80001376:	77e90913          	addi	s2,s2,1918 # 8000daf0 <tickslock>
    acquire(&p->lock);
    8000137a:	8526                	mv	a0,s1
    8000137c:	6b6040ef          	jal	ra,80005a32 <acquire>
    if(p->state == UNUSED) {
    80001380:	4c9c                	lw	a5,24(s1)
    80001382:	cb91                	beqz	a5,80001396 <allocproc+0x38>
      release(&p->lock);
    80001384:	8526                	mv	a0,s1
    80001386:	744040ef          	jal	ra,80005aca <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000138a:	16848493          	addi	s1,s1,360
    8000138e:	ff2496e3          	bne	s1,s2,8000137a <allocproc+0x1c>
  return 0;
    80001392:	4481                	li	s1,0
    80001394:	a089                	j	800013d6 <allocproc+0x78>
  p->pid = allocpid();
    80001396:	e71ff0ef          	jal	ra,80001206 <allocpid>
    8000139a:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000139c:	4785                	li	a5,1
    8000139e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800013a0:	dc5fe0ef          	jal	ra,80000164 <kalloc>
    800013a4:	892a                	mv	s2,a0
    800013a6:	eca8                	sd	a0,88(s1)
    800013a8:	cd15                	beqz	a0,800013e4 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    800013aa:	8526                	mv	a0,s1
    800013ac:	e99ff0ef          	jal	ra,80001244 <proc_pagetable>
    800013b0:	892a                	mv	s2,a0
    800013b2:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800013b4:	c121                	beqz	a0,800013f4 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    800013b6:	07000613          	li	a2,112
    800013ba:	4581                	li	a1,0
    800013bc:	06048513          	addi	a0,s1,96
    800013c0:	ef3fe0ef          	jal	ra,800002b2 <memset>
  p->context.ra = (uint64)forkret;
    800013c4:	00000797          	auipc	a5,0x0
    800013c8:	e0878793          	addi	a5,a5,-504 # 800011cc <forkret>
    800013cc:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800013ce:	60bc                	ld	a5,64(s1)
    800013d0:	6705                	lui	a4,0x1
    800013d2:	97ba                	add	a5,a5,a4
    800013d4:	f4bc                	sd	a5,104(s1)
}
    800013d6:	8526                	mv	a0,s1
    800013d8:	60e2                	ld	ra,24(sp)
    800013da:	6442                	ld	s0,16(sp)
    800013dc:	64a2                	ld	s1,8(sp)
    800013de:	6902                	ld	s2,0(sp)
    800013e0:	6105                	addi	sp,sp,32
    800013e2:	8082                	ret
    freeproc(p);
    800013e4:	8526                	mv	a0,s1
    800013e6:	f29ff0ef          	jal	ra,8000130e <freeproc>
    release(&p->lock);
    800013ea:	8526                	mv	a0,s1
    800013ec:	6de040ef          	jal	ra,80005aca <release>
    return 0;
    800013f0:	84ca                	mv	s1,s2
    800013f2:	b7d5                	j	800013d6 <allocproc+0x78>
    freeproc(p);
    800013f4:	8526                	mv	a0,s1
    800013f6:	f19ff0ef          	jal	ra,8000130e <freeproc>
    release(&p->lock);
    800013fa:	8526                	mv	a0,s1
    800013fc:	6ce040ef          	jal	ra,80005aca <release>
    return 0;
    80001400:	84ca                	mv	s1,s2
    80001402:	bfd1                	j	800013d6 <allocproc+0x78>

0000000080001404 <userinit>:
{
    80001404:	1101                	addi	sp,sp,-32
    80001406:	ec06                	sd	ra,24(sp)
    80001408:	e822                	sd	s0,16(sp)
    8000140a:	e426                	sd	s1,8(sp)
    8000140c:	1000                	addi	s0,sp,32
  p = allocproc();
    8000140e:	f51ff0ef          	jal	ra,8000135e <allocproc>
    80001412:	84aa                	mv	s1,a0
  initproc = p;
    80001414:	00006797          	auipc	a5,0x6
    80001418:	66a7b623          	sd	a0,1644(a5) # 80007a80 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    8000141c:	03400613          	li	a2,52
    80001420:	00006597          	auipc	a1,0x6
    80001424:	5f058593          	addi	a1,a1,1520 # 80007a10 <initcode>
    80001428:	6928                	ld	a0,80(a0)
    8000142a:	d96ff0ef          	jal	ra,800009c0 <uvmfirst>
  p->sz = PGSIZE;
    8000142e:	6785                	lui	a5,0x1
    80001430:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001432:	6cb8                	ld	a4,88(s1)
    80001434:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001438:	6cb8                	ld	a4,88(s1)
    8000143a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    8000143c:	4641                	li	a2,16
    8000143e:	00006597          	auipc	a1,0x6
    80001442:	e9a58593          	addi	a1,a1,-358 # 800072d8 <etext+0x2d8>
    80001446:	15848513          	addi	a0,s1,344
    8000144a:	faffe0ef          	jal	ra,800003f8 <safestrcpy>
  p->cwd = namei("/");
    8000144e:	00006517          	auipc	a0,0x6
    80001452:	e9a50513          	addi	a0,a0,-358 # 800072e8 <etext+0x2e8>
    80001456:	50d010ef          	jal	ra,80003162 <namei>
    8000145a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000145e:	478d                	li	a5,3
    80001460:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001462:	8526                	mv	a0,s1
    80001464:	666040ef          	jal	ra,80005aca <release>
}
    80001468:	60e2                	ld	ra,24(sp)
    8000146a:	6442                	ld	s0,16(sp)
    8000146c:	64a2                	ld	s1,8(sp)
    8000146e:	6105                	addi	sp,sp,32
    80001470:	8082                	ret

0000000080001472 <growproc>:
{
    80001472:	1101                	addi	sp,sp,-32
    80001474:	ec06                	sd	ra,24(sp)
    80001476:	e822                	sd	s0,16(sp)
    80001478:	e426                	sd	s1,8(sp)
    8000147a:	e04a                	sd	s2,0(sp)
    8000147c:	1000                	addi	s0,sp,32
    8000147e:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001480:	d1dff0ef          	jal	ra,8000119c <myproc>
    80001484:	84aa                	mv	s1,a0
  sz = p->sz;
    80001486:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001488:	01204c63          	bgtz	s2,800014a0 <growproc+0x2e>
  } else if(n < 0){
    8000148c:	02094463          	bltz	s2,800014b4 <growproc+0x42>
  p->sz = sz;
    80001490:	e4ac                	sd	a1,72(s1)
  return 0;
    80001492:	4501                	li	a0,0
}
    80001494:	60e2                	ld	ra,24(sp)
    80001496:	6442                	ld	s0,16(sp)
    80001498:	64a2                	ld	s1,8(sp)
    8000149a:	6902                	ld	s2,0(sp)
    8000149c:	6105                	addi	sp,sp,32
    8000149e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800014a0:	4691                	li	a3,4
    800014a2:	00b90633          	add	a2,s2,a1
    800014a6:	6928                	ld	a0,80(a0)
    800014a8:	dbaff0ef          	jal	ra,80000a62 <uvmalloc>
    800014ac:	85aa                	mv	a1,a0
    800014ae:	f16d                	bnez	a0,80001490 <growproc+0x1e>
      return -1;
    800014b0:	557d                	li	a0,-1
    800014b2:	b7cd                	j	80001494 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800014b4:	00b90633          	add	a2,s2,a1
    800014b8:	6928                	ld	a0,80(a0)
    800014ba:	d64ff0ef          	jal	ra,80000a1e <uvmdealloc>
    800014be:	85aa                	mv	a1,a0
    800014c0:	bfc1                	j	80001490 <growproc+0x1e>

00000000800014c2 <fork>:
{
    800014c2:	7139                	addi	sp,sp,-64
    800014c4:	fc06                	sd	ra,56(sp)
    800014c6:	f822                	sd	s0,48(sp)
    800014c8:	f426                	sd	s1,40(sp)
    800014ca:	f04a                	sd	s2,32(sp)
    800014cc:	ec4e                	sd	s3,24(sp)
    800014ce:	e852                	sd	s4,16(sp)
    800014d0:	e456                	sd	s5,8(sp)
    800014d2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800014d4:	cc9ff0ef          	jal	ra,8000119c <myproc>
    800014d8:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800014da:	e85ff0ef          	jal	ra,8000135e <allocproc>
    800014de:	0e050663          	beqz	a0,800015ca <fork+0x108>
    800014e2:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800014e4:	048ab603          	ld	a2,72(s5)
    800014e8:	692c                	ld	a1,80(a0)
    800014ea:	050ab503          	ld	a0,80(s5)
    800014ee:	f0cff0ef          	jal	ra,80000bfa <uvmcopy>
    800014f2:	04054863          	bltz	a0,80001542 <fork+0x80>
  np->sz = p->sz;
    800014f6:	048ab783          	ld	a5,72(s5)
    800014fa:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    800014fe:	058ab683          	ld	a3,88(s5)
    80001502:	87b6                	mv	a5,a3
    80001504:	058a3703          	ld	a4,88(s4)
    80001508:	12068693          	addi	a3,a3,288
    8000150c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001510:	6788                	ld	a0,8(a5)
    80001512:	6b8c                	ld	a1,16(a5)
    80001514:	6f90                	ld	a2,24(a5)
    80001516:	01073023          	sd	a6,0(a4)
    8000151a:	e708                	sd	a0,8(a4)
    8000151c:	eb0c                	sd	a1,16(a4)
    8000151e:	ef10                	sd	a2,24(a4)
    80001520:	02078793          	addi	a5,a5,32
    80001524:	02070713          	addi	a4,a4,32
    80001528:	fed792e3          	bne	a5,a3,8000150c <fork+0x4a>
  np->trapframe->a0 = 0;
    8000152c:	058a3783          	ld	a5,88(s4)
    80001530:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001534:	0d0a8493          	addi	s1,s5,208
    80001538:	0d0a0913          	addi	s2,s4,208
    8000153c:	150a8993          	addi	s3,s5,336
    80001540:	a829                	j	8000155a <fork+0x98>
    freeproc(np);
    80001542:	8552                	mv	a0,s4
    80001544:	dcbff0ef          	jal	ra,8000130e <freeproc>
    release(&np->lock);
    80001548:	8552                	mv	a0,s4
    8000154a:	580040ef          	jal	ra,80005aca <release>
    return -1;
    8000154e:	597d                	li	s2,-1
    80001550:	a09d                	j	800015b6 <fork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001552:	04a1                	addi	s1,s1,8
    80001554:	0921                	addi	s2,s2,8
    80001556:	01348963          	beq	s1,s3,80001568 <fork+0xa6>
    if(p->ofile[i])
    8000155a:	6088                	ld	a0,0(s1)
    8000155c:	d97d                	beqz	a0,80001552 <fork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    8000155e:	1b2020ef          	jal	ra,80003710 <filedup>
    80001562:	00a93023          	sd	a0,0(s2)
    80001566:	b7f5                	j	80001552 <fork+0x90>
  np->cwd = idup(p->cwd);
    80001568:	150ab503          	ld	a0,336(s5)
    8000156c:	508010ef          	jal	ra,80002a74 <idup>
    80001570:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001574:	4641                	li	a2,16
    80001576:	158a8593          	addi	a1,s5,344
    8000157a:	158a0513          	addi	a0,s4,344
    8000157e:	e7bfe0ef          	jal	ra,800003f8 <safestrcpy>
  pid = np->pid;
    80001582:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001586:	8552                	mv	a0,s4
    80001588:	542040ef          	jal	ra,80005aca <release>
  acquire(&wait_lock);
    8000158c:	00006497          	auipc	s1,0x6
    80001590:	74c48493          	addi	s1,s1,1868 # 80007cd8 <wait_lock>
    80001594:	8526                	mv	a0,s1
    80001596:	49c040ef          	jal	ra,80005a32 <acquire>
  np->parent = p;
    8000159a:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    8000159e:	8526                	mv	a0,s1
    800015a0:	52a040ef          	jal	ra,80005aca <release>
  acquire(&np->lock);
    800015a4:	8552                	mv	a0,s4
    800015a6:	48c040ef          	jal	ra,80005a32 <acquire>
  np->state = RUNNABLE;
    800015aa:	478d                	li	a5,3
    800015ac:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    800015b0:	8552                	mv	a0,s4
    800015b2:	518040ef          	jal	ra,80005aca <release>
}
    800015b6:	854a                	mv	a0,s2
    800015b8:	70e2                	ld	ra,56(sp)
    800015ba:	7442                	ld	s0,48(sp)
    800015bc:	74a2                	ld	s1,40(sp)
    800015be:	7902                	ld	s2,32(sp)
    800015c0:	69e2                	ld	s3,24(sp)
    800015c2:	6a42                	ld	s4,16(sp)
    800015c4:	6aa2                	ld	s5,8(sp)
    800015c6:	6121                	addi	sp,sp,64
    800015c8:	8082                	ret
    return -1;
    800015ca:	597d                	li	s2,-1
    800015cc:	b7ed                	j	800015b6 <fork+0xf4>

00000000800015ce <scheduler>:
{
    800015ce:	715d                	addi	sp,sp,-80
    800015d0:	e486                	sd	ra,72(sp)
    800015d2:	e0a2                	sd	s0,64(sp)
    800015d4:	fc26                	sd	s1,56(sp)
    800015d6:	f84a                	sd	s2,48(sp)
    800015d8:	f44e                	sd	s3,40(sp)
    800015da:	f052                	sd	s4,32(sp)
    800015dc:	ec56                	sd	s5,24(sp)
    800015de:	e85a                	sd	s6,16(sp)
    800015e0:	e45e                	sd	s7,8(sp)
    800015e2:	e062                	sd	s8,0(sp)
    800015e4:	0880                	addi	s0,sp,80
    800015e6:	8792                	mv	a5,tp
  int id = r_tp();
    800015e8:	2781                	sext.w	a5,a5
  c->proc = 0;
    800015ea:	00779b13          	slli	s6,a5,0x7
    800015ee:	00006717          	auipc	a4,0x6
    800015f2:	6d270713          	addi	a4,a4,1746 # 80007cc0 <pid_lock>
    800015f6:	975a                	add	a4,a4,s6
    800015f8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800015fc:	00006717          	auipc	a4,0x6
    80001600:	6fc70713          	addi	a4,a4,1788 # 80007cf8 <cpus+0x8>
    80001604:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001606:	4c11                	li	s8,4
        c->proc = p;
    80001608:	079e                	slli	a5,a5,0x7
    8000160a:	00006a17          	auipc	s4,0x6
    8000160e:	6b6a0a13          	addi	s4,s4,1718 # 80007cc0 <pid_lock>
    80001612:	9a3e                	add	s4,s4,a5
        found = 1;
    80001614:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001616:	0000c997          	auipc	s3,0xc
    8000161a:	4da98993          	addi	s3,s3,1242 # 8000daf0 <tickslock>
    8000161e:	a0a9                	j	80001668 <scheduler+0x9a>
      release(&p->lock);
    80001620:	8526                	mv	a0,s1
    80001622:	4a8040ef          	jal	ra,80005aca <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001626:	16848493          	addi	s1,s1,360
    8000162a:	03348563          	beq	s1,s3,80001654 <scheduler+0x86>
      acquire(&p->lock);
    8000162e:	8526                	mv	a0,s1
    80001630:	402040ef          	jal	ra,80005a32 <acquire>
      if(p->state == RUNNABLE) {
    80001634:	4c9c                	lw	a5,24(s1)
    80001636:	ff2795e3          	bne	a5,s2,80001620 <scheduler+0x52>
        p->state = RUNNING;
    8000163a:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000163e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001642:	06048593          	addi	a1,s1,96
    80001646:	855a                	mv	a0,s6
    80001648:	5b4000ef          	jal	ra,80001bfc <swtch>
        c->proc = 0;
    8000164c:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001650:	8ade                	mv	s5,s7
    80001652:	b7f9                	j	80001620 <scheduler+0x52>
    if(found == 0) {
    80001654:	000a9a63          	bnez	s5,80001668 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001658:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000165c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001660:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001664:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001668:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000166c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001670:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001674:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001676:	00007497          	auipc	s1,0x7
    8000167a:	a7a48493          	addi	s1,s1,-1414 # 800080f0 <proc>
      if(p->state == RUNNABLE) {
    8000167e:	490d                	li	s2,3
    80001680:	b77d                	j	8000162e <scheduler+0x60>

0000000080001682 <sched>:
{
    80001682:	7179                	addi	sp,sp,-48
    80001684:	f406                	sd	ra,40(sp)
    80001686:	f022                	sd	s0,32(sp)
    80001688:	ec26                	sd	s1,24(sp)
    8000168a:	e84a                	sd	s2,16(sp)
    8000168c:	e44e                	sd	s3,8(sp)
    8000168e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001690:	b0dff0ef          	jal	ra,8000119c <myproc>
    80001694:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001696:	332040ef          	jal	ra,800059c8 <holding>
    8000169a:	c92d                	beqz	a0,8000170c <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000169c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000169e:	2781                	sext.w	a5,a5
    800016a0:	079e                	slli	a5,a5,0x7
    800016a2:	00006717          	auipc	a4,0x6
    800016a6:	61e70713          	addi	a4,a4,1566 # 80007cc0 <pid_lock>
    800016aa:	97ba                	add	a5,a5,a4
    800016ac:	0a87a703          	lw	a4,168(a5)
    800016b0:	4785                	li	a5,1
    800016b2:	06f71363          	bne	a4,a5,80001718 <sched+0x96>
  if(p->state == RUNNING)
    800016b6:	4c98                	lw	a4,24(s1)
    800016b8:	4791                	li	a5,4
    800016ba:	06f70563          	beq	a4,a5,80001724 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800016be:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800016c2:	8b89                	andi	a5,a5,2
  if(intr_get())
    800016c4:	e7b5                	bnez	a5,80001730 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800016c6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800016c8:	00006917          	auipc	s2,0x6
    800016cc:	5f890913          	addi	s2,s2,1528 # 80007cc0 <pid_lock>
    800016d0:	2781                	sext.w	a5,a5
    800016d2:	079e                	slli	a5,a5,0x7
    800016d4:	97ca                	add	a5,a5,s2
    800016d6:	0ac7a983          	lw	s3,172(a5)
    800016da:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800016dc:	2781                	sext.w	a5,a5
    800016de:	079e                	slli	a5,a5,0x7
    800016e0:	00006597          	auipc	a1,0x6
    800016e4:	61858593          	addi	a1,a1,1560 # 80007cf8 <cpus+0x8>
    800016e8:	95be                	add	a1,a1,a5
    800016ea:	06048513          	addi	a0,s1,96
    800016ee:	50e000ef          	jal	ra,80001bfc <swtch>
    800016f2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800016f4:	2781                	sext.w	a5,a5
    800016f6:	079e                	slli	a5,a5,0x7
    800016f8:	993e                	add	s2,s2,a5
    800016fa:	0b392623          	sw	s3,172(s2)
}
    800016fe:	70a2                	ld	ra,40(sp)
    80001700:	7402                	ld	s0,32(sp)
    80001702:	64e2                	ld	s1,24(sp)
    80001704:	6942                	ld	s2,16(sp)
    80001706:	69a2                	ld	s3,8(sp)
    80001708:	6145                	addi	sp,sp,48
    8000170a:	8082                	ret
    panic("sched p->lock");
    8000170c:	00006517          	auipc	a0,0x6
    80001710:	be450513          	addi	a0,a0,-1052 # 800072f0 <etext+0x2f0>
    80001714:	00e040ef          	jal	ra,80005722 <panic>
    panic("sched locks");
    80001718:	00006517          	auipc	a0,0x6
    8000171c:	be850513          	addi	a0,a0,-1048 # 80007300 <etext+0x300>
    80001720:	002040ef          	jal	ra,80005722 <panic>
    panic("sched running");
    80001724:	00006517          	auipc	a0,0x6
    80001728:	bec50513          	addi	a0,a0,-1044 # 80007310 <etext+0x310>
    8000172c:	7f7030ef          	jal	ra,80005722 <panic>
    panic("sched interruptible");
    80001730:	00006517          	auipc	a0,0x6
    80001734:	bf050513          	addi	a0,a0,-1040 # 80007320 <etext+0x320>
    80001738:	7eb030ef          	jal	ra,80005722 <panic>

000000008000173c <yield>:
{
    8000173c:	1101                	addi	sp,sp,-32
    8000173e:	ec06                	sd	ra,24(sp)
    80001740:	e822                	sd	s0,16(sp)
    80001742:	e426                	sd	s1,8(sp)
    80001744:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001746:	a57ff0ef          	jal	ra,8000119c <myproc>
    8000174a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000174c:	2e6040ef          	jal	ra,80005a32 <acquire>
  p->state = RUNNABLE;
    80001750:	478d                	li	a5,3
    80001752:	cc9c                	sw	a5,24(s1)
  sched();
    80001754:	f2fff0ef          	jal	ra,80001682 <sched>
  release(&p->lock);
    80001758:	8526                	mv	a0,s1
    8000175a:	370040ef          	jal	ra,80005aca <release>
}
    8000175e:	60e2                	ld	ra,24(sp)
    80001760:	6442                	ld	s0,16(sp)
    80001762:	64a2                	ld	s1,8(sp)
    80001764:	6105                	addi	sp,sp,32
    80001766:	8082                	ret

0000000080001768 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001768:	7179                	addi	sp,sp,-48
    8000176a:	f406                	sd	ra,40(sp)
    8000176c:	f022                	sd	s0,32(sp)
    8000176e:	ec26                	sd	s1,24(sp)
    80001770:	e84a                	sd	s2,16(sp)
    80001772:	e44e                	sd	s3,8(sp)
    80001774:	1800                	addi	s0,sp,48
    80001776:	89aa                	mv	s3,a0
    80001778:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000177a:	a23ff0ef          	jal	ra,8000119c <myproc>
    8000177e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001780:	2b2040ef          	jal	ra,80005a32 <acquire>
  release(lk);
    80001784:	854a                	mv	a0,s2
    80001786:	344040ef          	jal	ra,80005aca <release>

  // Go to sleep.
  p->chan = chan;
    8000178a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000178e:	4789                	li	a5,2
    80001790:	cc9c                	sw	a5,24(s1)

  sched();
    80001792:	ef1ff0ef          	jal	ra,80001682 <sched>

  // Tidy up.
  p->chan = 0;
    80001796:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000179a:	8526                	mv	a0,s1
    8000179c:	32e040ef          	jal	ra,80005aca <release>
  acquire(lk);
    800017a0:	854a                	mv	a0,s2
    800017a2:	290040ef          	jal	ra,80005a32 <acquire>
}
    800017a6:	70a2                	ld	ra,40(sp)
    800017a8:	7402                	ld	s0,32(sp)
    800017aa:	64e2                	ld	s1,24(sp)
    800017ac:	6942                	ld	s2,16(sp)
    800017ae:	69a2                	ld	s3,8(sp)
    800017b0:	6145                	addi	sp,sp,48
    800017b2:	8082                	ret

00000000800017b4 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800017b4:	7139                	addi	sp,sp,-64
    800017b6:	fc06                	sd	ra,56(sp)
    800017b8:	f822                	sd	s0,48(sp)
    800017ba:	f426                	sd	s1,40(sp)
    800017bc:	f04a                	sd	s2,32(sp)
    800017be:	ec4e                	sd	s3,24(sp)
    800017c0:	e852                	sd	s4,16(sp)
    800017c2:	e456                	sd	s5,8(sp)
    800017c4:	0080                	addi	s0,sp,64
    800017c6:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800017c8:	00007497          	auipc	s1,0x7
    800017cc:	92848493          	addi	s1,s1,-1752 # 800080f0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800017d0:	4989                	li	s3,2
        p->state = RUNNABLE;
    800017d2:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d4:	0000c917          	auipc	s2,0xc
    800017d8:	31c90913          	addi	s2,s2,796 # 8000daf0 <tickslock>
    800017dc:	a801                	j	800017ec <wakeup+0x38>
      }
      release(&p->lock);
    800017de:	8526                	mv	a0,s1
    800017e0:	2ea040ef          	jal	ra,80005aca <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017e4:	16848493          	addi	s1,s1,360
    800017e8:	03248263          	beq	s1,s2,8000180c <wakeup+0x58>
    if(p != myproc()){
    800017ec:	9b1ff0ef          	jal	ra,8000119c <myproc>
    800017f0:	fea48ae3          	beq	s1,a0,800017e4 <wakeup+0x30>
      acquire(&p->lock);
    800017f4:	8526                	mv	a0,s1
    800017f6:	23c040ef          	jal	ra,80005a32 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800017fa:	4c9c                	lw	a5,24(s1)
    800017fc:	ff3791e3          	bne	a5,s3,800017de <wakeup+0x2a>
    80001800:	709c                	ld	a5,32(s1)
    80001802:	fd479ee3          	bne	a5,s4,800017de <wakeup+0x2a>
        p->state = RUNNABLE;
    80001806:	0154ac23          	sw	s5,24(s1)
    8000180a:	bfd1                	j	800017de <wakeup+0x2a>
    }
  }
}
    8000180c:	70e2                	ld	ra,56(sp)
    8000180e:	7442                	ld	s0,48(sp)
    80001810:	74a2                	ld	s1,40(sp)
    80001812:	7902                	ld	s2,32(sp)
    80001814:	69e2                	ld	s3,24(sp)
    80001816:	6a42                	ld	s4,16(sp)
    80001818:	6aa2                	ld	s5,8(sp)
    8000181a:	6121                	addi	sp,sp,64
    8000181c:	8082                	ret

000000008000181e <reparent>:
{
    8000181e:	7179                	addi	sp,sp,-48
    80001820:	f406                	sd	ra,40(sp)
    80001822:	f022                	sd	s0,32(sp)
    80001824:	ec26                	sd	s1,24(sp)
    80001826:	e84a                	sd	s2,16(sp)
    80001828:	e44e                	sd	s3,8(sp)
    8000182a:	e052                	sd	s4,0(sp)
    8000182c:	1800                	addi	s0,sp,48
    8000182e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001830:	00007497          	auipc	s1,0x7
    80001834:	8c048493          	addi	s1,s1,-1856 # 800080f0 <proc>
      pp->parent = initproc;
    80001838:	00006a17          	auipc	s4,0x6
    8000183c:	248a0a13          	addi	s4,s4,584 # 80007a80 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001840:	0000c997          	auipc	s3,0xc
    80001844:	2b098993          	addi	s3,s3,688 # 8000daf0 <tickslock>
    80001848:	a029                	j	80001852 <reparent+0x34>
    8000184a:	16848493          	addi	s1,s1,360
    8000184e:	01348b63          	beq	s1,s3,80001864 <reparent+0x46>
    if(pp->parent == p){
    80001852:	7c9c                	ld	a5,56(s1)
    80001854:	ff279be3          	bne	a5,s2,8000184a <reparent+0x2c>
      pp->parent = initproc;
    80001858:	000a3503          	ld	a0,0(s4)
    8000185c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000185e:	f57ff0ef          	jal	ra,800017b4 <wakeup>
    80001862:	b7e5                	j	8000184a <reparent+0x2c>
}
    80001864:	70a2                	ld	ra,40(sp)
    80001866:	7402                	ld	s0,32(sp)
    80001868:	64e2                	ld	s1,24(sp)
    8000186a:	6942                	ld	s2,16(sp)
    8000186c:	69a2                	ld	s3,8(sp)
    8000186e:	6a02                	ld	s4,0(sp)
    80001870:	6145                	addi	sp,sp,48
    80001872:	8082                	ret

0000000080001874 <exit>:
{
    80001874:	7179                	addi	sp,sp,-48
    80001876:	f406                	sd	ra,40(sp)
    80001878:	f022                	sd	s0,32(sp)
    8000187a:	ec26                	sd	s1,24(sp)
    8000187c:	e84a                	sd	s2,16(sp)
    8000187e:	e44e                	sd	s3,8(sp)
    80001880:	e052                	sd	s4,0(sp)
    80001882:	1800                	addi	s0,sp,48
    80001884:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001886:	917ff0ef          	jal	ra,8000119c <myproc>
    8000188a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000188c:	00006797          	auipc	a5,0x6
    80001890:	1f47b783          	ld	a5,500(a5) # 80007a80 <initproc>
    80001894:	0d050493          	addi	s1,a0,208
    80001898:	15050913          	addi	s2,a0,336
    8000189c:	00a79f63          	bne	a5,a0,800018ba <exit+0x46>
    panic("init exiting");
    800018a0:	00006517          	auipc	a0,0x6
    800018a4:	a9850513          	addi	a0,a0,-1384 # 80007338 <etext+0x338>
    800018a8:	67b030ef          	jal	ra,80005722 <panic>
      fileclose(f);
    800018ac:	6ab010ef          	jal	ra,80003756 <fileclose>
      p->ofile[fd] = 0;
    800018b0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800018b4:	04a1                	addi	s1,s1,8
    800018b6:	01248563          	beq	s1,s2,800018c0 <exit+0x4c>
    if(p->ofile[fd]){
    800018ba:	6088                	ld	a0,0(s1)
    800018bc:	f965                	bnez	a0,800018ac <exit+0x38>
    800018be:	bfdd                	j	800018b4 <exit+0x40>
  begin_op();
    800018c0:	27f010ef          	jal	ra,8000333e <begin_op>
  iput(p->cwd);
    800018c4:	1509b503          	ld	a0,336(s3)
    800018c8:	360010ef          	jal	ra,80002c28 <iput>
  end_op();
    800018cc:	2e1010ef          	jal	ra,800033ac <end_op>
  p->cwd = 0;
    800018d0:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800018d4:	00006497          	auipc	s1,0x6
    800018d8:	40448493          	addi	s1,s1,1028 # 80007cd8 <wait_lock>
    800018dc:	8526                	mv	a0,s1
    800018de:	154040ef          	jal	ra,80005a32 <acquire>
  reparent(p);
    800018e2:	854e                	mv	a0,s3
    800018e4:	f3bff0ef          	jal	ra,8000181e <reparent>
  wakeup(p->parent);
    800018e8:	0389b503          	ld	a0,56(s3)
    800018ec:	ec9ff0ef          	jal	ra,800017b4 <wakeup>
  acquire(&p->lock);
    800018f0:	854e                	mv	a0,s3
    800018f2:	140040ef          	jal	ra,80005a32 <acquire>
  p->xstate = status;
    800018f6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800018fa:	4795                	li	a5,5
    800018fc:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001900:	8526                	mv	a0,s1
    80001902:	1c8040ef          	jal	ra,80005aca <release>
  sched();
    80001906:	d7dff0ef          	jal	ra,80001682 <sched>
  panic("zombie exit");
    8000190a:	00006517          	auipc	a0,0x6
    8000190e:	a3e50513          	addi	a0,a0,-1474 # 80007348 <etext+0x348>
    80001912:	611030ef          	jal	ra,80005722 <panic>

0000000080001916 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001916:	7179                	addi	sp,sp,-48
    80001918:	f406                	sd	ra,40(sp)
    8000191a:	f022                	sd	s0,32(sp)
    8000191c:	ec26                	sd	s1,24(sp)
    8000191e:	e84a                	sd	s2,16(sp)
    80001920:	e44e                	sd	s3,8(sp)
    80001922:	1800                	addi	s0,sp,48
    80001924:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001926:	00006497          	auipc	s1,0x6
    8000192a:	7ca48493          	addi	s1,s1,1994 # 800080f0 <proc>
    8000192e:	0000c997          	auipc	s3,0xc
    80001932:	1c298993          	addi	s3,s3,450 # 8000daf0 <tickslock>
    acquire(&p->lock);
    80001936:	8526                	mv	a0,s1
    80001938:	0fa040ef          	jal	ra,80005a32 <acquire>
    if(p->pid == pid){
    8000193c:	589c                	lw	a5,48(s1)
    8000193e:	01278b63          	beq	a5,s2,80001954 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001942:	8526                	mv	a0,s1
    80001944:	186040ef          	jal	ra,80005aca <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001948:	16848493          	addi	s1,s1,360
    8000194c:	ff3495e3          	bne	s1,s3,80001936 <kill+0x20>
  }
  return -1;
    80001950:	557d                	li	a0,-1
    80001952:	a819                	j	80001968 <kill+0x52>
      p->killed = 1;
    80001954:	4785                	li	a5,1
    80001956:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001958:	4c98                	lw	a4,24(s1)
    8000195a:	4789                	li	a5,2
    8000195c:	00f70d63          	beq	a4,a5,80001976 <kill+0x60>
      release(&p->lock);
    80001960:	8526                	mv	a0,s1
    80001962:	168040ef          	jal	ra,80005aca <release>
      return 0;
    80001966:	4501                	li	a0,0
}
    80001968:	70a2                	ld	ra,40(sp)
    8000196a:	7402                	ld	s0,32(sp)
    8000196c:	64e2                	ld	s1,24(sp)
    8000196e:	6942                	ld	s2,16(sp)
    80001970:	69a2                	ld	s3,8(sp)
    80001972:	6145                	addi	sp,sp,48
    80001974:	8082                	ret
        p->state = RUNNABLE;
    80001976:	478d                	li	a5,3
    80001978:	cc9c                	sw	a5,24(s1)
    8000197a:	b7dd                	j	80001960 <kill+0x4a>

000000008000197c <setkilled>:

void
setkilled(struct proc *p)
{
    8000197c:	1101                	addi	sp,sp,-32
    8000197e:	ec06                	sd	ra,24(sp)
    80001980:	e822                	sd	s0,16(sp)
    80001982:	e426                	sd	s1,8(sp)
    80001984:	1000                	addi	s0,sp,32
    80001986:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001988:	0aa040ef          	jal	ra,80005a32 <acquire>
  p->killed = 1;
    8000198c:	4785                	li	a5,1
    8000198e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001990:	8526                	mv	a0,s1
    80001992:	138040ef          	jal	ra,80005aca <release>
}
    80001996:	60e2                	ld	ra,24(sp)
    80001998:	6442                	ld	s0,16(sp)
    8000199a:	64a2                	ld	s1,8(sp)
    8000199c:	6105                	addi	sp,sp,32
    8000199e:	8082                	ret

00000000800019a0 <killed>:

int
killed(struct proc *p)
{
    800019a0:	1101                	addi	sp,sp,-32
    800019a2:	ec06                	sd	ra,24(sp)
    800019a4:	e822                	sd	s0,16(sp)
    800019a6:	e426                	sd	s1,8(sp)
    800019a8:	e04a                	sd	s2,0(sp)
    800019aa:	1000                	addi	s0,sp,32
    800019ac:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800019ae:	084040ef          	jal	ra,80005a32 <acquire>
  k = p->killed;
    800019b2:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800019b6:	8526                	mv	a0,s1
    800019b8:	112040ef          	jal	ra,80005aca <release>
  return k;
}
    800019bc:	854a                	mv	a0,s2
    800019be:	60e2                	ld	ra,24(sp)
    800019c0:	6442                	ld	s0,16(sp)
    800019c2:	64a2                	ld	s1,8(sp)
    800019c4:	6902                	ld	s2,0(sp)
    800019c6:	6105                	addi	sp,sp,32
    800019c8:	8082                	ret

00000000800019ca <wait>:
{
    800019ca:	715d                	addi	sp,sp,-80
    800019cc:	e486                	sd	ra,72(sp)
    800019ce:	e0a2                	sd	s0,64(sp)
    800019d0:	fc26                	sd	s1,56(sp)
    800019d2:	f84a                	sd	s2,48(sp)
    800019d4:	f44e                	sd	s3,40(sp)
    800019d6:	f052                	sd	s4,32(sp)
    800019d8:	ec56                	sd	s5,24(sp)
    800019da:	e85a                	sd	s6,16(sp)
    800019dc:	e45e                	sd	s7,8(sp)
    800019de:	e062                	sd	s8,0(sp)
    800019e0:	0880                	addi	s0,sp,80
    800019e2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800019e4:	fb8ff0ef          	jal	ra,8000119c <myproc>
    800019e8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800019ea:	00006517          	auipc	a0,0x6
    800019ee:	2ee50513          	addi	a0,a0,750 # 80007cd8 <wait_lock>
    800019f2:	040040ef          	jal	ra,80005a32 <acquire>
    havekids = 0;
    800019f6:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800019f8:	4a15                	li	s4,5
        havekids = 1;
    800019fa:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800019fc:	0000c997          	auipc	s3,0xc
    80001a00:	0f498993          	addi	s3,s3,244 # 8000daf0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001a04:	00006c17          	auipc	s8,0x6
    80001a08:	2d4c0c13          	addi	s8,s8,724 # 80007cd8 <wait_lock>
    havekids = 0;
    80001a0c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001a0e:	00006497          	auipc	s1,0x6
    80001a12:	6e248493          	addi	s1,s1,1762 # 800080f0 <proc>
    80001a16:	a899                	j	80001a6c <wait+0xa2>
          pid = pp->pid;
    80001a18:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001a1c:	000b0c63          	beqz	s6,80001a34 <wait+0x6a>
    80001a20:	4691                	li	a3,4
    80001a22:	02c48613          	addi	a2,s1,44
    80001a26:	85da                	mv	a1,s6
    80001a28:	05093503          	ld	a0,80(s2)
    80001a2c:	b14ff0ef          	jal	ra,80000d40 <copyout>
    80001a30:	00054f63          	bltz	a0,80001a4e <wait+0x84>
          freeproc(pp);
    80001a34:	8526                	mv	a0,s1
    80001a36:	8d9ff0ef          	jal	ra,8000130e <freeproc>
          release(&pp->lock);
    80001a3a:	8526                	mv	a0,s1
    80001a3c:	08e040ef          	jal	ra,80005aca <release>
          release(&wait_lock);
    80001a40:	00006517          	auipc	a0,0x6
    80001a44:	29850513          	addi	a0,a0,664 # 80007cd8 <wait_lock>
    80001a48:	082040ef          	jal	ra,80005aca <release>
          return pid;
    80001a4c:	a891                	j	80001aa0 <wait+0xd6>
            release(&pp->lock);
    80001a4e:	8526                	mv	a0,s1
    80001a50:	07a040ef          	jal	ra,80005aca <release>
            release(&wait_lock);
    80001a54:	00006517          	auipc	a0,0x6
    80001a58:	28450513          	addi	a0,a0,644 # 80007cd8 <wait_lock>
    80001a5c:	06e040ef          	jal	ra,80005aca <release>
            return -1;
    80001a60:	59fd                	li	s3,-1
    80001a62:	a83d                	j	80001aa0 <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001a64:	16848493          	addi	s1,s1,360
    80001a68:	03348063          	beq	s1,s3,80001a88 <wait+0xbe>
      if(pp->parent == p){
    80001a6c:	7c9c                	ld	a5,56(s1)
    80001a6e:	ff279be3          	bne	a5,s2,80001a64 <wait+0x9a>
        acquire(&pp->lock);
    80001a72:	8526                	mv	a0,s1
    80001a74:	7bf030ef          	jal	ra,80005a32 <acquire>
        if(pp->state == ZOMBIE){
    80001a78:	4c9c                	lw	a5,24(s1)
    80001a7a:	f9478fe3          	beq	a5,s4,80001a18 <wait+0x4e>
        release(&pp->lock);
    80001a7e:	8526                	mv	a0,s1
    80001a80:	04a040ef          	jal	ra,80005aca <release>
        havekids = 1;
    80001a84:	8756                	mv	a4,s5
    80001a86:	bff9                	j	80001a64 <wait+0x9a>
    if(!havekids || killed(p)){
    80001a88:	c709                	beqz	a4,80001a92 <wait+0xc8>
    80001a8a:	854a                	mv	a0,s2
    80001a8c:	f15ff0ef          	jal	ra,800019a0 <killed>
    80001a90:	c50d                	beqz	a0,80001aba <wait+0xf0>
      release(&wait_lock);
    80001a92:	00006517          	auipc	a0,0x6
    80001a96:	24650513          	addi	a0,a0,582 # 80007cd8 <wait_lock>
    80001a9a:	030040ef          	jal	ra,80005aca <release>
      return -1;
    80001a9e:	59fd                	li	s3,-1
}
    80001aa0:	854e                	mv	a0,s3
    80001aa2:	60a6                	ld	ra,72(sp)
    80001aa4:	6406                	ld	s0,64(sp)
    80001aa6:	74e2                	ld	s1,56(sp)
    80001aa8:	7942                	ld	s2,48(sp)
    80001aaa:	79a2                	ld	s3,40(sp)
    80001aac:	7a02                	ld	s4,32(sp)
    80001aae:	6ae2                	ld	s5,24(sp)
    80001ab0:	6b42                	ld	s6,16(sp)
    80001ab2:	6ba2                	ld	s7,8(sp)
    80001ab4:	6c02                	ld	s8,0(sp)
    80001ab6:	6161                	addi	sp,sp,80
    80001ab8:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001aba:	85e2                	mv	a1,s8
    80001abc:	854a                	mv	a0,s2
    80001abe:	cabff0ef          	jal	ra,80001768 <sleep>
    havekids = 0;
    80001ac2:	b7a9                	j	80001a0c <wait+0x42>

0000000080001ac4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001ac4:	7179                	addi	sp,sp,-48
    80001ac6:	f406                	sd	ra,40(sp)
    80001ac8:	f022                	sd	s0,32(sp)
    80001aca:	ec26                	sd	s1,24(sp)
    80001acc:	e84a                	sd	s2,16(sp)
    80001ace:	e44e                	sd	s3,8(sp)
    80001ad0:	e052                	sd	s4,0(sp)
    80001ad2:	1800                	addi	s0,sp,48
    80001ad4:	84aa                	mv	s1,a0
    80001ad6:	892e                	mv	s2,a1
    80001ad8:	89b2                	mv	s3,a2
    80001ada:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001adc:	ec0ff0ef          	jal	ra,8000119c <myproc>
  if(user_dst){
    80001ae0:	cc99                	beqz	s1,80001afe <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80001ae2:	86d2                	mv	a3,s4
    80001ae4:	864e                	mv	a2,s3
    80001ae6:	85ca                	mv	a1,s2
    80001ae8:	6928                	ld	a0,80(a0)
    80001aea:	a56ff0ef          	jal	ra,80000d40 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001aee:	70a2                	ld	ra,40(sp)
    80001af0:	7402                	ld	s0,32(sp)
    80001af2:	64e2                	ld	s1,24(sp)
    80001af4:	6942                	ld	s2,16(sp)
    80001af6:	69a2                	ld	s3,8(sp)
    80001af8:	6a02                	ld	s4,0(sp)
    80001afa:	6145                	addi	sp,sp,48
    80001afc:	8082                	ret
    memmove((char *)dst, src, len);
    80001afe:	000a061b          	sext.w	a2,s4
    80001b02:	85ce                	mv	a1,s3
    80001b04:	854a                	mv	a0,s2
    80001b06:	809fe0ef          	jal	ra,8000030e <memmove>
    return 0;
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	b7cd                	j	80001aee <either_copyout+0x2a>

0000000080001b0e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001b0e:	7179                	addi	sp,sp,-48
    80001b10:	f406                	sd	ra,40(sp)
    80001b12:	f022                	sd	s0,32(sp)
    80001b14:	ec26                	sd	s1,24(sp)
    80001b16:	e84a                	sd	s2,16(sp)
    80001b18:	e44e                	sd	s3,8(sp)
    80001b1a:	e052                	sd	s4,0(sp)
    80001b1c:	1800                	addi	s0,sp,48
    80001b1e:	892a                	mv	s2,a0
    80001b20:	84ae                	mv	s1,a1
    80001b22:	89b2                	mv	s3,a2
    80001b24:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001b26:	e76ff0ef          	jal	ra,8000119c <myproc>
  if(user_src){
    80001b2a:	cc99                	beqz	s1,80001b48 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80001b2c:	86d2                	mv	a3,s4
    80001b2e:	864e                	mv	a2,s3
    80001b30:	85ca                	mv	a1,s2
    80001b32:	6928                	ld	a0,80(a0)
    80001b34:	ac4ff0ef          	jal	ra,80000df8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001b38:	70a2                	ld	ra,40(sp)
    80001b3a:	7402                	ld	s0,32(sp)
    80001b3c:	64e2                	ld	s1,24(sp)
    80001b3e:	6942                	ld	s2,16(sp)
    80001b40:	69a2                	ld	s3,8(sp)
    80001b42:	6a02                	ld	s4,0(sp)
    80001b44:	6145                	addi	sp,sp,48
    80001b46:	8082                	ret
    memmove(dst, (char*)src, len);
    80001b48:	000a061b          	sext.w	a2,s4
    80001b4c:	85ce                	mv	a1,s3
    80001b4e:	854a                	mv	a0,s2
    80001b50:	fbefe0ef          	jal	ra,8000030e <memmove>
    return 0;
    80001b54:	8526                	mv	a0,s1
    80001b56:	b7cd                	j	80001b38 <either_copyin+0x2a>

0000000080001b58 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001b58:	715d                	addi	sp,sp,-80
    80001b5a:	e486                	sd	ra,72(sp)
    80001b5c:	e0a2                	sd	s0,64(sp)
    80001b5e:	fc26                	sd	s1,56(sp)
    80001b60:	f84a                	sd	s2,48(sp)
    80001b62:	f44e                	sd	s3,40(sp)
    80001b64:	f052                	sd	s4,32(sp)
    80001b66:	ec56                	sd	s5,24(sp)
    80001b68:	e85a                	sd	s6,16(sp)
    80001b6a:	e45e                	sd	s7,8(sp)
    80001b6c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001b6e:	00005517          	auipc	a0,0x5
    80001b72:	56250513          	addi	a0,a0,1378 # 800070d0 <etext+0xd0>
    80001b76:	0f9030ef          	jal	ra,8000546e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001b7a:	00006497          	auipc	s1,0x6
    80001b7e:	6ce48493          	addi	s1,s1,1742 # 80008248 <proc+0x158>
    80001b82:	0000c917          	auipc	s2,0xc
    80001b86:	0c690913          	addi	s2,s2,198 # 8000dc48 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001b8a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001b8c:	00005997          	auipc	s3,0x5
    80001b90:	7cc98993          	addi	s3,s3,1996 # 80007358 <etext+0x358>
    printf("%d %s %s", p->pid, state, p->name);
    80001b94:	00005a97          	auipc	s5,0x5
    80001b98:	7cca8a93          	addi	s5,s5,1996 # 80007360 <etext+0x360>
    printf("\n");
    80001b9c:	00005a17          	auipc	s4,0x5
    80001ba0:	534a0a13          	addi	s4,s4,1332 # 800070d0 <etext+0xd0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001ba4:	00005b97          	auipc	s7,0x5
    80001ba8:	7fcb8b93          	addi	s7,s7,2044 # 800073a0 <states.0>
    80001bac:	a829                	j	80001bc6 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80001bae:	ed86a583          	lw	a1,-296(a3)
    80001bb2:	8556                	mv	a0,s5
    80001bb4:	0bb030ef          	jal	ra,8000546e <printf>
    printf("\n");
    80001bb8:	8552                	mv	a0,s4
    80001bba:	0b5030ef          	jal	ra,8000546e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001bbe:	16848493          	addi	s1,s1,360
    80001bc2:	03248263          	beq	s1,s2,80001be6 <procdump+0x8e>
    if(p->state == UNUSED)
    80001bc6:	86a6                	mv	a3,s1
    80001bc8:	ec04a783          	lw	a5,-320(s1)
    80001bcc:	dbed                	beqz	a5,80001bbe <procdump+0x66>
      state = "???";
    80001bce:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001bd0:	fcfb6fe3          	bltu	s6,a5,80001bae <procdump+0x56>
    80001bd4:	02079713          	slli	a4,a5,0x20
    80001bd8:	01d75793          	srli	a5,a4,0x1d
    80001bdc:	97de                	add	a5,a5,s7
    80001bde:	6390                	ld	a2,0(a5)
    80001be0:	f679                	bnez	a2,80001bae <procdump+0x56>
      state = "???";
    80001be2:	864e                	mv	a2,s3
    80001be4:	b7e9                	j	80001bae <procdump+0x56>
  }
}
    80001be6:	60a6                	ld	ra,72(sp)
    80001be8:	6406                	ld	s0,64(sp)
    80001bea:	74e2                	ld	s1,56(sp)
    80001bec:	7942                	ld	s2,48(sp)
    80001bee:	79a2                	ld	s3,40(sp)
    80001bf0:	7a02                	ld	s4,32(sp)
    80001bf2:	6ae2                	ld	s5,24(sp)
    80001bf4:	6b42                	ld	s6,16(sp)
    80001bf6:	6ba2                	ld	s7,8(sp)
    80001bf8:	6161                	addi	sp,sp,80
    80001bfa:	8082                	ret

0000000080001bfc <swtch>:
    80001bfc:	00153023          	sd	ra,0(a0)
    80001c00:	00253423          	sd	sp,8(a0)
    80001c04:	e900                	sd	s0,16(a0)
    80001c06:	ed04                	sd	s1,24(a0)
    80001c08:	03253023          	sd	s2,32(a0)
    80001c0c:	03353423          	sd	s3,40(a0)
    80001c10:	03453823          	sd	s4,48(a0)
    80001c14:	03553c23          	sd	s5,56(a0)
    80001c18:	05653023          	sd	s6,64(a0)
    80001c1c:	05753423          	sd	s7,72(a0)
    80001c20:	05853823          	sd	s8,80(a0)
    80001c24:	05953c23          	sd	s9,88(a0)
    80001c28:	07a53023          	sd	s10,96(a0)
    80001c2c:	07b53423          	sd	s11,104(a0)
    80001c30:	0005b083          	ld	ra,0(a1)
    80001c34:	0085b103          	ld	sp,8(a1)
    80001c38:	6980                	ld	s0,16(a1)
    80001c3a:	6d84                	ld	s1,24(a1)
    80001c3c:	0205b903          	ld	s2,32(a1)
    80001c40:	0285b983          	ld	s3,40(a1)
    80001c44:	0305ba03          	ld	s4,48(a1)
    80001c48:	0385ba83          	ld	s5,56(a1)
    80001c4c:	0405bb03          	ld	s6,64(a1)
    80001c50:	0485bb83          	ld	s7,72(a1)
    80001c54:	0505bc03          	ld	s8,80(a1)
    80001c58:	0585bc83          	ld	s9,88(a1)
    80001c5c:	0605bd03          	ld	s10,96(a1)
    80001c60:	0685bd83          	ld	s11,104(a1)
    80001c64:	8082                	ret

0000000080001c66 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001c66:	1141                	addi	sp,sp,-16
    80001c68:	e406                	sd	ra,8(sp)
    80001c6a:	e022                	sd	s0,0(sp)
    80001c6c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001c6e:	00005597          	auipc	a1,0x5
    80001c72:	76258593          	addi	a1,a1,1890 # 800073d0 <states.0+0x30>
    80001c76:	0000c517          	auipc	a0,0xc
    80001c7a:	e7a50513          	addi	a0,a0,-390 # 8000daf0 <tickslock>
    80001c7e:	535030ef          	jal	ra,800059b2 <initlock>
}
    80001c82:	60a2                	ld	ra,8(sp)
    80001c84:	6402                	ld	s0,0(sp)
    80001c86:	0141                	addi	sp,sp,16
    80001c88:	8082                	ret

0000000080001c8a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001c8a:	1141                	addi	sp,sp,-16
    80001c8c:	e422                	sd	s0,8(sp)
    80001c8e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001c90:	00003797          	auipc	a5,0x3
    80001c94:	d8078793          	addi	a5,a5,-640 # 80004a10 <kernelvec>
    80001c98:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001c9c:	6422                	ld	s0,8(sp)
    80001c9e:	0141                	addi	sp,sp,16
    80001ca0:	8082                	ret

0000000080001ca2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001ca2:	1141                	addi	sp,sp,-16
    80001ca4:	e406                	sd	ra,8(sp)
    80001ca6:	e022                	sd	s0,0(sp)
    80001ca8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001caa:	cf2ff0ef          	jal	ra,8000119c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cae:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001cb2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001cb4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001cb8:	00004697          	auipc	a3,0x4
    80001cbc:	34868693          	addi	a3,a3,840 # 80006000 <_trampoline>
    80001cc0:	00004717          	auipc	a4,0x4
    80001cc4:	34070713          	addi	a4,a4,832 # 80006000 <_trampoline>
    80001cc8:	8f15                	sub	a4,a4,a3
    80001cca:	040007b7          	lui	a5,0x4000
    80001cce:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001cd0:	07b2                	slli	a5,a5,0xc
    80001cd2:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001cd4:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001cd8:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001cda:	18002673          	csrr	a2,satp
    80001cde:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001ce0:	6d30                	ld	a2,88(a0)
    80001ce2:	6138                	ld	a4,64(a0)
    80001ce4:	6585                	lui	a1,0x1
    80001ce6:	972e                	add	a4,a4,a1
    80001ce8:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001cea:	6d38                	ld	a4,88(a0)
    80001cec:	00000617          	auipc	a2,0x0
    80001cf0:	10c60613          	addi	a2,a2,268 # 80001df8 <usertrap>
    80001cf4:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001cf6:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001cf8:	8612                	mv	a2,tp
    80001cfa:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cfc:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001d00:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001d04:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d08:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001d0c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001d0e:	6f18                	ld	a4,24(a4)
    80001d10:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001d14:	6928                	ld	a0,80(a0)
    80001d16:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001d18:	00004717          	auipc	a4,0x4
    80001d1c:	38470713          	addi	a4,a4,900 # 8000609c <userret>
    80001d20:	8f15                	sub	a4,a4,a3
    80001d22:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001d24:	577d                	li	a4,-1
    80001d26:	177e                	slli	a4,a4,0x3f
    80001d28:	8d59                	or	a0,a0,a4
    80001d2a:	9782                	jalr	a5
}
    80001d2c:	60a2                	ld	ra,8(sp)
    80001d2e:	6402                	ld	s0,0(sp)
    80001d30:	0141                	addi	sp,sp,16
    80001d32:	8082                	ret

0000000080001d34 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001d34:	1101                	addi	sp,sp,-32
    80001d36:	ec06                	sd	ra,24(sp)
    80001d38:	e822                	sd	s0,16(sp)
    80001d3a:	e426                	sd	s1,8(sp)
    80001d3c:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001d3e:	c32ff0ef          	jal	ra,80001170 <cpuid>
    80001d42:	cd19                	beqz	a0,80001d60 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001d44:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001d48:	000f4737          	lui	a4,0xf4
    80001d4c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001d50:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001d52:	14d79073          	csrw	0x14d,a5
}
    80001d56:	60e2                	ld	ra,24(sp)
    80001d58:	6442                	ld	s0,16(sp)
    80001d5a:	64a2                	ld	s1,8(sp)
    80001d5c:	6105                	addi	sp,sp,32
    80001d5e:	8082                	ret
    acquire(&tickslock);
    80001d60:	0000c497          	auipc	s1,0xc
    80001d64:	d9048493          	addi	s1,s1,-624 # 8000daf0 <tickslock>
    80001d68:	8526                	mv	a0,s1
    80001d6a:	4c9030ef          	jal	ra,80005a32 <acquire>
    ticks++;
    80001d6e:	00006517          	auipc	a0,0x6
    80001d72:	d1a50513          	addi	a0,a0,-742 # 80007a88 <ticks>
    80001d76:	411c                	lw	a5,0(a0)
    80001d78:	2785                	addiw	a5,a5,1
    80001d7a:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001d7c:	a39ff0ef          	jal	ra,800017b4 <wakeup>
    release(&tickslock);
    80001d80:	8526                	mv	a0,s1
    80001d82:	549030ef          	jal	ra,80005aca <release>
    80001d86:	bf7d                	j	80001d44 <clockintr+0x10>

0000000080001d88 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001d88:	1101                	addi	sp,sp,-32
    80001d8a:	ec06                	sd	ra,24(sp)
    80001d8c:	e822                	sd	s0,16(sp)
    80001d8e:	e426                	sd	s1,8(sp)
    80001d90:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d92:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001d96:	57fd                	li	a5,-1
    80001d98:	17fe                	slli	a5,a5,0x3f
    80001d9a:	07a5                	addi	a5,a5,9
    80001d9c:	00f70d63          	beq	a4,a5,80001db6 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001da0:	57fd                	li	a5,-1
    80001da2:	17fe                	slli	a5,a5,0x3f
    80001da4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001da6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001da8:	04f70463          	beq	a4,a5,80001df0 <devintr+0x68>
  }
}
    80001dac:	60e2                	ld	ra,24(sp)
    80001dae:	6442                	ld	s0,16(sp)
    80001db0:	64a2                	ld	s1,8(sp)
    80001db2:	6105                	addi	sp,sp,32
    80001db4:	8082                	ret
    int irq = plic_claim();
    80001db6:	503020ef          	jal	ra,80004ab8 <plic_claim>
    80001dba:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001dbc:	47a9                	li	a5,10
    80001dbe:	02f50363          	beq	a0,a5,80001de4 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80001dc2:	4785                	li	a5,1
    80001dc4:	02f50363          	beq	a0,a5,80001dea <devintr+0x62>
    return 1;
    80001dc8:	4505                	li	a0,1
    } else if(irq){
    80001dca:	d0ed                	beqz	s1,80001dac <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80001dcc:	85a6                	mv	a1,s1
    80001dce:	00005517          	auipc	a0,0x5
    80001dd2:	60a50513          	addi	a0,a0,1546 # 800073d8 <states.0+0x38>
    80001dd6:	698030ef          	jal	ra,8000546e <printf>
      plic_complete(irq);
    80001dda:	8526                	mv	a0,s1
    80001ddc:	4fd020ef          	jal	ra,80004ad8 <plic_complete>
    return 1;
    80001de0:	4505                	li	a0,1
    80001de2:	b7e9                	j	80001dac <devintr+0x24>
      uartintr();
    80001de4:	393030ef          	jal	ra,80005976 <uartintr>
    80001de8:	bfcd                	j	80001dda <devintr+0x52>
      virtio_disk_intr();
    80001dea:	15a030ef          	jal	ra,80004f44 <virtio_disk_intr>
    80001dee:	b7f5                	j	80001dda <devintr+0x52>
    clockintr();
    80001df0:	f45ff0ef          	jal	ra,80001d34 <clockintr>
    return 2;
    80001df4:	4509                	li	a0,2
    80001df6:	bf5d                	j	80001dac <devintr+0x24>

0000000080001df8 <usertrap>:
{
    80001df8:	1101                	addi	sp,sp,-32
    80001dfa:	ec06                	sd	ra,24(sp)
    80001dfc:	e822                	sd	s0,16(sp)
    80001dfe:	e426                	sd	s1,8(sp)
    80001e00:	e04a                	sd	s2,0(sp)
    80001e02:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e04:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001e08:	1007f793          	andi	a5,a5,256
    80001e0c:	ef85                	bnez	a5,80001e44 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001e0e:	00003797          	auipc	a5,0x3
    80001e12:	c0278793          	addi	a5,a5,-1022 # 80004a10 <kernelvec>
    80001e16:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001e1a:	b82ff0ef          	jal	ra,8000119c <myproc>
    80001e1e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001e20:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e22:	14102773          	csrr	a4,sepc
    80001e26:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e28:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001e2c:	47a1                	li	a5,8
    80001e2e:	02f70163          	beq	a4,a5,80001e50 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001e32:	f57ff0ef          	jal	ra,80001d88 <devintr>
    80001e36:	892a                	mv	s2,a0
    80001e38:	c135                	beqz	a0,80001e9c <usertrap+0xa4>
  if(killed(p))
    80001e3a:	8526                	mv	a0,s1
    80001e3c:	b65ff0ef          	jal	ra,800019a0 <killed>
    80001e40:	cd1d                	beqz	a0,80001e7e <usertrap+0x86>
    80001e42:	a81d                	j	80001e78 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001e44:	00005517          	auipc	a0,0x5
    80001e48:	5b450513          	addi	a0,a0,1460 # 800073f8 <states.0+0x58>
    80001e4c:	0d7030ef          	jal	ra,80005722 <panic>
    if(killed(p))
    80001e50:	b51ff0ef          	jal	ra,800019a0 <killed>
    80001e54:	e121                	bnez	a0,80001e94 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001e56:	6cb8                	ld	a4,88(s1)
    80001e58:	6f1c                	ld	a5,24(a4)
    80001e5a:	0791                	addi	a5,a5,4
    80001e5c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e5e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e62:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e66:	10079073          	csrw	sstatus,a5
    syscall();
    80001e6a:	248000ef          	jal	ra,800020b2 <syscall>
  if(killed(p))
    80001e6e:	8526                	mv	a0,s1
    80001e70:	b31ff0ef          	jal	ra,800019a0 <killed>
    80001e74:	c901                	beqz	a0,80001e84 <usertrap+0x8c>
    80001e76:	4901                	li	s2,0
    exit(-1);
    80001e78:	557d                	li	a0,-1
    80001e7a:	9fbff0ef          	jal	ra,80001874 <exit>
  if(which_dev == 2)
    80001e7e:	4789                	li	a5,2
    80001e80:	04f90563          	beq	s2,a5,80001eca <usertrap+0xd2>
  usertrapret();
    80001e84:	e1fff0ef          	jal	ra,80001ca2 <usertrapret>
}
    80001e88:	60e2                	ld	ra,24(sp)
    80001e8a:	6442                	ld	s0,16(sp)
    80001e8c:	64a2                	ld	s1,8(sp)
    80001e8e:	6902                	ld	s2,0(sp)
    80001e90:	6105                	addi	sp,sp,32
    80001e92:	8082                	ret
      exit(-1);
    80001e94:	557d                	li	a0,-1
    80001e96:	9dfff0ef          	jal	ra,80001874 <exit>
    80001e9a:	bf75                	j	80001e56 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e9c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001ea0:	5890                	lw	a2,48(s1)
    80001ea2:	00005517          	auipc	a0,0x5
    80001ea6:	57650513          	addi	a0,a0,1398 # 80007418 <states.0+0x78>
    80001eaa:	5c4030ef          	jal	ra,8000546e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001eae:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001eb2:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001eb6:	00005517          	auipc	a0,0x5
    80001eba:	59250513          	addi	a0,a0,1426 # 80007448 <states.0+0xa8>
    80001ebe:	5b0030ef          	jal	ra,8000546e <printf>
    setkilled(p);
    80001ec2:	8526                	mv	a0,s1
    80001ec4:	ab9ff0ef          	jal	ra,8000197c <setkilled>
    80001ec8:	b75d                	j	80001e6e <usertrap+0x76>
    yield();
    80001eca:	873ff0ef          	jal	ra,8000173c <yield>
    80001ece:	bf5d                	j	80001e84 <usertrap+0x8c>

0000000080001ed0 <kerneltrap>:
{
    80001ed0:	7179                	addi	sp,sp,-48
    80001ed2:	f406                	sd	ra,40(sp)
    80001ed4:	f022                	sd	s0,32(sp)
    80001ed6:	ec26                	sd	s1,24(sp)
    80001ed8:	e84a                	sd	s2,16(sp)
    80001eda:	e44e                	sd	s3,8(sp)
    80001edc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001ede:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ee2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001ee6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001eea:	1004f793          	andi	a5,s1,256
    80001eee:	c795                	beqz	a5,80001f1a <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ef0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ef4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001ef6:	eb85                	bnez	a5,80001f26 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001ef8:	e91ff0ef          	jal	ra,80001d88 <devintr>
    80001efc:	c91d                	beqz	a0,80001f32 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001efe:	4789                	li	a5,2
    80001f00:	04f50a63          	beq	a0,a5,80001f54 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001f04:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f08:	10049073          	csrw	sstatus,s1
}
    80001f0c:	70a2                	ld	ra,40(sp)
    80001f0e:	7402                	ld	s0,32(sp)
    80001f10:	64e2                	ld	s1,24(sp)
    80001f12:	6942                	ld	s2,16(sp)
    80001f14:	69a2                	ld	s3,8(sp)
    80001f16:	6145                	addi	sp,sp,48
    80001f18:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001f1a:	00005517          	auipc	a0,0x5
    80001f1e:	55650513          	addi	a0,a0,1366 # 80007470 <states.0+0xd0>
    80001f22:	001030ef          	jal	ra,80005722 <panic>
    panic("kerneltrap: interrupts enabled");
    80001f26:	00005517          	auipc	a0,0x5
    80001f2a:	57250513          	addi	a0,a0,1394 # 80007498 <states.0+0xf8>
    80001f2e:	7f4030ef          	jal	ra,80005722 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001f32:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001f36:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001f3a:	85ce                	mv	a1,s3
    80001f3c:	00005517          	auipc	a0,0x5
    80001f40:	57c50513          	addi	a0,a0,1404 # 800074b8 <states.0+0x118>
    80001f44:	52a030ef          	jal	ra,8000546e <printf>
    panic("kerneltrap");
    80001f48:	00005517          	auipc	a0,0x5
    80001f4c:	59850513          	addi	a0,a0,1432 # 800074e0 <states.0+0x140>
    80001f50:	7d2030ef          	jal	ra,80005722 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001f54:	a48ff0ef          	jal	ra,8000119c <myproc>
    80001f58:	d555                	beqz	a0,80001f04 <kerneltrap+0x34>
    yield();
    80001f5a:	fe2ff0ef          	jal	ra,8000173c <yield>
    80001f5e:	b75d                	j	80001f04 <kerneltrap+0x34>

0000000080001f60 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001f60:	1101                	addi	sp,sp,-32
    80001f62:	ec06                	sd	ra,24(sp)
    80001f64:	e822                	sd	s0,16(sp)
    80001f66:	e426                	sd	s1,8(sp)
    80001f68:	1000                	addi	s0,sp,32
    80001f6a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f6c:	a30ff0ef          	jal	ra,8000119c <myproc>
  switch (n) {
    80001f70:	4795                	li	a5,5
    80001f72:	0497e163          	bltu	a5,s1,80001fb4 <argraw+0x54>
    80001f76:	048a                	slli	s1,s1,0x2
    80001f78:	00005717          	auipc	a4,0x5
    80001f7c:	5a070713          	addi	a4,a4,1440 # 80007518 <states.0+0x178>
    80001f80:	94ba                	add	s1,s1,a4
    80001f82:	409c                	lw	a5,0(s1)
    80001f84:	97ba                	add	a5,a5,a4
    80001f86:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001f88:	6d3c                	ld	a5,88(a0)
    80001f8a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001f8c:	60e2                	ld	ra,24(sp)
    80001f8e:	6442                	ld	s0,16(sp)
    80001f90:	64a2                	ld	s1,8(sp)
    80001f92:	6105                	addi	sp,sp,32
    80001f94:	8082                	ret
    return p->trapframe->a1;
    80001f96:	6d3c                	ld	a5,88(a0)
    80001f98:	7fa8                	ld	a0,120(a5)
    80001f9a:	bfcd                	j	80001f8c <argraw+0x2c>
    return p->trapframe->a2;
    80001f9c:	6d3c                	ld	a5,88(a0)
    80001f9e:	63c8                	ld	a0,128(a5)
    80001fa0:	b7f5                	j	80001f8c <argraw+0x2c>
    return p->trapframe->a3;
    80001fa2:	6d3c                	ld	a5,88(a0)
    80001fa4:	67c8                	ld	a0,136(a5)
    80001fa6:	b7dd                	j	80001f8c <argraw+0x2c>
    return p->trapframe->a4;
    80001fa8:	6d3c                	ld	a5,88(a0)
    80001faa:	6bc8                	ld	a0,144(a5)
    80001fac:	b7c5                	j	80001f8c <argraw+0x2c>
    return p->trapframe->a5;
    80001fae:	6d3c                	ld	a5,88(a0)
    80001fb0:	6fc8                	ld	a0,152(a5)
    80001fb2:	bfe9                	j	80001f8c <argraw+0x2c>
  panic("argraw");
    80001fb4:	00005517          	auipc	a0,0x5
    80001fb8:	53c50513          	addi	a0,a0,1340 # 800074f0 <states.0+0x150>
    80001fbc:	766030ef          	jal	ra,80005722 <panic>

0000000080001fc0 <fetchaddr>:
{
    80001fc0:	1101                	addi	sp,sp,-32
    80001fc2:	ec06                	sd	ra,24(sp)
    80001fc4:	e822                	sd	s0,16(sp)
    80001fc6:	e426                	sd	s1,8(sp)
    80001fc8:	e04a                	sd	s2,0(sp)
    80001fca:	1000                	addi	s0,sp,32
    80001fcc:	84aa                	mv	s1,a0
    80001fce:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001fd0:	9ccff0ef          	jal	ra,8000119c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001fd4:	653c                	ld	a5,72(a0)
    80001fd6:	02f4f663          	bgeu	s1,a5,80002002 <fetchaddr+0x42>
    80001fda:	00848713          	addi	a4,s1,8
    80001fde:	02e7e463          	bltu	a5,a4,80002006 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001fe2:	46a1                	li	a3,8
    80001fe4:	8626                	mv	a2,s1
    80001fe6:	85ca                	mv	a1,s2
    80001fe8:	6928                	ld	a0,80(a0)
    80001fea:	e0ffe0ef          	jal	ra,80000df8 <copyin>
    80001fee:	00a03533          	snez	a0,a0
    80001ff2:	40a00533          	neg	a0,a0
}
    80001ff6:	60e2                	ld	ra,24(sp)
    80001ff8:	6442                	ld	s0,16(sp)
    80001ffa:	64a2                	ld	s1,8(sp)
    80001ffc:	6902                	ld	s2,0(sp)
    80001ffe:	6105                	addi	sp,sp,32
    80002000:	8082                	ret
    return -1;
    80002002:	557d                	li	a0,-1
    80002004:	bfcd                	j	80001ff6 <fetchaddr+0x36>
    80002006:	557d                	li	a0,-1
    80002008:	b7fd                	j	80001ff6 <fetchaddr+0x36>

000000008000200a <fetchstr>:
{
    8000200a:	7179                	addi	sp,sp,-48
    8000200c:	f406                	sd	ra,40(sp)
    8000200e:	f022                	sd	s0,32(sp)
    80002010:	ec26                	sd	s1,24(sp)
    80002012:	e84a                	sd	s2,16(sp)
    80002014:	e44e                	sd	s3,8(sp)
    80002016:	1800                	addi	s0,sp,48
    80002018:	892a                	mv	s2,a0
    8000201a:	84ae                	mv	s1,a1
    8000201c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000201e:	97eff0ef          	jal	ra,8000119c <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002022:	86ce                	mv	a3,s3
    80002024:	864a                	mv	a2,s2
    80002026:	85a6                	mv	a1,s1
    80002028:	6928                	ld	a0,80(a0)
    8000202a:	e55fe0ef          	jal	ra,80000e7e <copyinstr>
    8000202e:	00054c63          	bltz	a0,80002046 <fetchstr+0x3c>
  return strlen(buf);
    80002032:	8526                	mv	a0,s1
    80002034:	bf6fe0ef          	jal	ra,8000042a <strlen>
}
    80002038:	70a2                	ld	ra,40(sp)
    8000203a:	7402                	ld	s0,32(sp)
    8000203c:	64e2                	ld	s1,24(sp)
    8000203e:	6942                	ld	s2,16(sp)
    80002040:	69a2                	ld	s3,8(sp)
    80002042:	6145                	addi	sp,sp,48
    80002044:	8082                	ret
    return -1;
    80002046:	557d                	li	a0,-1
    80002048:	bfc5                	j	80002038 <fetchstr+0x2e>

000000008000204a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000204a:	1101                	addi	sp,sp,-32
    8000204c:	ec06                	sd	ra,24(sp)
    8000204e:	e822                	sd	s0,16(sp)
    80002050:	e426                	sd	s1,8(sp)
    80002052:	1000                	addi	s0,sp,32
    80002054:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002056:	f0bff0ef          	jal	ra,80001f60 <argraw>
    8000205a:	c088                	sw	a0,0(s1)
}
    8000205c:	60e2                	ld	ra,24(sp)
    8000205e:	6442                	ld	s0,16(sp)
    80002060:	64a2                	ld	s1,8(sp)
    80002062:	6105                	addi	sp,sp,32
    80002064:	8082                	ret

0000000080002066 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002066:	1101                	addi	sp,sp,-32
    80002068:	ec06                	sd	ra,24(sp)
    8000206a:	e822                	sd	s0,16(sp)
    8000206c:	e426                	sd	s1,8(sp)
    8000206e:	1000                	addi	s0,sp,32
    80002070:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002072:	eefff0ef          	jal	ra,80001f60 <argraw>
    80002076:	e088                	sd	a0,0(s1)
}
    80002078:	60e2                	ld	ra,24(sp)
    8000207a:	6442                	ld	s0,16(sp)
    8000207c:	64a2                	ld	s1,8(sp)
    8000207e:	6105                	addi	sp,sp,32
    80002080:	8082                	ret

0000000080002082 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002082:	7179                	addi	sp,sp,-48
    80002084:	f406                	sd	ra,40(sp)
    80002086:	f022                	sd	s0,32(sp)
    80002088:	ec26                	sd	s1,24(sp)
    8000208a:	e84a                	sd	s2,16(sp)
    8000208c:	1800                	addi	s0,sp,48
    8000208e:	84ae                	mv	s1,a1
    80002090:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002092:	fd840593          	addi	a1,s0,-40
    80002096:	fd1ff0ef          	jal	ra,80002066 <argaddr>
  return fetchstr(addr, buf, max);
    8000209a:	864a                	mv	a2,s2
    8000209c:	85a6                	mv	a1,s1
    8000209e:	fd843503          	ld	a0,-40(s0)
    800020a2:	f69ff0ef          	jal	ra,8000200a <fetchstr>
}
    800020a6:	70a2                	ld	ra,40(sp)
    800020a8:	7402                	ld	s0,32(sp)
    800020aa:	64e2                	ld	s1,24(sp)
    800020ac:	6942                	ld	s2,16(sp)
    800020ae:	6145                	addi	sp,sp,48
    800020b0:	8082                	ret

00000000800020b2 <syscall>:
#endif
};

void
syscall(void)
{
    800020b2:	1101                	addi	sp,sp,-32
    800020b4:	ec06                	sd	ra,24(sp)
    800020b6:	e822                	sd	s0,16(sp)
    800020b8:	e426                	sd	s1,8(sp)
    800020ba:	e04a                	sd	s2,0(sp)
    800020bc:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800020be:	8deff0ef          	jal	ra,8000119c <myproc>
    800020c2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800020c4:	05853903          	ld	s2,88(a0)
    800020c8:	0a893783          	ld	a5,168(s2)
    800020cc:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800020d0:	37fd                	addiw	a5,a5,-1
    800020d2:	02100713          	li	a4,33
    800020d6:	00f76f63          	bltu	a4,a5,800020f4 <syscall+0x42>
    800020da:	00369713          	slli	a4,a3,0x3
    800020de:	00005797          	auipc	a5,0x5
    800020e2:	45278793          	addi	a5,a5,1106 # 80007530 <syscalls>
    800020e6:	97ba                	add	a5,a5,a4
    800020e8:	639c                	ld	a5,0(a5)
    800020ea:	c789                	beqz	a5,800020f4 <syscall+0x42>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800020ec:	9782                	jalr	a5
    800020ee:	06a93823          	sd	a0,112(s2)
    800020f2:	a829                	j	8000210c <syscall+0x5a>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800020f4:	15848613          	addi	a2,s1,344
    800020f8:	588c                	lw	a1,48(s1)
    800020fa:	00005517          	auipc	a0,0x5
    800020fe:	3fe50513          	addi	a0,a0,1022 # 800074f8 <states.0+0x158>
    80002102:	36c030ef          	jal	ra,8000546e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002106:	6cbc                	ld	a5,88(s1)
    80002108:	577d                	li	a4,-1
    8000210a:	fbb8                	sd	a4,112(a5)
  }
}
    8000210c:	60e2                	ld	ra,24(sp)
    8000210e:	6442                	ld	s0,16(sp)
    80002110:	64a2                	ld	s1,8(sp)
    80002112:	6902                	ld	s2,0(sp)
    80002114:	6105                	addi	sp,sp,32
    80002116:	8082                	ret

0000000080002118 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002118:	1101                	addi	sp,sp,-32
    8000211a:	ec06                	sd	ra,24(sp)
    8000211c:	e822                	sd	s0,16(sp)
    8000211e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002120:	fec40593          	addi	a1,s0,-20
    80002124:	4501                	li	a0,0
    80002126:	f25ff0ef          	jal	ra,8000204a <argint>
  exit(n);
    8000212a:	fec42503          	lw	a0,-20(s0)
    8000212e:	f46ff0ef          	jal	ra,80001874 <exit>
  return 0;  // not reached
}
    80002132:	4501                	li	a0,0
    80002134:	60e2                	ld	ra,24(sp)
    80002136:	6442                	ld	s0,16(sp)
    80002138:	6105                	addi	sp,sp,32
    8000213a:	8082                	ret

000000008000213c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000213c:	1141                	addi	sp,sp,-16
    8000213e:	e406                	sd	ra,8(sp)
    80002140:	e022                	sd	s0,0(sp)
    80002142:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002144:	858ff0ef          	jal	ra,8000119c <myproc>
}
    80002148:	5908                	lw	a0,48(a0)
    8000214a:	60a2                	ld	ra,8(sp)
    8000214c:	6402                	ld	s0,0(sp)
    8000214e:	0141                	addi	sp,sp,16
    80002150:	8082                	ret

0000000080002152 <sys_fork>:

uint64
sys_fork(void)
{
    80002152:	1141                	addi	sp,sp,-16
    80002154:	e406                	sd	ra,8(sp)
    80002156:	e022                	sd	s0,0(sp)
    80002158:	0800                	addi	s0,sp,16
  return fork();
    8000215a:	b68ff0ef          	jal	ra,800014c2 <fork>
}
    8000215e:	60a2                	ld	ra,8(sp)
    80002160:	6402                	ld	s0,0(sp)
    80002162:	0141                	addi	sp,sp,16
    80002164:	8082                	ret

0000000080002166 <sys_wait>:

uint64
sys_wait(void)
{
    80002166:	1101                	addi	sp,sp,-32
    80002168:	ec06                	sd	ra,24(sp)
    8000216a:	e822                	sd	s0,16(sp)
    8000216c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000216e:	fe840593          	addi	a1,s0,-24
    80002172:	4501                	li	a0,0
    80002174:	ef3ff0ef          	jal	ra,80002066 <argaddr>
  return wait(p);
    80002178:	fe843503          	ld	a0,-24(s0)
    8000217c:	84fff0ef          	jal	ra,800019ca <wait>
}
    80002180:	60e2                	ld	ra,24(sp)
    80002182:	6442                	ld	s0,16(sp)
    80002184:	6105                	addi	sp,sp,32
    80002186:	8082                	ret

0000000080002188 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002188:	7179                	addi	sp,sp,-48
    8000218a:	f406                	sd	ra,40(sp)
    8000218c:	f022                	sd	s0,32(sp)
    8000218e:	ec26                	sd	s1,24(sp)
    80002190:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002192:	fdc40593          	addi	a1,s0,-36
    80002196:	4501                	li	a0,0
    80002198:	eb3ff0ef          	jal	ra,8000204a <argint>
  addr = myproc()->sz;
    8000219c:	800ff0ef          	jal	ra,8000119c <myproc>
    800021a0:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800021a2:	fdc42503          	lw	a0,-36(s0)
    800021a6:	accff0ef          	jal	ra,80001472 <growproc>
    800021aa:	00054863          	bltz	a0,800021ba <sys_sbrk+0x32>
    return -1;
  return addr;
}
    800021ae:	8526                	mv	a0,s1
    800021b0:	70a2                	ld	ra,40(sp)
    800021b2:	7402                	ld	s0,32(sp)
    800021b4:	64e2                	ld	s1,24(sp)
    800021b6:	6145                	addi	sp,sp,48
    800021b8:	8082                	ret
    return -1;
    800021ba:	54fd                	li	s1,-1
    800021bc:	bfcd                	j	800021ae <sys_sbrk+0x26>

00000000800021be <sys_sleep>:

uint64
sys_sleep(void)
{
    800021be:	7139                	addi	sp,sp,-64
    800021c0:	fc06                	sd	ra,56(sp)
    800021c2:	f822                	sd	s0,48(sp)
    800021c4:	f426                	sd	s1,40(sp)
    800021c6:	f04a                	sd	s2,32(sp)
    800021c8:	ec4e                	sd	s3,24(sp)
    800021ca:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800021cc:	fcc40593          	addi	a1,s0,-52
    800021d0:	4501                	li	a0,0
    800021d2:	e79ff0ef          	jal	ra,8000204a <argint>
  if(n < 0)
    800021d6:	fcc42783          	lw	a5,-52(s0)
    800021da:	0607c563          	bltz	a5,80002244 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    800021de:	0000c517          	auipc	a0,0xc
    800021e2:	91250513          	addi	a0,a0,-1774 # 8000daf0 <tickslock>
    800021e6:	04d030ef          	jal	ra,80005a32 <acquire>
  ticks0 = ticks;
    800021ea:	00006917          	auipc	s2,0x6
    800021ee:	89e92903          	lw	s2,-1890(s2) # 80007a88 <ticks>
  while(ticks - ticks0 < n){
    800021f2:	fcc42783          	lw	a5,-52(s0)
    800021f6:	cb8d                	beqz	a5,80002228 <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800021f8:	0000c997          	auipc	s3,0xc
    800021fc:	8f898993          	addi	s3,s3,-1800 # 8000daf0 <tickslock>
    80002200:	00006497          	auipc	s1,0x6
    80002204:	88848493          	addi	s1,s1,-1912 # 80007a88 <ticks>
    if(killed(myproc())){
    80002208:	f95fe0ef          	jal	ra,8000119c <myproc>
    8000220c:	f94ff0ef          	jal	ra,800019a0 <killed>
    80002210:	ed0d                	bnez	a0,8000224a <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002212:	85ce                	mv	a1,s3
    80002214:	8526                	mv	a0,s1
    80002216:	d52ff0ef          	jal	ra,80001768 <sleep>
  while(ticks - ticks0 < n){
    8000221a:	409c                	lw	a5,0(s1)
    8000221c:	412787bb          	subw	a5,a5,s2
    80002220:	fcc42703          	lw	a4,-52(s0)
    80002224:	fee7e2e3          	bltu	a5,a4,80002208 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002228:	0000c517          	auipc	a0,0xc
    8000222c:	8c850513          	addi	a0,a0,-1848 # 8000daf0 <tickslock>
    80002230:	09b030ef          	jal	ra,80005aca <release>
  return 0;
    80002234:	4501                	li	a0,0
}
    80002236:	70e2                	ld	ra,56(sp)
    80002238:	7442                	ld	s0,48(sp)
    8000223a:	74a2                	ld	s1,40(sp)
    8000223c:	7902                	ld	s2,32(sp)
    8000223e:	69e2                	ld	s3,24(sp)
    80002240:	6121                	addi	sp,sp,64
    80002242:	8082                	ret
    n = 0;
    80002244:	fc042623          	sw	zero,-52(s0)
    80002248:	bf59                	j	800021de <sys_sleep+0x20>
      release(&tickslock);
    8000224a:	0000c517          	auipc	a0,0xc
    8000224e:	8a650513          	addi	a0,a0,-1882 # 8000daf0 <tickslock>
    80002252:	079030ef          	jal	ra,80005aca <release>
      return -1;
    80002256:	557d                	li	a0,-1
    80002258:	bff9                	j	80002236 <sys_sleep+0x78>

000000008000225a <sys_pgpte>:


#ifdef LAB_PGTBL
int
sys_pgpte(void)
{
    8000225a:	7179                	addi	sp,sp,-48
    8000225c:	f406                	sd	ra,40(sp)
    8000225e:	f022                	sd	s0,32(sp)
    80002260:	ec26                	sd	s1,24(sp)
    80002262:	1800                	addi	s0,sp,48
  uint64 va;
  struct proc *p;

  p = myproc();
    80002264:	f39fe0ef          	jal	ra,8000119c <myproc>
    80002268:	84aa                	mv	s1,a0
  argaddr(0, &va);
    8000226a:	fd840593          	addi	a1,s0,-40
    8000226e:	4501                	li	a0,0
    80002270:	df7ff0ef          	jal	ra,80002066 <argaddr>
  pte_t *pte = pgpte(p->pagetable, va);
    80002274:	fd843583          	ld	a1,-40(s0)
    80002278:	68a8                	ld	a0,80(s1)
    8000227a:	daffe0ef          	jal	ra,80001028 <pgpte>
    8000227e:	87aa                	mv	a5,a0
  if(pte != 0) {
      return (uint64) *pte;
  }
  return 0;
    80002280:	4501                	li	a0,0
  if(pte != 0) {
    80002282:	c391                	beqz	a5,80002286 <sys_pgpte+0x2c>
      return (uint64) *pte;
    80002284:	4388                	lw	a0,0(a5)
}
    80002286:	70a2                	ld	ra,40(sp)
    80002288:	7402                	ld	s0,32(sp)
    8000228a:	64e2                	ld	s1,24(sp)
    8000228c:	6145                	addi	sp,sp,48
    8000228e:	8082                	ret

0000000080002290 <sys_kpgtbl>:
#endif

#ifdef LAB_PGTBL
int
sys_kpgtbl(void)
{
    80002290:	1141                	addi	sp,sp,-16
    80002292:	e406                	sd	ra,8(sp)
    80002294:	e022                	sd	s0,0(sp)
    80002296:	0800                	addi	s0,sp,16
  struct proc *p;

  p = myproc();
    80002298:	f05fe0ef          	jal	ra,8000119c <myproc>
  vmprint(p->pagetable);
    8000229c:	6928                	ld	a0,80(a0)
    8000229e:	d5dfe0ef          	jal	ra,80000ffa <vmprint>
  return 0;
}
    800022a2:	4501                	li	a0,0
    800022a4:	60a2                	ld	ra,8(sp)
    800022a6:	6402                	ld	s0,0(sp)
    800022a8:	0141                	addi	sp,sp,16
    800022aa:	8082                	ret

00000000800022ac <sys_kill>:
#endif


uint64
sys_kill(void)
{
    800022ac:	1101                	addi	sp,sp,-32
    800022ae:	ec06                	sd	ra,24(sp)
    800022b0:	e822                	sd	s0,16(sp)
    800022b2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800022b4:	fec40593          	addi	a1,s0,-20
    800022b8:	4501                	li	a0,0
    800022ba:	d91ff0ef          	jal	ra,8000204a <argint>
  return kill(pid);
    800022be:	fec42503          	lw	a0,-20(s0)
    800022c2:	e54ff0ef          	jal	ra,80001916 <kill>
}
    800022c6:	60e2                	ld	ra,24(sp)
    800022c8:	6442                	ld	s0,16(sp)
    800022ca:	6105                	addi	sp,sp,32
    800022cc:	8082                	ret

00000000800022ce <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800022ce:	1101                	addi	sp,sp,-32
    800022d0:	ec06                	sd	ra,24(sp)
    800022d2:	e822                	sd	s0,16(sp)
    800022d4:	e426                	sd	s1,8(sp)
    800022d6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800022d8:	0000c517          	auipc	a0,0xc
    800022dc:	81850513          	addi	a0,a0,-2024 # 8000daf0 <tickslock>
    800022e0:	752030ef          	jal	ra,80005a32 <acquire>
  xticks = ticks;
    800022e4:	00005497          	auipc	s1,0x5
    800022e8:	7a44a483          	lw	s1,1956(s1) # 80007a88 <ticks>
  release(&tickslock);
    800022ec:	0000c517          	auipc	a0,0xc
    800022f0:	80450513          	addi	a0,a0,-2044 # 8000daf0 <tickslock>
    800022f4:	7d6030ef          	jal	ra,80005aca <release>
  return xticks;
}
    800022f8:	02049513          	slli	a0,s1,0x20
    800022fc:	9101                	srli	a0,a0,0x20
    800022fe:	60e2                	ld	ra,24(sp)
    80002300:	6442                	ld	s0,16(sp)
    80002302:	64a2                	ld	s1,8(sp)
    80002304:	6105                	addi	sp,sp,32
    80002306:	8082                	ret

0000000080002308 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002308:	7179                	addi	sp,sp,-48
    8000230a:	f406                	sd	ra,40(sp)
    8000230c:	f022                	sd	s0,32(sp)
    8000230e:	ec26                	sd	s1,24(sp)
    80002310:	e84a                	sd	s2,16(sp)
    80002312:	e44e                	sd	s3,8(sp)
    80002314:	e052                	sd	s4,0(sp)
    80002316:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002318:	00005597          	auipc	a1,0x5
    8000231c:	33058593          	addi	a1,a1,816 # 80007648 <syscalls+0x118>
    80002320:	0000b517          	auipc	a0,0xb
    80002324:	7e850513          	addi	a0,a0,2024 # 8000db08 <bcache>
    80002328:	68a030ef          	jal	ra,800059b2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000232c:	00013797          	auipc	a5,0x13
    80002330:	7dc78793          	addi	a5,a5,2012 # 80015b08 <bcache+0x8000>
    80002334:	00014717          	auipc	a4,0x14
    80002338:	a3c70713          	addi	a4,a4,-1476 # 80015d70 <bcache+0x8268>
    8000233c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002340:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002344:	0000b497          	auipc	s1,0xb
    80002348:	7dc48493          	addi	s1,s1,2012 # 8000db20 <bcache+0x18>
    b->next = bcache.head.next;
    8000234c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000234e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002350:	00005a17          	auipc	s4,0x5
    80002354:	300a0a13          	addi	s4,s4,768 # 80007650 <syscalls+0x120>
    b->next = bcache.head.next;
    80002358:	2b893783          	ld	a5,696(s2)
    8000235c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000235e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002362:	85d2                	mv	a1,s4
    80002364:	01048513          	addi	a0,s1,16
    80002368:	228010ef          	jal	ra,80003590 <initsleeplock>
    bcache.head.next->prev = b;
    8000236c:	2b893783          	ld	a5,696(s2)
    80002370:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002372:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002376:	45848493          	addi	s1,s1,1112
    8000237a:	fd349fe3          	bne	s1,s3,80002358 <binit+0x50>
  }
}
    8000237e:	70a2                	ld	ra,40(sp)
    80002380:	7402                	ld	s0,32(sp)
    80002382:	64e2                	ld	s1,24(sp)
    80002384:	6942                	ld	s2,16(sp)
    80002386:	69a2                	ld	s3,8(sp)
    80002388:	6a02                	ld	s4,0(sp)
    8000238a:	6145                	addi	sp,sp,48
    8000238c:	8082                	ret

000000008000238e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000238e:	7179                	addi	sp,sp,-48
    80002390:	f406                	sd	ra,40(sp)
    80002392:	f022                	sd	s0,32(sp)
    80002394:	ec26                	sd	s1,24(sp)
    80002396:	e84a                	sd	s2,16(sp)
    80002398:	e44e                	sd	s3,8(sp)
    8000239a:	1800                	addi	s0,sp,48
    8000239c:	892a                	mv	s2,a0
    8000239e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800023a0:	0000b517          	auipc	a0,0xb
    800023a4:	76850513          	addi	a0,a0,1896 # 8000db08 <bcache>
    800023a8:	68a030ef          	jal	ra,80005a32 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800023ac:	00014497          	auipc	s1,0x14
    800023b0:	a144b483          	ld	s1,-1516(s1) # 80015dc0 <bcache+0x82b8>
    800023b4:	00014797          	auipc	a5,0x14
    800023b8:	9bc78793          	addi	a5,a5,-1604 # 80015d70 <bcache+0x8268>
    800023bc:	02f48b63          	beq	s1,a5,800023f2 <bread+0x64>
    800023c0:	873e                	mv	a4,a5
    800023c2:	a021                	j	800023ca <bread+0x3c>
    800023c4:	68a4                	ld	s1,80(s1)
    800023c6:	02e48663          	beq	s1,a4,800023f2 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800023ca:	449c                	lw	a5,8(s1)
    800023cc:	ff279ce3          	bne	a5,s2,800023c4 <bread+0x36>
    800023d0:	44dc                	lw	a5,12(s1)
    800023d2:	ff3799e3          	bne	a5,s3,800023c4 <bread+0x36>
      b->refcnt++;
    800023d6:	40bc                	lw	a5,64(s1)
    800023d8:	2785                	addiw	a5,a5,1
    800023da:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800023dc:	0000b517          	auipc	a0,0xb
    800023e0:	72c50513          	addi	a0,a0,1836 # 8000db08 <bcache>
    800023e4:	6e6030ef          	jal	ra,80005aca <release>
      acquiresleep(&b->lock);
    800023e8:	01048513          	addi	a0,s1,16
    800023ec:	1da010ef          	jal	ra,800035c6 <acquiresleep>
      return b;
    800023f0:	a889                	j	80002442 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800023f2:	00014497          	auipc	s1,0x14
    800023f6:	9c64b483          	ld	s1,-1594(s1) # 80015db8 <bcache+0x82b0>
    800023fa:	00014797          	auipc	a5,0x14
    800023fe:	97678793          	addi	a5,a5,-1674 # 80015d70 <bcache+0x8268>
    80002402:	00f48863          	beq	s1,a5,80002412 <bread+0x84>
    80002406:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002408:	40bc                	lw	a5,64(s1)
    8000240a:	cb91                	beqz	a5,8000241e <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000240c:	64a4                	ld	s1,72(s1)
    8000240e:	fee49de3          	bne	s1,a4,80002408 <bread+0x7a>
  panic("bget: no buffers");
    80002412:	00005517          	auipc	a0,0x5
    80002416:	24650513          	addi	a0,a0,582 # 80007658 <syscalls+0x128>
    8000241a:	308030ef          	jal	ra,80005722 <panic>
      b->dev = dev;
    8000241e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002422:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002426:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000242a:	4785                	li	a5,1
    8000242c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000242e:	0000b517          	auipc	a0,0xb
    80002432:	6da50513          	addi	a0,a0,1754 # 8000db08 <bcache>
    80002436:	694030ef          	jal	ra,80005aca <release>
      acquiresleep(&b->lock);
    8000243a:	01048513          	addi	a0,s1,16
    8000243e:	188010ef          	jal	ra,800035c6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002442:	409c                	lw	a5,0(s1)
    80002444:	cb89                	beqz	a5,80002456 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002446:	8526                	mv	a0,s1
    80002448:	70a2                	ld	ra,40(sp)
    8000244a:	7402                	ld	s0,32(sp)
    8000244c:	64e2                	ld	s1,24(sp)
    8000244e:	6942                	ld	s2,16(sp)
    80002450:	69a2                	ld	s3,8(sp)
    80002452:	6145                	addi	sp,sp,48
    80002454:	8082                	ret
    virtio_disk_rw(b, 0);
    80002456:	4581                	li	a1,0
    80002458:	8526                	mv	a0,s1
    8000245a:	0d1020ef          	jal	ra,80004d2a <virtio_disk_rw>
    b->valid = 1;
    8000245e:	4785                	li	a5,1
    80002460:	c09c                	sw	a5,0(s1)
  return b;
    80002462:	b7d5                	j	80002446 <bread+0xb8>

0000000080002464 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002464:	1101                	addi	sp,sp,-32
    80002466:	ec06                	sd	ra,24(sp)
    80002468:	e822                	sd	s0,16(sp)
    8000246a:	e426                	sd	s1,8(sp)
    8000246c:	1000                	addi	s0,sp,32
    8000246e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002470:	0541                	addi	a0,a0,16
    80002472:	1d2010ef          	jal	ra,80003644 <holdingsleep>
    80002476:	c911                	beqz	a0,8000248a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002478:	4585                	li	a1,1
    8000247a:	8526                	mv	a0,s1
    8000247c:	0af020ef          	jal	ra,80004d2a <virtio_disk_rw>
}
    80002480:	60e2                	ld	ra,24(sp)
    80002482:	6442                	ld	s0,16(sp)
    80002484:	64a2                	ld	s1,8(sp)
    80002486:	6105                	addi	sp,sp,32
    80002488:	8082                	ret
    panic("bwrite");
    8000248a:	00005517          	auipc	a0,0x5
    8000248e:	1e650513          	addi	a0,a0,486 # 80007670 <syscalls+0x140>
    80002492:	290030ef          	jal	ra,80005722 <panic>

0000000080002496 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002496:	1101                	addi	sp,sp,-32
    80002498:	ec06                	sd	ra,24(sp)
    8000249a:	e822                	sd	s0,16(sp)
    8000249c:	e426                	sd	s1,8(sp)
    8000249e:	e04a                	sd	s2,0(sp)
    800024a0:	1000                	addi	s0,sp,32
    800024a2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800024a4:	01050913          	addi	s2,a0,16
    800024a8:	854a                	mv	a0,s2
    800024aa:	19a010ef          	jal	ra,80003644 <holdingsleep>
    800024ae:	c13d                	beqz	a0,80002514 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    800024b0:	854a                	mv	a0,s2
    800024b2:	15a010ef          	jal	ra,8000360c <releasesleep>

  acquire(&bcache.lock);
    800024b6:	0000b517          	auipc	a0,0xb
    800024ba:	65250513          	addi	a0,a0,1618 # 8000db08 <bcache>
    800024be:	574030ef          	jal	ra,80005a32 <acquire>
  b->refcnt--;
    800024c2:	40bc                	lw	a5,64(s1)
    800024c4:	37fd                	addiw	a5,a5,-1
    800024c6:	0007871b          	sext.w	a4,a5
    800024ca:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800024cc:	eb05                	bnez	a4,800024fc <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800024ce:	68bc                	ld	a5,80(s1)
    800024d0:	64b8                	ld	a4,72(s1)
    800024d2:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800024d4:	64bc                	ld	a5,72(s1)
    800024d6:	68b8                	ld	a4,80(s1)
    800024d8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800024da:	00013797          	auipc	a5,0x13
    800024de:	62e78793          	addi	a5,a5,1582 # 80015b08 <bcache+0x8000>
    800024e2:	2b87b703          	ld	a4,696(a5)
    800024e6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800024e8:	00014717          	auipc	a4,0x14
    800024ec:	88870713          	addi	a4,a4,-1912 # 80015d70 <bcache+0x8268>
    800024f0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800024f2:	2b87b703          	ld	a4,696(a5)
    800024f6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800024f8:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    800024fc:	0000b517          	auipc	a0,0xb
    80002500:	60c50513          	addi	a0,a0,1548 # 8000db08 <bcache>
    80002504:	5c6030ef          	jal	ra,80005aca <release>
}
    80002508:	60e2                	ld	ra,24(sp)
    8000250a:	6442                	ld	s0,16(sp)
    8000250c:	64a2                	ld	s1,8(sp)
    8000250e:	6902                	ld	s2,0(sp)
    80002510:	6105                	addi	sp,sp,32
    80002512:	8082                	ret
    panic("brelse");
    80002514:	00005517          	auipc	a0,0x5
    80002518:	16450513          	addi	a0,a0,356 # 80007678 <syscalls+0x148>
    8000251c:	206030ef          	jal	ra,80005722 <panic>

0000000080002520 <bpin>:

void
bpin(struct buf *b) {
    80002520:	1101                	addi	sp,sp,-32
    80002522:	ec06                	sd	ra,24(sp)
    80002524:	e822                	sd	s0,16(sp)
    80002526:	e426                	sd	s1,8(sp)
    80002528:	1000                	addi	s0,sp,32
    8000252a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000252c:	0000b517          	auipc	a0,0xb
    80002530:	5dc50513          	addi	a0,a0,1500 # 8000db08 <bcache>
    80002534:	4fe030ef          	jal	ra,80005a32 <acquire>
  b->refcnt++;
    80002538:	40bc                	lw	a5,64(s1)
    8000253a:	2785                	addiw	a5,a5,1
    8000253c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000253e:	0000b517          	auipc	a0,0xb
    80002542:	5ca50513          	addi	a0,a0,1482 # 8000db08 <bcache>
    80002546:	584030ef          	jal	ra,80005aca <release>
}
    8000254a:	60e2                	ld	ra,24(sp)
    8000254c:	6442                	ld	s0,16(sp)
    8000254e:	64a2                	ld	s1,8(sp)
    80002550:	6105                	addi	sp,sp,32
    80002552:	8082                	ret

0000000080002554 <bunpin>:

void
bunpin(struct buf *b) {
    80002554:	1101                	addi	sp,sp,-32
    80002556:	ec06                	sd	ra,24(sp)
    80002558:	e822                	sd	s0,16(sp)
    8000255a:	e426                	sd	s1,8(sp)
    8000255c:	1000                	addi	s0,sp,32
    8000255e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002560:	0000b517          	auipc	a0,0xb
    80002564:	5a850513          	addi	a0,a0,1448 # 8000db08 <bcache>
    80002568:	4ca030ef          	jal	ra,80005a32 <acquire>
  b->refcnt--;
    8000256c:	40bc                	lw	a5,64(s1)
    8000256e:	37fd                	addiw	a5,a5,-1
    80002570:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002572:	0000b517          	auipc	a0,0xb
    80002576:	59650513          	addi	a0,a0,1430 # 8000db08 <bcache>
    8000257a:	550030ef          	jal	ra,80005aca <release>
}
    8000257e:	60e2                	ld	ra,24(sp)
    80002580:	6442                	ld	s0,16(sp)
    80002582:	64a2                	ld	s1,8(sp)
    80002584:	6105                	addi	sp,sp,32
    80002586:	8082                	ret

0000000080002588 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002588:	1101                	addi	sp,sp,-32
    8000258a:	ec06                	sd	ra,24(sp)
    8000258c:	e822                	sd	s0,16(sp)
    8000258e:	e426                	sd	s1,8(sp)
    80002590:	e04a                	sd	s2,0(sp)
    80002592:	1000                	addi	s0,sp,32
    80002594:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002596:	00d5d59b          	srliw	a1,a1,0xd
    8000259a:	00014797          	auipc	a5,0x14
    8000259e:	c4a7a783          	lw	a5,-950(a5) # 800161e4 <sb+0x1c>
    800025a2:	9dbd                	addw	a1,a1,a5
    800025a4:	debff0ef          	jal	ra,8000238e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800025a8:	0074f713          	andi	a4,s1,7
    800025ac:	4785                	li	a5,1
    800025ae:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800025b2:	14ce                	slli	s1,s1,0x33
    800025b4:	90d9                	srli	s1,s1,0x36
    800025b6:	00950733          	add	a4,a0,s1
    800025ba:	05874703          	lbu	a4,88(a4)
    800025be:	00e7f6b3          	and	a3,a5,a4
    800025c2:	c29d                	beqz	a3,800025e8 <bfree+0x60>
    800025c4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800025c6:	94aa                	add	s1,s1,a0
    800025c8:	fff7c793          	not	a5,a5
    800025cc:	8f7d                	and	a4,a4,a5
    800025ce:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800025d2:	6ef000ef          	jal	ra,800034c0 <log_write>
  brelse(bp);
    800025d6:	854a                	mv	a0,s2
    800025d8:	ebfff0ef          	jal	ra,80002496 <brelse>
}
    800025dc:	60e2                	ld	ra,24(sp)
    800025de:	6442                	ld	s0,16(sp)
    800025e0:	64a2                	ld	s1,8(sp)
    800025e2:	6902                	ld	s2,0(sp)
    800025e4:	6105                	addi	sp,sp,32
    800025e6:	8082                	ret
    panic("freeing free block");
    800025e8:	00005517          	auipc	a0,0x5
    800025ec:	09850513          	addi	a0,a0,152 # 80007680 <syscalls+0x150>
    800025f0:	132030ef          	jal	ra,80005722 <panic>

00000000800025f4 <balloc>:
{
    800025f4:	711d                	addi	sp,sp,-96
    800025f6:	ec86                	sd	ra,88(sp)
    800025f8:	e8a2                	sd	s0,80(sp)
    800025fa:	e4a6                	sd	s1,72(sp)
    800025fc:	e0ca                	sd	s2,64(sp)
    800025fe:	fc4e                	sd	s3,56(sp)
    80002600:	f852                	sd	s4,48(sp)
    80002602:	f456                	sd	s5,40(sp)
    80002604:	f05a                	sd	s6,32(sp)
    80002606:	ec5e                	sd	s7,24(sp)
    80002608:	e862                	sd	s8,16(sp)
    8000260a:	e466                	sd	s9,8(sp)
    8000260c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000260e:	00014797          	auipc	a5,0x14
    80002612:	bbe7a783          	lw	a5,-1090(a5) # 800161cc <sb+0x4>
    80002616:	cff1                	beqz	a5,800026f2 <balloc+0xfe>
    80002618:	8baa                	mv	s7,a0
    8000261a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000261c:	00014b17          	auipc	s6,0x14
    80002620:	bacb0b13          	addi	s6,s6,-1108 # 800161c8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002624:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002626:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002628:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000262a:	6c89                	lui	s9,0x2
    8000262c:	a0b5                	j	80002698 <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000262e:	97ca                	add	a5,a5,s2
    80002630:	8e55                	or	a2,a2,a3
    80002632:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002636:	854a                	mv	a0,s2
    80002638:	689000ef          	jal	ra,800034c0 <log_write>
        brelse(bp);
    8000263c:	854a                	mv	a0,s2
    8000263e:	e59ff0ef          	jal	ra,80002496 <brelse>
  bp = bread(dev, bno);
    80002642:	85a6                	mv	a1,s1
    80002644:	855e                	mv	a0,s7
    80002646:	d49ff0ef          	jal	ra,8000238e <bread>
    8000264a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000264c:	40000613          	li	a2,1024
    80002650:	4581                	li	a1,0
    80002652:	05850513          	addi	a0,a0,88
    80002656:	c5dfd0ef          	jal	ra,800002b2 <memset>
  log_write(bp);
    8000265a:	854a                	mv	a0,s2
    8000265c:	665000ef          	jal	ra,800034c0 <log_write>
  brelse(bp);
    80002660:	854a                	mv	a0,s2
    80002662:	e35ff0ef          	jal	ra,80002496 <brelse>
}
    80002666:	8526                	mv	a0,s1
    80002668:	60e6                	ld	ra,88(sp)
    8000266a:	6446                	ld	s0,80(sp)
    8000266c:	64a6                	ld	s1,72(sp)
    8000266e:	6906                	ld	s2,64(sp)
    80002670:	79e2                	ld	s3,56(sp)
    80002672:	7a42                	ld	s4,48(sp)
    80002674:	7aa2                	ld	s5,40(sp)
    80002676:	7b02                	ld	s6,32(sp)
    80002678:	6be2                	ld	s7,24(sp)
    8000267a:	6c42                	ld	s8,16(sp)
    8000267c:	6ca2                	ld	s9,8(sp)
    8000267e:	6125                	addi	sp,sp,96
    80002680:	8082                	ret
    brelse(bp);
    80002682:	854a                	mv	a0,s2
    80002684:	e13ff0ef          	jal	ra,80002496 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002688:	015c87bb          	addw	a5,s9,s5
    8000268c:	00078a9b          	sext.w	s5,a5
    80002690:	004b2703          	lw	a4,4(s6)
    80002694:	04eaff63          	bgeu	s5,a4,800026f2 <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    80002698:	41fad79b          	sraiw	a5,s5,0x1f
    8000269c:	0137d79b          	srliw	a5,a5,0x13
    800026a0:	015787bb          	addw	a5,a5,s5
    800026a4:	40d7d79b          	sraiw	a5,a5,0xd
    800026a8:	01cb2583          	lw	a1,28(s6)
    800026ac:	9dbd                	addw	a1,a1,a5
    800026ae:	855e                	mv	a0,s7
    800026b0:	cdfff0ef          	jal	ra,8000238e <bread>
    800026b4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800026b6:	004b2503          	lw	a0,4(s6)
    800026ba:	000a849b          	sext.w	s1,s5
    800026be:	8762                	mv	a4,s8
    800026c0:	fca4f1e3          	bgeu	s1,a0,80002682 <balloc+0x8e>
      m = 1 << (bi % 8);
    800026c4:	00777693          	andi	a3,a4,7
    800026c8:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800026cc:	41f7579b          	sraiw	a5,a4,0x1f
    800026d0:	01d7d79b          	srliw	a5,a5,0x1d
    800026d4:	9fb9                	addw	a5,a5,a4
    800026d6:	4037d79b          	sraiw	a5,a5,0x3
    800026da:	00f90633          	add	a2,s2,a5
    800026de:	05864603          	lbu	a2,88(a2)
    800026e2:	00c6f5b3          	and	a1,a3,a2
    800026e6:	d5a1                	beqz	a1,8000262e <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800026e8:	2705                	addiw	a4,a4,1
    800026ea:	2485                	addiw	s1,s1,1
    800026ec:	fd471ae3          	bne	a4,s4,800026c0 <balloc+0xcc>
    800026f0:	bf49                	j	80002682 <balloc+0x8e>
  printf("balloc: out of blocks\n");
    800026f2:	00005517          	auipc	a0,0x5
    800026f6:	fa650513          	addi	a0,a0,-90 # 80007698 <syscalls+0x168>
    800026fa:	575020ef          	jal	ra,8000546e <printf>
  return 0;
    800026fe:	4481                	li	s1,0
    80002700:	b79d                	j	80002666 <balloc+0x72>

0000000080002702 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002702:	7179                	addi	sp,sp,-48
    80002704:	f406                	sd	ra,40(sp)
    80002706:	f022                	sd	s0,32(sp)
    80002708:	ec26                	sd	s1,24(sp)
    8000270a:	e84a                	sd	s2,16(sp)
    8000270c:	e44e                	sd	s3,8(sp)
    8000270e:	e052                	sd	s4,0(sp)
    80002710:	1800                	addi	s0,sp,48
    80002712:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002714:	47ad                	li	a5,11
    80002716:	02b7e663          	bltu	a5,a1,80002742 <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    8000271a:	02059793          	slli	a5,a1,0x20
    8000271e:	01e7d593          	srli	a1,a5,0x1e
    80002722:	00b504b3          	add	s1,a0,a1
    80002726:	0504a903          	lw	s2,80(s1)
    8000272a:	06091663          	bnez	s2,80002796 <bmap+0x94>
      addr = balloc(ip->dev);
    8000272e:	4108                	lw	a0,0(a0)
    80002730:	ec5ff0ef          	jal	ra,800025f4 <balloc>
    80002734:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002738:	04090f63          	beqz	s2,80002796 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    8000273c:	0524a823          	sw	s2,80(s1)
    80002740:	a899                	j	80002796 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002742:	ff45849b          	addiw	s1,a1,-12
    80002746:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000274a:	0ff00793          	li	a5,255
    8000274e:	06e7eb63          	bltu	a5,a4,800027c4 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002752:	08052903          	lw	s2,128(a0)
    80002756:	00091b63          	bnez	s2,8000276c <bmap+0x6a>
      addr = balloc(ip->dev);
    8000275a:	4108                	lw	a0,0(a0)
    8000275c:	e99ff0ef          	jal	ra,800025f4 <balloc>
    80002760:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002764:	02090963          	beqz	s2,80002796 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002768:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000276c:	85ca                	mv	a1,s2
    8000276e:	0009a503          	lw	a0,0(s3)
    80002772:	c1dff0ef          	jal	ra,8000238e <bread>
    80002776:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002778:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000277c:	02049713          	slli	a4,s1,0x20
    80002780:	01e75593          	srli	a1,a4,0x1e
    80002784:	00b784b3          	add	s1,a5,a1
    80002788:	0004a903          	lw	s2,0(s1)
    8000278c:	00090e63          	beqz	s2,800027a8 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002790:	8552                	mv	a0,s4
    80002792:	d05ff0ef          	jal	ra,80002496 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002796:	854a                	mv	a0,s2
    80002798:	70a2                	ld	ra,40(sp)
    8000279a:	7402                	ld	s0,32(sp)
    8000279c:	64e2                	ld	s1,24(sp)
    8000279e:	6942                	ld	s2,16(sp)
    800027a0:	69a2                	ld	s3,8(sp)
    800027a2:	6a02                	ld	s4,0(sp)
    800027a4:	6145                	addi	sp,sp,48
    800027a6:	8082                	ret
      addr = balloc(ip->dev);
    800027a8:	0009a503          	lw	a0,0(s3)
    800027ac:	e49ff0ef          	jal	ra,800025f4 <balloc>
    800027b0:	0005091b          	sext.w	s2,a0
      if(addr){
    800027b4:	fc090ee3          	beqz	s2,80002790 <bmap+0x8e>
        a[bn] = addr;
    800027b8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800027bc:	8552                	mv	a0,s4
    800027be:	503000ef          	jal	ra,800034c0 <log_write>
    800027c2:	b7f9                	j	80002790 <bmap+0x8e>
  panic("bmap: out of range");
    800027c4:	00005517          	auipc	a0,0x5
    800027c8:	eec50513          	addi	a0,a0,-276 # 800076b0 <syscalls+0x180>
    800027cc:	757020ef          	jal	ra,80005722 <panic>

00000000800027d0 <iget>:
{
    800027d0:	7179                	addi	sp,sp,-48
    800027d2:	f406                	sd	ra,40(sp)
    800027d4:	f022                	sd	s0,32(sp)
    800027d6:	ec26                	sd	s1,24(sp)
    800027d8:	e84a                	sd	s2,16(sp)
    800027da:	e44e                	sd	s3,8(sp)
    800027dc:	e052                	sd	s4,0(sp)
    800027de:	1800                	addi	s0,sp,48
    800027e0:	89aa                	mv	s3,a0
    800027e2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800027e4:	00014517          	auipc	a0,0x14
    800027e8:	a0450513          	addi	a0,a0,-1532 # 800161e8 <itable>
    800027ec:	246030ef          	jal	ra,80005a32 <acquire>
  empty = 0;
    800027f0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800027f2:	00014497          	auipc	s1,0x14
    800027f6:	a0e48493          	addi	s1,s1,-1522 # 80016200 <itable+0x18>
    800027fa:	00015697          	auipc	a3,0x15
    800027fe:	49668693          	addi	a3,a3,1174 # 80017c90 <log>
    80002802:	a039                	j	80002810 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002804:	02090963          	beqz	s2,80002836 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002808:	08848493          	addi	s1,s1,136
    8000280c:	02d48863          	beq	s1,a3,8000283c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002810:	449c                	lw	a5,8(s1)
    80002812:	fef059e3          	blez	a5,80002804 <iget+0x34>
    80002816:	4098                	lw	a4,0(s1)
    80002818:	ff3716e3          	bne	a4,s3,80002804 <iget+0x34>
    8000281c:	40d8                	lw	a4,4(s1)
    8000281e:	ff4713e3          	bne	a4,s4,80002804 <iget+0x34>
      ip->ref++;
    80002822:	2785                	addiw	a5,a5,1
    80002824:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002826:	00014517          	auipc	a0,0x14
    8000282a:	9c250513          	addi	a0,a0,-1598 # 800161e8 <itable>
    8000282e:	29c030ef          	jal	ra,80005aca <release>
      return ip;
    80002832:	8926                	mv	s2,s1
    80002834:	a02d                	j	8000285e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002836:	fbe9                	bnez	a5,80002808 <iget+0x38>
    80002838:	8926                	mv	s2,s1
    8000283a:	b7f9                	j	80002808 <iget+0x38>
  if(empty == 0)
    8000283c:	02090a63          	beqz	s2,80002870 <iget+0xa0>
  ip->dev = dev;
    80002840:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002844:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002848:	4785                	li	a5,1
    8000284a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000284e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002852:	00014517          	auipc	a0,0x14
    80002856:	99650513          	addi	a0,a0,-1642 # 800161e8 <itable>
    8000285a:	270030ef          	jal	ra,80005aca <release>
}
    8000285e:	854a                	mv	a0,s2
    80002860:	70a2                	ld	ra,40(sp)
    80002862:	7402                	ld	s0,32(sp)
    80002864:	64e2                	ld	s1,24(sp)
    80002866:	6942                	ld	s2,16(sp)
    80002868:	69a2                	ld	s3,8(sp)
    8000286a:	6a02                	ld	s4,0(sp)
    8000286c:	6145                	addi	sp,sp,48
    8000286e:	8082                	ret
    panic("iget: no inodes");
    80002870:	00005517          	auipc	a0,0x5
    80002874:	e5850513          	addi	a0,a0,-424 # 800076c8 <syscalls+0x198>
    80002878:	6ab020ef          	jal	ra,80005722 <panic>

000000008000287c <fsinit>:
fsinit(int dev) {
    8000287c:	7179                	addi	sp,sp,-48
    8000287e:	f406                	sd	ra,40(sp)
    80002880:	f022                	sd	s0,32(sp)
    80002882:	ec26                	sd	s1,24(sp)
    80002884:	e84a                	sd	s2,16(sp)
    80002886:	e44e                	sd	s3,8(sp)
    80002888:	1800                	addi	s0,sp,48
    8000288a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000288c:	4585                	li	a1,1
    8000288e:	b01ff0ef          	jal	ra,8000238e <bread>
    80002892:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002894:	00014997          	auipc	s3,0x14
    80002898:	93498993          	addi	s3,s3,-1740 # 800161c8 <sb>
    8000289c:	02000613          	li	a2,32
    800028a0:	05850593          	addi	a1,a0,88
    800028a4:	854e                	mv	a0,s3
    800028a6:	a69fd0ef          	jal	ra,8000030e <memmove>
  brelse(bp);
    800028aa:	8526                	mv	a0,s1
    800028ac:	bebff0ef          	jal	ra,80002496 <brelse>
  if(sb.magic != FSMAGIC)
    800028b0:	0009a703          	lw	a4,0(s3)
    800028b4:	102037b7          	lui	a5,0x10203
    800028b8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800028bc:	02f71063          	bne	a4,a5,800028dc <fsinit+0x60>
  initlog(dev, &sb);
    800028c0:	00014597          	auipc	a1,0x14
    800028c4:	90858593          	addi	a1,a1,-1784 # 800161c8 <sb>
    800028c8:	854a                	mv	a0,s2
    800028ca:	1e3000ef          	jal	ra,800032ac <initlog>
}
    800028ce:	70a2                	ld	ra,40(sp)
    800028d0:	7402                	ld	s0,32(sp)
    800028d2:	64e2                	ld	s1,24(sp)
    800028d4:	6942                	ld	s2,16(sp)
    800028d6:	69a2                	ld	s3,8(sp)
    800028d8:	6145                	addi	sp,sp,48
    800028da:	8082                	ret
    panic("invalid file system");
    800028dc:	00005517          	auipc	a0,0x5
    800028e0:	dfc50513          	addi	a0,a0,-516 # 800076d8 <syscalls+0x1a8>
    800028e4:	63f020ef          	jal	ra,80005722 <panic>

00000000800028e8 <iinit>:
{
    800028e8:	7179                	addi	sp,sp,-48
    800028ea:	f406                	sd	ra,40(sp)
    800028ec:	f022                	sd	s0,32(sp)
    800028ee:	ec26                	sd	s1,24(sp)
    800028f0:	e84a                	sd	s2,16(sp)
    800028f2:	e44e                	sd	s3,8(sp)
    800028f4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800028f6:	00005597          	auipc	a1,0x5
    800028fa:	dfa58593          	addi	a1,a1,-518 # 800076f0 <syscalls+0x1c0>
    800028fe:	00014517          	auipc	a0,0x14
    80002902:	8ea50513          	addi	a0,a0,-1814 # 800161e8 <itable>
    80002906:	0ac030ef          	jal	ra,800059b2 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000290a:	00014497          	auipc	s1,0x14
    8000290e:	90648493          	addi	s1,s1,-1786 # 80016210 <itable+0x28>
    80002912:	00015997          	auipc	s3,0x15
    80002916:	38e98993          	addi	s3,s3,910 # 80017ca0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000291a:	00005917          	auipc	s2,0x5
    8000291e:	dde90913          	addi	s2,s2,-546 # 800076f8 <syscalls+0x1c8>
    80002922:	85ca                	mv	a1,s2
    80002924:	8526                	mv	a0,s1
    80002926:	46b000ef          	jal	ra,80003590 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000292a:	08848493          	addi	s1,s1,136
    8000292e:	ff349ae3          	bne	s1,s3,80002922 <iinit+0x3a>
}
    80002932:	70a2                	ld	ra,40(sp)
    80002934:	7402                	ld	s0,32(sp)
    80002936:	64e2                	ld	s1,24(sp)
    80002938:	6942                	ld	s2,16(sp)
    8000293a:	69a2                	ld	s3,8(sp)
    8000293c:	6145                	addi	sp,sp,48
    8000293e:	8082                	ret

0000000080002940 <ialloc>:
{
    80002940:	715d                	addi	sp,sp,-80
    80002942:	e486                	sd	ra,72(sp)
    80002944:	e0a2                	sd	s0,64(sp)
    80002946:	fc26                	sd	s1,56(sp)
    80002948:	f84a                	sd	s2,48(sp)
    8000294a:	f44e                	sd	s3,40(sp)
    8000294c:	f052                	sd	s4,32(sp)
    8000294e:	ec56                	sd	s5,24(sp)
    80002950:	e85a                	sd	s6,16(sp)
    80002952:	e45e                	sd	s7,8(sp)
    80002954:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002956:	00014717          	auipc	a4,0x14
    8000295a:	87e72703          	lw	a4,-1922(a4) # 800161d4 <sb+0xc>
    8000295e:	4785                	li	a5,1
    80002960:	04e7f663          	bgeu	a5,a4,800029ac <ialloc+0x6c>
    80002964:	8aaa                	mv	s5,a0
    80002966:	8bae                	mv	s7,a1
    80002968:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000296a:	00014a17          	auipc	s4,0x14
    8000296e:	85ea0a13          	addi	s4,s4,-1954 # 800161c8 <sb>
    80002972:	00048b1b          	sext.w	s6,s1
    80002976:	0044d593          	srli	a1,s1,0x4
    8000297a:	018a2783          	lw	a5,24(s4)
    8000297e:	9dbd                	addw	a1,a1,a5
    80002980:	8556                	mv	a0,s5
    80002982:	a0dff0ef          	jal	ra,8000238e <bread>
    80002986:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002988:	05850993          	addi	s3,a0,88
    8000298c:	00f4f793          	andi	a5,s1,15
    80002990:	079a                	slli	a5,a5,0x6
    80002992:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002994:	00099783          	lh	a5,0(s3)
    80002998:	cf85                	beqz	a5,800029d0 <ialloc+0x90>
    brelse(bp);
    8000299a:	afdff0ef          	jal	ra,80002496 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000299e:	0485                	addi	s1,s1,1
    800029a0:	00ca2703          	lw	a4,12(s4)
    800029a4:	0004879b          	sext.w	a5,s1
    800029a8:	fce7e5e3          	bltu	a5,a4,80002972 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800029ac:	00005517          	auipc	a0,0x5
    800029b0:	d5450513          	addi	a0,a0,-684 # 80007700 <syscalls+0x1d0>
    800029b4:	2bb020ef          	jal	ra,8000546e <printf>
  return 0;
    800029b8:	4501                	li	a0,0
}
    800029ba:	60a6                	ld	ra,72(sp)
    800029bc:	6406                	ld	s0,64(sp)
    800029be:	74e2                	ld	s1,56(sp)
    800029c0:	7942                	ld	s2,48(sp)
    800029c2:	79a2                	ld	s3,40(sp)
    800029c4:	7a02                	ld	s4,32(sp)
    800029c6:	6ae2                	ld	s5,24(sp)
    800029c8:	6b42                	ld	s6,16(sp)
    800029ca:	6ba2                	ld	s7,8(sp)
    800029cc:	6161                	addi	sp,sp,80
    800029ce:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800029d0:	04000613          	li	a2,64
    800029d4:	4581                	li	a1,0
    800029d6:	854e                	mv	a0,s3
    800029d8:	8dbfd0ef          	jal	ra,800002b2 <memset>
      dip->type = type;
    800029dc:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800029e0:	854a                	mv	a0,s2
    800029e2:	2df000ef          	jal	ra,800034c0 <log_write>
      brelse(bp);
    800029e6:	854a                	mv	a0,s2
    800029e8:	aafff0ef          	jal	ra,80002496 <brelse>
      return iget(dev, inum);
    800029ec:	85da                	mv	a1,s6
    800029ee:	8556                	mv	a0,s5
    800029f0:	de1ff0ef          	jal	ra,800027d0 <iget>
    800029f4:	b7d9                	j	800029ba <ialloc+0x7a>

00000000800029f6 <iupdate>:
{
    800029f6:	1101                	addi	sp,sp,-32
    800029f8:	ec06                	sd	ra,24(sp)
    800029fa:	e822                	sd	s0,16(sp)
    800029fc:	e426                	sd	s1,8(sp)
    800029fe:	e04a                	sd	s2,0(sp)
    80002a00:	1000                	addi	s0,sp,32
    80002a02:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002a04:	415c                	lw	a5,4(a0)
    80002a06:	0047d79b          	srliw	a5,a5,0x4
    80002a0a:	00013597          	auipc	a1,0x13
    80002a0e:	7d65a583          	lw	a1,2006(a1) # 800161e0 <sb+0x18>
    80002a12:	9dbd                	addw	a1,a1,a5
    80002a14:	4108                	lw	a0,0(a0)
    80002a16:	979ff0ef          	jal	ra,8000238e <bread>
    80002a1a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002a1c:	05850793          	addi	a5,a0,88
    80002a20:	40d8                	lw	a4,4(s1)
    80002a22:	8b3d                	andi	a4,a4,15
    80002a24:	071a                	slli	a4,a4,0x6
    80002a26:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002a28:	04449703          	lh	a4,68(s1)
    80002a2c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002a30:	04649703          	lh	a4,70(s1)
    80002a34:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002a38:	04849703          	lh	a4,72(s1)
    80002a3c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002a40:	04a49703          	lh	a4,74(s1)
    80002a44:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002a48:	44f8                	lw	a4,76(s1)
    80002a4a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002a4c:	03400613          	li	a2,52
    80002a50:	05048593          	addi	a1,s1,80
    80002a54:	00c78513          	addi	a0,a5,12
    80002a58:	8b7fd0ef          	jal	ra,8000030e <memmove>
  log_write(bp);
    80002a5c:	854a                	mv	a0,s2
    80002a5e:	263000ef          	jal	ra,800034c0 <log_write>
  brelse(bp);
    80002a62:	854a                	mv	a0,s2
    80002a64:	a33ff0ef          	jal	ra,80002496 <brelse>
}
    80002a68:	60e2                	ld	ra,24(sp)
    80002a6a:	6442                	ld	s0,16(sp)
    80002a6c:	64a2                	ld	s1,8(sp)
    80002a6e:	6902                	ld	s2,0(sp)
    80002a70:	6105                	addi	sp,sp,32
    80002a72:	8082                	ret

0000000080002a74 <idup>:
{
    80002a74:	1101                	addi	sp,sp,-32
    80002a76:	ec06                	sd	ra,24(sp)
    80002a78:	e822                	sd	s0,16(sp)
    80002a7a:	e426                	sd	s1,8(sp)
    80002a7c:	1000                	addi	s0,sp,32
    80002a7e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002a80:	00013517          	auipc	a0,0x13
    80002a84:	76850513          	addi	a0,a0,1896 # 800161e8 <itable>
    80002a88:	7ab020ef          	jal	ra,80005a32 <acquire>
  ip->ref++;
    80002a8c:	449c                	lw	a5,8(s1)
    80002a8e:	2785                	addiw	a5,a5,1
    80002a90:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002a92:	00013517          	auipc	a0,0x13
    80002a96:	75650513          	addi	a0,a0,1878 # 800161e8 <itable>
    80002a9a:	030030ef          	jal	ra,80005aca <release>
}
    80002a9e:	8526                	mv	a0,s1
    80002aa0:	60e2                	ld	ra,24(sp)
    80002aa2:	6442                	ld	s0,16(sp)
    80002aa4:	64a2                	ld	s1,8(sp)
    80002aa6:	6105                	addi	sp,sp,32
    80002aa8:	8082                	ret

0000000080002aaa <ilock>:
{
    80002aaa:	1101                	addi	sp,sp,-32
    80002aac:	ec06                	sd	ra,24(sp)
    80002aae:	e822                	sd	s0,16(sp)
    80002ab0:	e426                	sd	s1,8(sp)
    80002ab2:	e04a                	sd	s2,0(sp)
    80002ab4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002ab6:	c105                	beqz	a0,80002ad6 <ilock+0x2c>
    80002ab8:	84aa                	mv	s1,a0
    80002aba:	451c                	lw	a5,8(a0)
    80002abc:	00f05d63          	blez	a5,80002ad6 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80002ac0:	0541                	addi	a0,a0,16
    80002ac2:	305000ef          	jal	ra,800035c6 <acquiresleep>
  if(ip->valid == 0){
    80002ac6:	40bc                	lw	a5,64(s1)
    80002ac8:	cf89                	beqz	a5,80002ae2 <ilock+0x38>
}
    80002aca:	60e2                	ld	ra,24(sp)
    80002acc:	6442                	ld	s0,16(sp)
    80002ace:	64a2                	ld	s1,8(sp)
    80002ad0:	6902                	ld	s2,0(sp)
    80002ad2:	6105                	addi	sp,sp,32
    80002ad4:	8082                	ret
    panic("ilock");
    80002ad6:	00005517          	auipc	a0,0x5
    80002ada:	c4250513          	addi	a0,a0,-958 # 80007718 <syscalls+0x1e8>
    80002ade:	445020ef          	jal	ra,80005722 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002ae2:	40dc                	lw	a5,4(s1)
    80002ae4:	0047d79b          	srliw	a5,a5,0x4
    80002ae8:	00013597          	auipc	a1,0x13
    80002aec:	6f85a583          	lw	a1,1784(a1) # 800161e0 <sb+0x18>
    80002af0:	9dbd                	addw	a1,a1,a5
    80002af2:	4088                	lw	a0,0(s1)
    80002af4:	89bff0ef          	jal	ra,8000238e <bread>
    80002af8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002afa:	05850593          	addi	a1,a0,88
    80002afe:	40dc                	lw	a5,4(s1)
    80002b00:	8bbd                	andi	a5,a5,15
    80002b02:	079a                	slli	a5,a5,0x6
    80002b04:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002b06:	00059783          	lh	a5,0(a1)
    80002b0a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002b0e:	00259783          	lh	a5,2(a1)
    80002b12:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002b16:	00459783          	lh	a5,4(a1)
    80002b1a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002b1e:	00659783          	lh	a5,6(a1)
    80002b22:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002b26:	459c                	lw	a5,8(a1)
    80002b28:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002b2a:	03400613          	li	a2,52
    80002b2e:	05b1                	addi	a1,a1,12
    80002b30:	05048513          	addi	a0,s1,80
    80002b34:	fdafd0ef          	jal	ra,8000030e <memmove>
    brelse(bp);
    80002b38:	854a                	mv	a0,s2
    80002b3a:	95dff0ef          	jal	ra,80002496 <brelse>
    ip->valid = 1;
    80002b3e:	4785                	li	a5,1
    80002b40:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002b42:	04449783          	lh	a5,68(s1)
    80002b46:	f3d1                	bnez	a5,80002aca <ilock+0x20>
      panic("ilock: no type");
    80002b48:	00005517          	auipc	a0,0x5
    80002b4c:	bd850513          	addi	a0,a0,-1064 # 80007720 <syscalls+0x1f0>
    80002b50:	3d3020ef          	jal	ra,80005722 <panic>

0000000080002b54 <iunlock>:
{
    80002b54:	1101                	addi	sp,sp,-32
    80002b56:	ec06                	sd	ra,24(sp)
    80002b58:	e822                	sd	s0,16(sp)
    80002b5a:	e426                	sd	s1,8(sp)
    80002b5c:	e04a                	sd	s2,0(sp)
    80002b5e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002b60:	c505                	beqz	a0,80002b88 <iunlock+0x34>
    80002b62:	84aa                	mv	s1,a0
    80002b64:	01050913          	addi	s2,a0,16
    80002b68:	854a                	mv	a0,s2
    80002b6a:	2db000ef          	jal	ra,80003644 <holdingsleep>
    80002b6e:	cd09                	beqz	a0,80002b88 <iunlock+0x34>
    80002b70:	449c                	lw	a5,8(s1)
    80002b72:	00f05b63          	blez	a5,80002b88 <iunlock+0x34>
  releasesleep(&ip->lock);
    80002b76:	854a                	mv	a0,s2
    80002b78:	295000ef          	jal	ra,8000360c <releasesleep>
}
    80002b7c:	60e2                	ld	ra,24(sp)
    80002b7e:	6442                	ld	s0,16(sp)
    80002b80:	64a2                	ld	s1,8(sp)
    80002b82:	6902                	ld	s2,0(sp)
    80002b84:	6105                	addi	sp,sp,32
    80002b86:	8082                	ret
    panic("iunlock");
    80002b88:	00005517          	auipc	a0,0x5
    80002b8c:	ba850513          	addi	a0,a0,-1112 # 80007730 <syscalls+0x200>
    80002b90:	393020ef          	jal	ra,80005722 <panic>

0000000080002b94 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002b94:	7179                	addi	sp,sp,-48
    80002b96:	f406                	sd	ra,40(sp)
    80002b98:	f022                	sd	s0,32(sp)
    80002b9a:	ec26                	sd	s1,24(sp)
    80002b9c:	e84a                	sd	s2,16(sp)
    80002b9e:	e44e                	sd	s3,8(sp)
    80002ba0:	e052                	sd	s4,0(sp)
    80002ba2:	1800                	addi	s0,sp,48
    80002ba4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002ba6:	05050493          	addi	s1,a0,80
    80002baa:	08050913          	addi	s2,a0,128
    80002bae:	a021                	j	80002bb6 <itrunc+0x22>
    80002bb0:	0491                	addi	s1,s1,4
    80002bb2:	01248b63          	beq	s1,s2,80002bc8 <itrunc+0x34>
    if(ip->addrs[i]){
    80002bb6:	408c                	lw	a1,0(s1)
    80002bb8:	dde5                	beqz	a1,80002bb0 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002bba:	0009a503          	lw	a0,0(s3)
    80002bbe:	9cbff0ef          	jal	ra,80002588 <bfree>
      ip->addrs[i] = 0;
    80002bc2:	0004a023          	sw	zero,0(s1)
    80002bc6:	b7ed                	j	80002bb0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002bc8:	0809a583          	lw	a1,128(s3)
    80002bcc:	ed91                	bnez	a1,80002be8 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002bce:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002bd2:	854e                	mv	a0,s3
    80002bd4:	e23ff0ef          	jal	ra,800029f6 <iupdate>
}
    80002bd8:	70a2                	ld	ra,40(sp)
    80002bda:	7402                	ld	s0,32(sp)
    80002bdc:	64e2                	ld	s1,24(sp)
    80002bde:	6942                	ld	s2,16(sp)
    80002be0:	69a2                	ld	s3,8(sp)
    80002be2:	6a02                	ld	s4,0(sp)
    80002be4:	6145                	addi	sp,sp,48
    80002be6:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002be8:	0009a503          	lw	a0,0(s3)
    80002bec:	fa2ff0ef          	jal	ra,8000238e <bread>
    80002bf0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002bf2:	05850493          	addi	s1,a0,88
    80002bf6:	45850913          	addi	s2,a0,1112
    80002bfa:	a021                	j	80002c02 <itrunc+0x6e>
    80002bfc:	0491                	addi	s1,s1,4
    80002bfe:	01248963          	beq	s1,s2,80002c10 <itrunc+0x7c>
      if(a[j])
    80002c02:	408c                	lw	a1,0(s1)
    80002c04:	dde5                	beqz	a1,80002bfc <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80002c06:	0009a503          	lw	a0,0(s3)
    80002c0a:	97fff0ef          	jal	ra,80002588 <bfree>
    80002c0e:	b7fd                	j	80002bfc <itrunc+0x68>
    brelse(bp);
    80002c10:	8552                	mv	a0,s4
    80002c12:	885ff0ef          	jal	ra,80002496 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002c16:	0809a583          	lw	a1,128(s3)
    80002c1a:	0009a503          	lw	a0,0(s3)
    80002c1e:	96bff0ef          	jal	ra,80002588 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002c22:	0809a023          	sw	zero,128(s3)
    80002c26:	b765                	j	80002bce <itrunc+0x3a>

0000000080002c28 <iput>:
{
    80002c28:	1101                	addi	sp,sp,-32
    80002c2a:	ec06                	sd	ra,24(sp)
    80002c2c:	e822                	sd	s0,16(sp)
    80002c2e:	e426                	sd	s1,8(sp)
    80002c30:	e04a                	sd	s2,0(sp)
    80002c32:	1000                	addi	s0,sp,32
    80002c34:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002c36:	00013517          	auipc	a0,0x13
    80002c3a:	5b250513          	addi	a0,a0,1458 # 800161e8 <itable>
    80002c3e:	5f5020ef          	jal	ra,80005a32 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002c42:	4498                	lw	a4,8(s1)
    80002c44:	4785                	li	a5,1
    80002c46:	02f70163          	beq	a4,a5,80002c68 <iput+0x40>
  ip->ref--;
    80002c4a:	449c                	lw	a5,8(s1)
    80002c4c:	37fd                	addiw	a5,a5,-1
    80002c4e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002c50:	00013517          	auipc	a0,0x13
    80002c54:	59850513          	addi	a0,a0,1432 # 800161e8 <itable>
    80002c58:	673020ef          	jal	ra,80005aca <release>
}
    80002c5c:	60e2                	ld	ra,24(sp)
    80002c5e:	6442                	ld	s0,16(sp)
    80002c60:	64a2                	ld	s1,8(sp)
    80002c62:	6902                	ld	s2,0(sp)
    80002c64:	6105                	addi	sp,sp,32
    80002c66:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002c68:	40bc                	lw	a5,64(s1)
    80002c6a:	d3e5                	beqz	a5,80002c4a <iput+0x22>
    80002c6c:	04a49783          	lh	a5,74(s1)
    80002c70:	ffe9                	bnez	a5,80002c4a <iput+0x22>
    acquiresleep(&ip->lock);
    80002c72:	01048913          	addi	s2,s1,16
    80002c76:	854a                	mv	a0,s2
    80002c78:	14f000ef          	jal	ra,800035c6 <acquiresleep>
    release(&itable.lock);
    80002c7c:	00013517          	auipc	a0,0x13
    80002c80:	56c50513          	addi	a0,a0,1388 # 800161e8 <itable>
    80002c84:	647020ef          	jal	ra,80005aca <release>
    itrunc(ip);
    80002c88:	8526                	mv	a0,s1
    80002c8a:	f0bff0ef          	jal	ra,80002b94 <itrunc>
    ip->type = 0;
    80002c8e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002c92:	8526                	mv	a0,s1
    80002c94:	d63ff0ef          	jal	ra,800029f6 <iupdate>
    ip->valid = 0;
    80002c98:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002c9c:	854a                	mv	a0,s2
    80002c9e:	16f000ef          	jal	ra,8000360c <releasesleep>
    acquire(&itable.lock);
    80002ca2:	00013517          	auipc	a0,0x13
    80002ca6:	54650513          	addi	a0,a0,1350 # 800161e8 <itable>
    80002caa:	589020ef          	jal	ra,80005a32 <acquire>
    80002cae:	bf71                	j	80002c4a <iput+0x22>

0000000080002cb0 <iunlockput>:
{
    80002cb0:	1101                	addi	sp,sp,-32
    80002cb2:	ec06                	sd	ra,24(sp)
    80002cb4:	e822                	sd	s0,16(sp)
    80002cb6:	e426                	sd	s1,8(sp)
    80002cb8:	1000                	addi	s0,sp,32
    80002cba:	84aa                	mv	s1,a0
  iunlock(ip);
    80002cbc:	e99ff0ef          	jal	ra,80002b54 <iunlock>
  iput(ip);
    80002cc0:	8526                	mv	a0,s1
    80002cc2:	f67ff0ef          	jal	ra,80002c28 <iput>
}
    80002cc6:	60e2                	ld	ra,24(sp)
    80002cc8:	6442                	ld	s0,16(sp)
    80002cca:	64a2                	ld	s1,8(sp)
    80002ccc:	6105                	addi	sp,sp,32
    80002cce:	8082                	ret

0000000080002cd0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002cd0:	1141                	addi	sp,sp,-16
    80002cd2:	e422                	sd	s0,8(sp)
    80002cd4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002cd6:	411c                	lw	a5,0(a0)
    80002cd8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002cda:	415c                	lw	a5,4(a0)
    80002cdc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002cde:	04451783          	lh	a5,68(a0)
    80002ce2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002ce6:	04a51783          	lh	a5,74(a0)
    80002cea:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002cee:	04c56783          	lwu	a5,76(a0)
    80002cf2:	e99c                	sd	a5,16(a1)
}
    80002cf4:	6422                	ld	s0,8(sp)
    80002cf6:	0141                	addi	sp,sp,16
    80002cf8:	8082                	ret

0000000080002cfa <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002cfa:	457c                	lw	a5,76(a0)
    80002cfc:	0cd7ef63          	bltu	a5,a3,80002dda <readi+0xe0>
{
    80002d00:	7159                	addi	sp,sp,-112
    80002d02:	f486                	sd	ra,104(sp)
    80002d04:	f0a2                	sd	s0,96(sp)
    80002d06:	eca6                	sd	s1,88(sp)
    80002d08:	e8ca                	sd	s2,80(sp)
    80002d0a:	e4ce                	sd	s3,72(sp)
    80002d0c:	e0d2                	sd	s4,64(sp)
    80002d0e:	fc56                	sd	s5,56(sp)
    80002d10:	f85a                	sd	s6,48(sp)
    80002d12:	f45e                	sd	s7,40(sp)
    80002d14:	f062                	sd	s8,32(sp)
    80002d16:	ec66                	sd	s9,24(sp)
    80002d18:	e86a                	sd	s10,16(sp)
    80002d1a:	e46e                	sd	s11,8(sp)
    80002d1c:	1880                	addi	s0,sp,112
    80002d1e:	8b2a                	mv	s6,a0
    80002d20:	8bae                	mv	s7,a1
    80002d22:	8a32                	mv	s4,a2
    80002d24:	84b6                	mv	s1,a3
    80002d26:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002d28:	9f35                	addw	a4,a4,a3
    return 0;
    80002d2a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002d2c:	08d76663          	bltu	a4,a3,80002db8 <readi+0xbe>
  if(off + n > ip->size)
    80002d30:	00e7f463          	bgeu	a5,a4,80002d38 <readi+0x3e>
    n = ip->size - off;
    80002d34:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002d38:	080a8f63          	beqz	s5,80002dd6 <readi+0xdc>
    80002d3c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002d3e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002d42:	5c7d                	li	s8,-1
    80002d44:	a80d                	j	80002d76 <readi+0x7c>
    80002d46:	020d1d93          	slli	s11,s10,0x20
    80002d4a:	020ddd93          	srli	s11,s11,0x20
    80002d4e:	05890613          	addi	a2,s2,88
    80002d52:	86ee                	mv	a3,s11
    80002d54:	963a                	add	a2,a2,a4
    80002d56:	85d2                	mv	a1,s4
    80002d58:	855e                	mv	a0,s7
    80002d5a:	d6bfe0ef          	jal	ra,80001ac4 <either_copyout>
    80002d5e:	05850763          	beq	a0,s8,80002dac <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002d62:	854a                	mv	a0,s2
    80002d64:	f32ff0ef          	jal	ra,80002496 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002d68:	013d09bb          	addw	s3,s10,s3
    80002d6c:	009d04bb          	addw	s1,s10,s1
    80002d70:	9a6e                	add	s4,s4,s11
    80002d72:	0559f163          	bgeu	s3,s5,80002db4 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80002d76:	00a4d59b          	srliw	a1,s1,0xa
    80002d7a:	855a                	mv	a0,s6
    80002d7c:	987ff0ef          	jal	ra,80002702 <bmap>
    80002d80:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002d84:	c985                	beqz	a1,80002db4 <readi+0xba>
    bp = bread(ip->dev, addr);
    80002d86:	000b2503          	lw	a0,0(s6)
    80002d8a:	e04ff0ef          	jal	ra,8000238e <bread>
    80002d8e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002d90:	3ff4f713          	andi	a4,s1,1023
    80002d94:	40ec87bb          	subw	a5,s9,a4
    80002d98:	413a86bb          	subw	a3,s5,s3
    80002d9c:	8d3e                	mv	s10,a5
    80002d9e:	2781                	sext.w	a5,a5
    80002da0:	0006861b          	sext.w	a2,a3
    80002da4:	faf671e3          	bgeu	a2,a5,80002d46 <readi+0x4c>
    80002da8:	8d36                	mv	s10,a3
    80002daa:	bf71                	j	80002d46 <readi+0x4c>
      brelse(bp);
    80002dac:	854a                	mv	a0,s2
    80002dae:	ee8ff0ef          	jal	ra,80002496 <brelse>
      tot = -1;
    80002db2:	59fd                	li	s3,-1
  }
  return tot;
    80002db4:	0009851b          	sext.w	a0,s3
}
    80002db8:	70a6                	ld	ra,104(sp)
    80002dba:	7406                	ld	s0,96(sp)
    80002dbc:	64e6                	ld	s1,88(sp)
    80002dbe:	6946                	ld	s2,80(sp)
    80002dc0:	69a6                	ld	s3,72(sp)
    80002dc2:	6a06                	ld	s4,64(sp)
    80002dc4:	7ae2                	ld	s5,56(sp)
    80002dc6:	7b42                	ld	s6,48(sp)
    80002dc8:	7ba2                	ld	s7,40(sp)
    80002dca:	7c02                	ld	s8,32(sp)
    80002dcc:	6ce2                	ld	s9,24(sp)
    80002dce:	6d42                	ld	s10,16(sp)
    80002dd0:	6da2                	ld	s11,8(sp)
    80002dd2:	6165                	addi	sp,sp,112
    80002dd4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002dd6:	89d6                	mv	s3,s5
    80002dd8:	bff1                	j	80002db4 <readi+0xba>
    return 0;
    80002dda:	4501                	li	a0,0
}
    80002ddc:	8082                	ret

0000000080002dde <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002dde:	457c                	lw	a5,76(a0)
    80002de0:	0ed7ea63          	bltu	a5,a3,80002ed4 <writei+0xf6>
{
    80002de4:	7159                	addi	sp,sp,-112
    80002de6:	f486                	sd	ra,104(sp)
    80002de8:	f0a2                	sd	s0,96(sp)
    80002dea:	eca6                	sd	s1,88(sp)
    80002dec:	e8ca                	sd	s2,80(sp)
    80002dee:	e4ce                	sd	s3,72(sp)
    80002df0:	e0d2                	sd	s4,64(sp)
    80002df2:	fc56                	sd	s5,56(sp)
    80002df4:	f85a                	sd	s6,48(sp)
    80002df6:	f45e                	sd	s7,40(sp)
    80002df8:	f062                	sd	s8,32(sp)
    80002dfa:	ec66                	sd	s9,24(sp)
    80002dfc:	e86a                	sd	s10,16(sp)
    80002dfe:	e46e                	sd	s11,8(sp)
    80002e00:	1880                	addi	s0,sp,112
    80002e02:	8aaa                	mv	s5,a0
    80002e04:	8bae                	mv	s7,a1
    80002e06:	8a32                	mv	s4,a2
    80002e08:	8936                	mv	s2,a3
    80002e0a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002e0c:	00e687bb          	addw	a5,a3,a4
    80002e10:	0cd7e463          	bltu	a5,a3,80002ed8 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002e14:	00043737          	lui	a4,0x43
    80002e18:	0cf76263          	bltu	a4,a5,80002edc <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002e1c:	0a0b0a63          	beqz	s6,80002ed0 <writei+0xf2>
    80002e20:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002e22:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002e26:	5c7d                	li	s8,-1
    80002e28:	a825                	j	80002e60 <writei+0x82>
    80002e2a:	020d1d93          	slli	s11,s10,0x20
    80002e2e:	020ddd93          	srli	s11,s11,0x20
    80002e32:	05848513          	addi	a0,s1,88
    80002e36:	86ee                	mv	a3,s11
    80002e38:	8652                	mv	a2,s4
    80002e3a:	85de                	mv	a1,s7
    80002e3c:	953a                	add	a0,a0,a4
    80002e3e:	cd1fe0ef          	jal	ra,80001b0e <either_copyin>
    80002e42:	05850a63          	beq	a0,s8,80002e96 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002e46:	8526                	mv	a0,s1
    80002e48:	678000ef          	jal	ra,800034c0 <log_write>
    brelse(bp);
    80002e4c:	8526                	mv	a0,s1
    80002e4e:	e48ff0ef          	jal	ra,80002496 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002e52:	013d09bb          	addw	s3,s10,s3
    80002e56:	012d093b          	addw	s2,s10,s2
    80002e5a:	9a6e                	add	s4,s4,s11
    80002e5c:	0569f063          	bgeu	s3,s6,80002e9c <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002e60:	00a9559b          	srliw	a1,s2,0xa
    80002e64:	8556                	mv	a0,s5
    80002e66:	89dff0ef          	jal	ra,80002702 <bmap>
    80002e6a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002e6e:	c59d                	beqz	a1,80002e9c <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002e70:	000aa503          	lw	a0,0(s5)
    80002e74:	d1aff0ef          	jal	ra,8000238e <bread>
    80002e78:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002e7a:	3ff97713          	andi	a4,s2,1023
    80002e7e:	40ec87bb          	subw	a5,s9,a4
    80002e82:	413b06bb          	subw	a3,s6,s3
    80002e86:	8d3e                	mv	s10,a5
    80002e88:	2781                	sext.w	a5,a5
    80002e8a:	0006861b          	sext.w	a2,a3
    80002e8e:	f8f67ee3          	bgeu	a2,a5,80002e2a <writei+0x4c>
    80002e92:	8d36                	mv	s10,a3
    80002e94:	bf59                	j	80002e2a <writei+0x4c>
      brelse(bp);
    80002e96:	8526                	mv	a0,s1
    80002e98:	dfeff0ef          	jal	ra,80002496 <brelse>
  }

  if(off > ip->size)
    80002e9c:	04caa783          	lw	a5,76(s5)
    80002ea0:	0127f463          	bgeu	a5,s2,80002ea8 <writei+0xca>
    ip->size = off;
    80002ea4:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002ea8:	8556                	mv	a0,s5
    80002eaa:	b4dff0ef          	jal	ra,800029f6 <iupdate>

  return tot;
    80002eae:	0009851b          	sext.w	a0,s3
}
    80002eb2:	70a6                	ld	ra,104(sp)
    80002eb4:	7406                	ld	s0,96(sp)
    80002eb6:	64e6                	ld	s1,88(sp)
    80002eb8:	6946                	ld	s2,80(sp)
    80002eba:	69a6                	ld	s3,72(sp)
    80002ebc:	6a06                	ld	s4,64(sp)
    80002ebe:	7ae2                	ld	s5,56(sp)
    80002ec0:	7b42                	ld	s6,48(sp)
    80002ec2:	7ba2                	ld	s7,40(sp)
    80002ec4:	7c02                	ld	s8,32(sp)
    80002ec6:	6ce2                	ld	s9,24(sp)
    80002ec8:	6d42                	ld	s10,16(sp)
    80002eca:	6da2                	ld	s11,8(sp)
    80002ecc:	6165                	addi	sp,sp,112
    80002ece:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002ed0:	89da                	mv	s3,s6
    80002ed2:	bfd9                	j	80002ea8 <writei+0xca>
    return -1;
    80002ed4:	557d                	li	a0,-1
}
    80002ed6:	8082                	ret
    return -1;
    80002ed8:	557d                	li	a0,-1
    80002eda:	bfe1                	j	80002eb2 <writei+0xd4>
    return -1;
    80002edc:	557d                	li	a0,-1
    80002ede:	bfd1                	j	80002eb2 <writei+0xd4>

0000000080002ee0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002ee0:	1141                	addi	sp,sp,-16
    80002ee2:	e406                	sd	ra,8(sp)
    80002ee4:	e022                	sd	s0,0(sp)
    80002ee6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002ee8:	4639                	li	a2,14
    80002eea:	c94fd0ef          	jal	ra,8000037e <strncmp>
}
    80002eee:	60a2                	ld	ra,8(sp)
    80002ef0:	6402                	ld	s0,0(sp)
    80002ef2:	0141                	addi	sp,sp,16
    80002ef4:	8082                	ret

0000000080002ef6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002ef6:	7139                	addi	sp,sp,-64
    80002ef8:	fc06                	sd	ra,56(sp)
    80002efa:	f822                	sd	s0,48(sp)
    80002efc:	f426                	sd	s1,40(sp)
    80002efe:	f04a                	sd	s2,32(sp)
    80002f00:	ec4e                	sd	s3,24(sp)
    80002f02:	e852                	sd	s4,16(sp)
    80002f04:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002f06:	04451703          	lh	a4,68(a0)
    80002f0a:	4785                	li	a5,1
    80002f0c:	00f71a63          	bne	a4,a5,80002f20 <dirlookup+0x2a>
    80002f10:	892a                	mv	s2,a0
    80002f12:	89ae                	mv	s3,a1
    80002f14:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f16:	457c                	lw	a5,76(a0)
    80002f18:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002f1a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f1c:	e39d                	bnez	a5,80002f42 <dirlookup+0x4c>
    80002f1e:	a095                	j	80002f82 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002f20:	00005517          	auipc	a0,0x5
    80002f24:	81850513          	addi	a0,a0,-2024 # 80007738 <syscalls+0x208>
    80002f28:	7fa020ef          	jal	ra,80005722 <panic>
      panic("dirlookup read");
    80002f2c:	00005517          	auipc	a0,0x5
    80002f30:	82450513          	addi	a0,a0,-2012 # 80007750 <syscalls+0x220>
    80002f34:	7ee020ef          	jal	ra,80005722 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f38:	24c1                	addiw	s1,s1,16
    80002f3a:	04c92783          	lw	a5,76(s2)
    80002f3e:	04f4f163          	bgeu	s1,a5,80002f80 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002f42:	4741                	li	a4,16
    80002f44:	86a6                	mv	a3,s1
    80002f46:	fc040613          	addi	a2,s0,-64
    80002f4a:	4581                	li	a1,0
    80002f4c:	854a                	mv	a0,s2
    80002f4e:	dadff0ef          	jal	ra,80002cfa <readi>
    80002f52:	47c1                	li	a5,16
    80002f54:	fcf51ce3          	bne	a0,a5,80002f2c <dirlookup+0x36>
    if(de.inum == 0)
    80002f58:	fc045783          	lhu	a5,-64(s0)
    80002f5c:	dff1                	beqz	a5,80002f38 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002f5e:	fc240593          	addi	a1,s0,-62
    80002f62:	854e                	mv	a0,s3
    80002f64:	f7dff0ef          	jal	ra,80002ee0 <namecmp>
    80002f68:	f961                	bnez	a0,80002f38 <dirlookup+0x42>
      if(poff)
    80002f6a:	000a0463          	beqz	s4,80002f72 <dirlookup+0x7c>
        *poff = off;
    80002f6e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002f72:	fc045583          	lhu	a1,-64(s0)
    80002f76:	00092503          	lw	a0,0(s2)
    80002f7a:	857ff0ef          	jal	ra,800027d0 <iget>
    80002f7e:	a011                	j	80002f82 <dirlookup+0x8c>
  return 0;
    80002f80:	4501                	li	a0,0
}
    80002f82:	70e2                	ld	ra,56(sp)
    80002f84:	7442                	ld	s0,48(sp)
    80002f86:	74a2                	ld	s1,40(sp)
    80002f88:	7902                	ld	s2,32(sp)
    80002f8a:	69e2                	ld	s3,24(sp)
    80002f8c:	6a42                	ld	s4,16(sp)
    80002f8e:	6121                	addi	sp,sp,64
    80002f90:	8082                	ret

0000000080002f92 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002f92:	711d                	addi	sp,sp,-96
    80002f94:	ec86                	sd	ra,88(sp)
    80002f96:	e8a2                	sd	s0,80(sp)
    80002f98:	e4a6                	sd	s1,72(sp)
    80002f9a:	e0ca                	sd	s2,64(sp)
    80002f9c:	fc4e                	sd	s3,56(sp)
    80002f9e:	f852                	sd	s4,48(sp)
    80002fa0:	f456                	sd	s5,40(sp)
    80002fa2:	f05a                	sd	s6,32(sp)
    80002fa4:	ec5e                	sd	s7,24(sp)
    80002fa6:	e862                	sd	s8,16(sp)
    80002fa8:	e466                	sd	s9,8(sp)
    80002faa:	e06a                	sd	s10,0(sp)
    80002fac:	1080                	addi	s0,sp,96
    80002fae:	84aa                	mv	s1,a0
    80002fb0:	8b2e                	mv	s6,a1
    80002fb2:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002fb4:	00054703          	lbu	a4,0(a0)
    80002fb8:	02f00793          	li	a5,47
    80002fbc:	00f70f63          	beq	a4,a5,80002fda <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002fc0:	9dcfe0ef          	jal	ra,8000119c <myproc>
    80002fc4:	15053503          	ld	a0,336(a0)
    80002fc8:	aadff0ef          	jal	ra,80002a74 <idup>
    80002fcc:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002fce:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002fd2:	4cb5                	li	s9,13
  len = path - s;
    80002fd4:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002fd6:	4c05                	li	s8,1
    80002fd8:	a879                	j	80003076 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80002fda:	4585                	li	a1,1
    80002fdc:	4505                	li	a0,1
    80002fde:	ff2ff0ef          	jal	ra,800027d0 <iget>
    80002fe2:	8a2a                	mv	s4,a0
    80002fe4:	b7ed                	j	80002fce <namex+0x3c>
      iunlockput(ip);
    80002fe6:	8552                	mv	a0,s4
    80002fe8:	cc9ff0ef          	jal	ra,80002cb0 <iunlockput>
      return 0;
    80002fec:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002fee:	8552                	mv	a0,s4
    80002ff0:	60e6                	ld	ra,88(sp)
    80002ff2:	6446                	ld	s0,80(sp)
    80002ff4:	64a6                	ld	s1,72(sp)
    80002ff6:	6906                	ld	s2,64(sp)
    80002ff8:	79e2                	ld	s3,56(sp)
    80002ffa:	7a42                	ld	s4,48(sp)
    80002ffc:	7aa2                	ld	s5,40(sp)
    80002ffe:	7b02                	ld	s6,32(sp)
    80003000:	6be2                	ld	s7,24(sp)
    80003002:	6c42                	ld	s8,16(sp)
    80003004:	6ca2                	ld	s9,8(sp)
    80003006:	6d02                	ld	s10,0(sp)
    80003008:	6125                	addi	sp,sp,96
    8000300a:	8082                	ret
      iunlock(ip);
    8000300c:	8552                	mv	a0,s4
    8000300e:	b47ff0ef          	jal	ra,80002b54 <iunlock>
      return ip;
    80003012:	bff1                	j	80002fee <namex+0x5c>
      iunlockput(ip);
    80003014:	8552                	mv	a0,s4
    80003016:	c9bff0ef          	jal	ra,80002cb0 <iunlockput>
      return 0;
    8000301a:	8a4e                	mv	s4,s3
    8000301c:	bfc9                	j	80002fee <namex+0x5c>
  len = path - s;
    8000301e:	40998633          	sub	a2,s3,s1
    80003022:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003026:	09acd063          	bge	s9,s10,800030a6 <namex+0x114>
    memmove(name, s, DIRSIZ);
    8000302a:	4639                	li	a2,14
    8000302c:	85a6                	mv	a1,s1
    8000302e:	8556                	mv	a0,s5
    80003030:	adefd0ef          	jal	ra,8000030e <memmove>
    80003034:	84ce                	mv	s1,s3
  while(*path == '/')
    80003036:	0004c783          	lbu	a5,0(s1)
    8000303a:	01279763          	bne	a5,s2,80003048 <namex+0xb6>
    path++;
    8000303e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003040:	0004c783          	lbu	a5,0(s1)
    80003044:	ff278de3          	beq	a5,s2,8000303e <namex+0xac>
    ilock(ip);
    80003048:	8552                	mv	a0,s4
    8000304a:	a61ff0ef          	jal	ra,80002aaa <ilock>
    if(ip->type != T_DIR){
    8000304e:	044a1783          	lh	a5,68(s4)
    80003052:	f9879ae3          	bne	a5,s8,80002fe6 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003056:	000b0563          	beqz	s6,80003060 <namex+0xce>
    8000305a:	0004c783          	lbu	a5,0(s1)
    8000305e:	d7dd                	beqz	a5,8000300c <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003060:	865e                	mv	a2,s7
    80003062:	85d6                	mv	a1,s5
    80003064:	8552                	mv	a0,s4
    80003066:	e91ff0ef          	jal	ra,80002ef6 <dirlookup>
    8000306a:	89aa                	mv	s3,a0
    8000306c:	d545                	beqz	a0,80003014 <namex+0x82>
    iunlockput(ip);
    8000306e:	8552                	mv	a0,s4
    80003070:	c41ff0ef          	jal	ra,80002cb0 <iunlockput>
    ip = next;
    80003074:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003076:	0004c783          	lbu	a5,0(s1)
    8000307a:	01279763          	bne	a5,s2,80003088 <namex+0xf6>
    path++;
    8000307e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003080:	0004c783          	lbu	a5,0(s1)
    80003084:	ff278de3          	beq	a5,s2,8000307e <namex+0xec>
  if(*path == 0)
    80003088:	cb8d                	beqz	a5,800030ba <namex+0x128>
  while(*path != '/' && *path != 0)
    8000308a:	0004c783          	lbu	a5,0(s1)
    8000308e:	89a6                	mv	s3,s1
  len = path - s;
    80003090:	8d5e                	mv	s10,s7
    80003092:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003094:	01278963          	beq	a5,s2,800030a6 <namex+0x114>
    80003098:	d3d9                	beqz	a5,8000301e <namex+0x8c>
    path++;
    8000309a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000309c:	0009c783          	lbu	a5,0(s3)
    800030a0:	ff279ce3          	bne	a5,s2,80003098 <namex+0x106>
    800030a4:	bfad                	j	8000301e <namex+0x8c>
    memmove(name, s, len);
    800030a6:	2601                	sext.w	a2,a2
    800030a8:	85a6                	mv	a1,s1
    800030aa:	8556                	mv	a0,s5
    800030ac:	a62fd0ef          	jal	ra,8000030e <memmove>
    name[len] = 0;
    800030b0:	9d56                	add	s10,s10,s5
    800030b2:	000d0023          	sb	zero,0(s10)
    800030b6:	84ce                	mv	s1,s3
    800030b8:	bfbd                	j	80003036 <namex+0xa4>
  if(nameiparent){
    800030ba:	f20b0ae3          	beqz	s6,80002fee <namex+0x5c>
    iput(ip);
    800030be:	8552                	mv	a0,s4
    800030c0:	b69ff0ef          	jal	ra,80002c28 <iput>
    return 0;
    800030c4:	4a01                	li	s4,0
    800030c6:	b725                	j	80002fee <namex+0x5c>

00000000800030c8 <dirlink>:
{
    800030c8:	7139                	addi	sp,sp,-64
    800030ca:	fc06                	sd	ra,56(sp)
    800030cc:	f822                	sd	s0,48(sp)
    800030ce:	f426                	sd	s1,40(sp)
    800030d0:	f04a                	sd	s2,32(sp)
    800030d2:	ec4e                	sd	s3,24(sp)
    800030d4:	e852                	sd	s4,16(sp)
    800030d6:	0080                	addi	s0,sp,64
    800030d8:	892a                	mv	s2,a0
    800030da:	8a2e                	mv	s4,a1
    800030dc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800030de:	4601                	li	a2,0
    800030e0:	e17ff0ef          	jal	ra,80002ef6 <dirlookup>
    800030e4:	e52d                	bnez	a0,8000314e <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800030e6:	04c92483          	lw	s1,76(s2)
    800030ea:	c48d                	beqz	s1,80003114 <dirlink+0x4c>
    800030ec:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800030ee:	4741                	li	a4,16
    800030f0:	86a6                	mv	a3,s1
    800030f2:	fc040613          	addi	a2,s0,-64
    800030f6:	4581                	li	a1,0
    800030f8:	854a                	mv	a0,s2
    800030fa:	c01ff0ef          	jal	ra,80002cfa <readi>
    800030fe:	47c1                	li	a5,16
    80003100:	04f51b63          	bne	a0,a5,80003156 <dirlink+0x8e>
    if(de.inum == 0)
    80003104:	fc045783          	lhu	a5,-64(s0)
    80003108:	c791                	beqz	a5,80003114 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000310a:	24c1                	addiw	s1,s1,16
    8000310c:	04c92783          	lw	a5,76(s2)
    80003110:	fcf4efe3          	bltu	s1,a5,800030ee <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003114:	4639                	li	a2,14
    80003116:	85d2                	mv	a1,s4
    80003118:	fc240513          	addi	a0,s0,-62
    8000311c:	a9efd0ef          	jal	ra,800003ba <strncpy>
  de.inum = inum;
    80003120:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003124:	4741                	li	a4,16
    80003126:	86a6                	mv	a3,s1
    80003128:	fc040613          	addi	a2,s0,-64
    8000312c:	4581                	li	a1,0
    8000312e:	854a                	mv	a0,s2
    80003130:	cafff0ef          	jal	ra,80002dde <writei>
    80003134:	1541                	addi	a0,a0,-16
    80003136:	00a03533          	snez	a0,a0
    8000313a:	40a00533          	neg	a0,a0
}
    8000313e:	70e2                	ld	ra,56(sp)
    80003140:	7442                	ld	s0,48(sp)
    80003142:	74a2                	ld	s1,40(sp)
    80003144:	7902                	ld	s2,32(sp)
    80003146:	69e2                	ld	s3,24(sp)
    80003148:	6a42                	ld	s4,16(sp)
    8000314a:	6121                	addi	sp,sp,64
    8000314c:	8082                	ret
    iput(ip);
    8000314e:	adbff0ef          	jal	ra,80002c28 <iput>
    return -1;
    80003152:	557d                	li	a0,-1
    80003154:	b7ed                	j	8000313e <dirlink+0x76>
      panic("dirlink read");
    80003156:	00004517          	auipc	a0,0x4
    8000315a:	60a50513          	addi	a0,a0,1546 # 80007760 <syscalls+0x230>
    8000315e:	5c4020ef          	jal	ra,80005722 <panic>

0000000080003162 <namei>:

struct inode*
namei(char *path)
{
    80003162:	1101                	addi	sp,sp,-32
    80003164:	ec06                	sd	ra,24(sp)
    80003166:	e822                	sd	s0,16(sp)
    80003168:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000316a:	fe040613          	addi	a2,s0,-32
    8000316e:	4581                	li	a1,0
    80003170:	e23ff0ef          	jal	ra,80002f92 <namex>
}
    80003174:	60e2                	ld	ra,24(sp)
    80003176:	6442                	ld	s0,16(sp)
    80003178:	6105                	addi	sp,sp,32
    8000317a:	8082                	ret

000000008000317c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000317c:	1141                	addi	sp,sp,-16
    8000317e:	e406                	sd	ra,8(sp)
    80003180:	e022                	sd	s0,0(sp)
    80003182:	0800                	addi	s0,sp,16
    80003184:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003186:	4585                	li	a1,1
    80003188:	e0bff0ef          	jal	ra,80002f92 <namex>
}
    8000318c:	60a2                	ld	ra,8(sp)
    8000318e:	6402                	ld	s0,0(sp)
    80003190:	0141                	addi	sp,sp,16
    80003192:	8082                	ret

0000000080003194 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003194:	1101                	addi	sp,sp,-32
    80003196:	ec06                	sd	ra,24(sp)
    80003198:	e822                	sd	s0,16(sp)
    8000319a:	e426                	sd	s1,8(sp)
    8000319c:	e04a                	sd	s2,0(sp)
    8000319e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800031a0:	00015917          	auipc	s2,0x15
    800031a4:	af090913          	addi	s2,s2,-1296 # 80017c90 <log>
    800031a8:	01892583          	lw	a1,24(s2)
    800031ac:	02892503          	lw	a0,40(s2)
    800031b0:	9deff0ef          	jal	ra,8000238e <bread>
    800031b4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800031b6:	02c92683          	lw	a3,44(s2)
    800031ba:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800031bc:	02d05863          	blez	a3,800031ec <write_head+0x58>
    800031c0:	00015797          	auipc	a5,0x15
    800031c4:	b0078793          	addi	a5,a5,-1280 # 80017cc0 <log+0x30>
    800031c8:	05c50713          	addi	a4,a0,92
    800031cc:	36fd                	addiw	a3,a3,-1
    800031ce:	02069613          	slli	a2,a3,0x20
    800031d2:	01e65693          	srli	a3,a2,0x1e
    800031d6:	00015617          	auipc	a2,0x15
    800031da:	aee60613          	addi	a2,a2,-1298 # 80017cc4 <log+0x34>
    800031de:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800031e0:	4390                	lw	a2,0(a5)
    800031e2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800031e4:	0791                	addi	a5,a5,4
    800031e6:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800031e8:	fed79ce3          	bne	a5,a3,800031e0 <write_head+0x4c>
  }
  bwrite(buf);
    800031ec:	8526                	mv	a0,s1
    800031ee:	a76ff0ef          	jal	ra,80002464 <bwrite>
  brelse(buf);
    800031f2:	8526                	mv	a0,s1
    800031f4:	aa2ff0ef          	jal	ra,80002496 <brelse>
}
    800031f8:	60e2                	ld	ra,24(sp)
    800031fa:	6442                	ld	s0,16(sp)
    800031fc:	64a2                	ld	s1,8(sp)
    800031fe:	6902                	ld	s2,0(sp)
    80003200:	6105                	addi	sp,sp,32
    80003202:	8082                	ret

0000000080003204 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003204:	00015797          	auipc	a5,0x15
    80003208:	ab87a783          	lw	a5,-1352(a5) # 80017cbc <log+0x2c>
    8000320c:	08f05f63          	blez	a5,800032aa <install_trans+0xa6>
{
    80003210:	7139                	addi	sp,sp,-64
    80003212:	fc06                	sd	ra,56(sp)
    80003214:	f822                	sd	s0,48(sp)
    80003216:	f426                	sd	s1,40(sp)
    80003218:	f04a                	sd	s2,32(sp)
    8000321a:	ec4e                	sd	s3,24(sp)
    8000321c:	e852                	sd	s4,16(sp)
    8000321e:	e456                	sd	s5,8(sp)
    80003220:	e05a                	sd	s6,0(sp)
    80003222:	0080                	addi	s0,sp,64
    80003224:	8b2a                	mv	s6,a0
    80003226:	00015a97          	auipc	s5,0x15
    8000322a:	a9aa8a93          	addi	s5,s5,-1382 # 80017cc0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000322e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003230:	00015997          	auipc	s3,0x15
    80003234:	a6098993          	addi	s3,s3,-1440 # 80017c90 <log>
    80003238:	a829                	j	80003252 <install_trans+0x4e>
    brelse(lbuf);
    8000323a:	854a                	mv	a0,s2
    8000323c:	a5aff0ef          	jal	ra,80002496 <brelse>
    brelse(dbuf);
    80003240:	8526                	mv	a0,s1
    80003242:	a54ff0ef          	jal	ra,80002496 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003246:	2a05                	addiw	s4,s4,1
    80003248:	0a91                	addi	s5,s5,4
    8000324a:	02c9a783          	lw	a5,44(s3)
    8000324e:	04fa5463          	bge	s4,a5,80003296 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003252:	0189a583          	lw	a1,24(s3)
    80003256:	014585bb          	addw	a1,a1,s4
    8000325a:	2585                	addiw	a1,a1,1
    8000325c:	0289a503          	lw	a0,40(s3)
    80003260:	92eff0ef          	jal	ra,8000238e <bread>
    80003264:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003266:	000aa583          	lw	a1,0(s5)
    8000326a:	0289a503          	lw	a0,40(s3)
    8000326e:	920ff0ef          	jal	ra,8000238e <bread>
    80003272:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003274:	40000613          	li	a2,1024
    80003278:	05890593          	addi	a1,s2,88
    8000327c:	05850513          	addi	a0,a0,88
    80003280:	88efd0ef          	jal	ra,8000030e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003284:	8526                	mv	a0,s1
    80003286:	9deff0ef          	jal	ra,80002464 <bwrite>
    if(recovering == 0)
    8000328a:	fa0b18e3          	bnez	s6,8000323a <install_trans+0x36>
      bunpin(dbuf);
    8000328e:	8526                	mv	a0,s1
    80003290:	ac4ff0ef          	jal	ra,80002554 <bunpin>
    80003294:	b75d                	j	8000323a <install_trans+0x36>
}
    80003296:	70e2                	ld	ra,56(sp)
    80003298:	7442                	ld	s0,48(sp)
    8000329a:	74a2                	ld	s1,40(sp)
    8000329c:	7902                	ld	s2,32(sp)
    8000329e:	69e2                	ld	s3,24(sp)
    800032a0:	6a42                	ld	s4,16(sp)
    800032a2:	6aa2                	ld	s5,8(sp)
    800032a4:	6b02                	ld	s6,0(sp)
    800032a6:	6121                	addi	sp,sp,64
    800032a8:	8082                	ret
    800032aa:	8082                	ret

00000000800032ac <initlog>:
{
    800032ac:	7179                	addi	sp,sp,-48
    800032ae:	f406                	sd	ra,40(sp)
    800032b0:	f022                	sd	s0,32(sp)
    800032b2:	ec26                	sd	s1,24(sp)
    800032b4:	e84a                	sd	s2,16(sp)
    800032b6:	e44e                	sd	s3,8(sp)
    800032b8:	1800                	addi	s0,sp,48
    800032ba:	892a                	mv	s2,a0
    800032bc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800032be:	00015497          	auipc	s1,0x15
    800032c2:	9d248493          	addi	s1,s1,-1582 # 80017c90 <log>
    800032c6:	00004597          	auipc	a1,0x4
    800032ca:	4aa58593          	addi	a1,a1,1194 # 80007770 <syscalls+0x240>
    800032ce:	8526                	mv	a0,s1
    800032d0:	6e2020ef          	jal	ra,800059b2 <initlock>
  log.start = sb->logstart;
    800032d4:	0149a583          	lw	a1,20(s3)
    800032d8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800032da:	0109a783          	lw	a5,16(s3)
    800032de:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800032e0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800032e4:	854a                	mv	a0,s2
    800032e6:	8a8ff0ef          	jal	ra,8000238e <bread>
  log.lh.n = lh->n;
    800032ea:	4d34                	lw	a3,88(a0)
    800032ec:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800032ee:	02d05663          	blez	a3,8000331a <initlog+0x6e>
    800032f2:	05c50793          	addi	a5,a0,92
    800032f6:	00015717          	auipc	a4,0x15
    800032fa:	9ca70713          	addi	a4,a4,-1590 # 80017cc0 <log+0x30>
    800032fe:	36fd                	addiw	a3,a3,-1
    80003300:	02069613          	slli	a2,a3,0x20
    80003304:	01e65693          	srli	a3,a2,0x1e
    80003308:	06050613          	addi	a2,a0,96
    8000330c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000330e:	4390                	lw	a2,0(a5)
    80003310:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003312:	0791                	addi	a5,a5,4
    80003314:	0711                	addi	a4,a4,4
    80003316:	fed79ce3          	bne	a5,a3,8000330e <initlog+0x62>
  brelse(buf);
    8000331a:	97cff0ef          	jal	ra,80002496 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000331e:	4505                	li	a0,1
    80003320:	ee5ff0ef          	jal	ra,80003204 <install_trans>
  log.lh.n = 0;
    80003324:	00015797          	auipc	a5,0x15
    80003328:	9807ac23          	sw	zero,-1640(a5) # 80017cbc <log+0x2c>
  write_head(); // clear the log
    8000332c:	e69ff0ef          	jal	ra,80003194 <write_head>
}
    80003330:	70a2                	ld	ra,40(sp)
    80003332:	7402                	ld	s0,32(sp)
    80003334:	64e2                	ld	s1,24(sp)
    80003336:	6942                	ld	s2,16(sp)
    80003338:	69a2                	ld	s3,8(sp)
    8000333a:	6145                	addi	sp,sp,48
    8000333c:	8082                	ret

000000008000333e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000333e:	1101                	addi	sp,sp,-32
    80003340:	ec06                	sd	ra,24(sp)
    80003342:	e822                	sd	s0,16(sp)
    80003344:	e426                	sd	s1,8(sp)
    80003346:	e04a                	sd	s2,0(sp)
    80003348:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000334a:	00015517          	auipc	a0,0x15
    8000334e:	94650513          	addi	a0,a0,-1722 # 80017c90 <log>
    80003352:	6e0020ef          	jal	ra,80005a32 <acquire>
  while(1){
    if(log.committing){
    80003356:	00015497          	auipc	s1,0x15
    8000335a:	93a48493          	addi	s1,s1,-1734 # 80017c90 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000335e:	4979                	li	s2,30
    80003360:	a029                	j	8000336a <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003362:	85a6                	mv	a1,s1
    80003364:	8526                	mv	a0,s1
    80003366:	c02fe0ef          	jal	ra,80001768 <sleep>
    if(log.committing){
    8000336a:	50dc                	lw	a5,36(s1)
    8000336c:	fbfd                	bnez	a5,80003362 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000336e:	5098                	lw	a4,32(s1)
    80003370:	2705                	addiw	a4,a4,1
    80003372:	0007069b          	sext.w	a3,a4
    80003376:	0027179b          	slliw	a5,a4,0x2
    8000337a:	9fb9                	addw	a5,a5,a4
    8000337c:	0017979b          	slliw	a5,a5,0x1
    80003380:	54d8                	lw	a4,44(s1)
    80003382:	9fb9                	addw	a5,a5,a4
    80003384:	00f95763          	bge	s2,a5,80003392 <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003388:	85a6                	mv	a1,s1
    8000338a:	8526                	mv	a0,s1
    8000338c:	bdcfe0ef          	jal	ra,80001768 <sleep>
    80003390:	bfe9                	j	8000336a <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003392:	00015517          	auipc	a0,0x15
    80003396:	8fe50513          	addi	a0,a0,-1794 # 80017c90 <log>
    8000339a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000339c:	72e020ef          	jal	ra,80005aca <release>
      break;
    }
  }
}
    800033a0:	60e2                	ld	ra,24(sp)
    800033a2:	6442                	ld	s0,16(sp)
    800033a4:	64a2                	ld	s1,8(sp)
    800033a6:	6902                	ld	s2,0(sp)
    800033a8:	6105                	addi	sp,sp,32
    800033aa:	8082                	ret

00000000800033ac <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800033ac:	7139                	addi	sp,sp,-64
    800033ae:	fc06                	sd	ra,56(sp)
    800033b0:	f822                	sd	s0,48(sp)
    800033b2:	f426                	sd	s1,40(sp)
    800033b4:	f04a                	sd	s2,32(sp)
    800033b6:	ec4e                	sd	s3,24(sp)
    800033b8:	e852                	sd	s4,16(sp)
    800033ba:	e456                	sd	s5,8(sp)
    800033bc:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800033be:	00015497          	auipc	s1,0x15
    800033c2:	8d248493          	addi	s1,s1,-1838 # 80017c90 <log>
    800033c6:	8526                	mv	a0,s1
    800033c8:	66a020ef          	jal	ra,80005a32 <acquire>
  log.outstanding -= 1;
    800033cc:	509c                	lw	a5,32(s1)
    800033ce:	37fd                	addiw	a5,a5,-1
    800033d0:	0007891b          	sext.w	s2,a5
    800033d4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800033d6:	50dc                	lw	a5,36(s1)
    800033d8:	ef9d                	bnez	a5,80003416 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    800033da:	04091463          	bnez	s2,80003422 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800033de:	00015497          	auipc	s1,0x15
    800033e2:	8b248493          	addi	s1,s1,-1870 # 80017c90 <log>
    800033e6:	4785                	li	a5,1
    800033e8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800033ea:	8526                	mv	a0,s1
    800033ec:	6de020ef          	jal	ra,80005aca <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800033f0:	54dc                	lw	a5,44(s1)
    800033f2:	04f04b63          	bgtz	a5,80003448 <end_op+0x9c>
    acquire(&log.lock);
    800033f6:	00015497          	auipc	s1,0x15
    800033fa:	89a48493          	addi	s1,s1,-1894 # 80017c90 <log>
    800033fe:	8526                	mv	a0,s1
    80003400:	632020ef          	jal	ra,80005a32 <acquire>
    log.committing = 0;
    80003404:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003408:	8526                	mv	a0,s1
    8000340a:	baafe0ef          	jal	ra,800017b4 <wakeup>
    release(&log.lock);
    8000340e:	8526                	mv	a0,s1
    80003410:	6ba020ef          	jal	ra,80005aca <release>
}
    80003414:	a00d                	j	80003436 <end_op+0x8a>
    panic("log.committing");
    80003416:	00004517          	auipc	a0,0x4
    8000341a:	36250513          	addi	a0,a0,866 # 80007778 <syscalls+0x248>
    8000341e:	304020ef          	jal	ra,80005722 <panic>
    wakeup(&log);
    80003422:	00015497          	auipc	s1,0x15
    80003426:	86e48493          	addi	s1,s1,-1938 # 80017c90 <log>
    8000342a:	8526                	mv	a0,s1
    8000342c:	b88fe0ef          	jal	ra,800017b4 <wakeup>
  release(&log.lock);
    80003430:	8526                	mv	a0,s1
    80003432:	698020ef          	jal	ra,80005aca <release>
}
    80003436:	70e2                	ld	ra,56(sp)
    80003438:	7442                	ld	s0,48(sp)
    8000343a:	74a2                	ld	s1,40(sp)
    8000343c:	7902                	ld	s2,32(sp)
    8000343e:	69e2                	ld	s3,24(sp)
    80003440:	6a42                	ld	s4,16(sp)
    80003442:	6aa2                	ld	s5,8(sp)
    80003444:	6121                	addi	sp,sp,64
    80003446:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003448:	00015a97          	auipc	s5,0x15
    8000344c:	878a8a93          	addi	s5,s5,-1928 # 80017cc0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003450:	00015a17          	auipc	s4,0x15
    80003454:	840a0a13          	addi	s4,s4,-1984 # 80017c90 <log>
    80003458:	018a2583          	lw	a1,24(s4)
    8000345c:	012585bb          	addw	a1,a1,s2
    80003460:	2585                	addiw	a1,a1,1
    80003462:	028a2503          	lw	a0,40(s4)
    80003466:	f29fe0ef          	jal	ra,8000238e <bread>
    8000346a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000346c:	000aa583          	lw	a1,0(s5)
    80003470:	028a2503          	lw	a0,40(s4)
    80003474:	f1bfe0ef          	jal	ra,8000238e <bread>
    80003478:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000347a:	40000613          	li	a2,1024
    8000347e:	05850593          	addi	a1,a0,88
    80003482:	05848513          	addi	a0,s1,88
    80003486:	e89fc0ef          	jal	ra,8000030e <memmove>
    bwrite(to);  // write the log
    8000348a:	8526                	mv	a0,s1
    8000348c:	fd9fe0ef          	jal	ra,80002464 <bwrite>
    brelse(from);
    80003490:	854e                	mv	a0,s3
    80003492:	804ff0ef          	jal	ra,80002496 <brelse>
    brelse(to);
    80003496:	8526                	mv	a0,s1
    80003498:	ffffe0ef          	jal	ra,80002496 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000349c:	2905                	addiw	s2,s2,1
    8000349e:	0a91                	addi	s5,s5,4
    800034a0:	02ca2783          	lw	a5,44(s4)
    800034a4:	faf94ae3          	blt	s2,a5,80003458 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800034a8:	cedff0ef          	jal	ra,80003194 <write_head>
    install_trans(0); // Now install writes to home locations
    800034ac:	4501                	li	a0,0
    800034ae:	d57ff0ef          	jal	ra,80003204 <install_trans>
    log.lh.n = 0;
    800034b2:	00015797          	auipc	a5,0x15
    800034b6:	8007a523          	sw	zero,-2038(a5) # 80017cbc <log+0x2c>
    write_head();    // Erase the transaction from the log
    800034ba:	cdbff0ef          	jal	ra,80003194 <write_head>
    800034be:	bf25                	j	800033f6 <end_op+0x4a>

00000000800034c0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800034c0:	1101                	addi	sp,sp,-32
    800034c2:	ec06                	sd	ra,24(sp)
    800034c4:	e822                	sd	s0,16(sp)
    800034c6:	e426                	sd	s1,8(sp)
    800034c8:	e04a                	sd	s2,0(sp)
    800034ca:	1000                	addi	s0,sp,32
    800034cc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800034ce:	00014917          	auipc	s2,0x14
    800034d2:	7c290913          	addi	s2,s2,1986 # 80017c90 <log>
    800034d6:	854a                	mv	a0,s2
    800034d8:	55a020ef          	jal	ra,80005a32 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800034dc:	02c92603          	lw	a2,44(s2)
    800034e0:	47f5                	li	a5,29
    800034e2:	06c7c363          	blt	a5,a2,80003548 <log_write+0x88>
    800034e6:	00014797          	auipc	a5,0x14
    800034ea:	7c67a783          	lw	a5,1990(a5) # 80017cac <log+0x1c>
    800034ee:	37fd                	addiw	a5,a5,-1
    800034f0:	04f65c63          	bge	a2,a5,80003548 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800034f4:	00014797          	auipc	a5,0x14
    800034f8:	7bc7a783          	lw	a5,1980(a5) # 80017cb0 <log+0x20>
    800034fc:	04f05c63          	blez	a5,80003554 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003500:	4781                	li	a5,0
    80003502:	04c05f63          	blez	a2,80003560 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003506:	44cc                	lw	a1,12(s1)
    80003508:	00014717          	auipc	a4,0x14
    8000350c:	7b870713          	addi	a4,a4,1976 # 80017cc0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003510:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003512:	4314                	lw	a3,0(a4)
    80003514:	04b68663          	beq	a3,a1,80003560 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003518:	2785                	addiw	a5,a5,1
    8000351a:	0711                	addi	a4,a4,4
    8000351c:	fef61be3          	bne	a2,a5,80003512 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003520:	0621                	addi	a2,a2,8
    80003522:	060a                	slli	a2,a2,0x2
    80003524:	00014797          	auipc	a5,0x14
    80003528:	76c78793          	addi	a5,a5,1900 # 80017c90 <log>
    8000352c:	97b2                	add	a5,a5,a2
    8000352e:	44d8                	lw	a4,12(s1)
    80003530:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003532:	8526                	mv	a0,s1
    80003534:	fedfe0ef          	jal	ra,80002520 <bpin>
    log.lh.n++;
    80003538:	00014717          	auipc	a4,0x14
    8000353c:	75870713          	addi	a4,a4,1880 # 80017c90 <log>
    80003540:	575c                	lw	a5,44(a4)
    80003542:	2785                	addiw	a5,a5,1
    80003544:	d75c                	sw	a5,44(a4)
    80003546:	a80d                	j	80003578 <log_write+0xb8>
    panic("too big a transaction");
    80003548:	00004517          	auipc	a0,0x4
    8000354c:	24050513          	addi	a0,a0,576 # 80007788 <syscalls+0x258>
    80003550:	1d2020ef          	jal	ra,80005722 <panic>
    panic("log_write outside of trans");
    80003554:	00004517          	auipc	a0,0x4
    80003558:	24c50513          	addi	a0,a0,588 # 800077a0 <syscalls+0x270>
    8000355c:	1c6020ef          	jal	ra,80005722 <panic>
  log.lh.block[i] = b->blockno;
    80003560:	00878693          	addi	a3,a5,8
    80003564:	068a                	slli	a3,a3,0x2
    80003566:	00014717          	auipc	a4,0x14
    8000356a:	72a70713          	addi	a4,a4,1834 # 80017c90 <log>
    8000356e:	9736                	add	a4,a4,a3
    80003570:	44d4                	lw	a3,12(s1)
    80003572:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003574:	faf60fe3          	beq	a2,a5,80003532 <log_write+0x72>
  }
  release(&log.lock);
    80003578:	00014517          	auipc	a0,0x14
    8000357c:	71850513          	addi	a0,a0,1816 # 80017c90 <log>
    80003580:	54a020ef          	jal	ra,80005aca <release>
}
    80003584:	60e2                	ld	ra,24(sp)
    80003586:	6442                	ld	s0,16(sp)
    80003588:	64a2                	ld	s1,8(sp)
    8000358a:	6902                	ld	s2,0(sp)
    8000358c:	6105                	addi	sp,sp,32
    8000358e:	8082                	ret

0000000080003590 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003590:	1101                	addi	sp,sp,-32
    80003592:	ec06                	sd	ra,24(sp)
    80003594:	e822                	sd	s0,16(sp)
    80003596:	e426                	sd	s1,8(sp)
    80003598:	e04a                	sd	s2,0(sp)
    8000359a:	1000                	addi	s0,sp,32
    8000359c:	84aa                	mv	s1,a0
    8000359e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800035a0:	00004597          	auipc	a1,0x4
    800035a4:	22058593          	addi	a1,a1,544 # 800077c0 <syscalls+0x290>
    800035a8:	0521                	addi	a0,a0,8
    800035aa:	408020ef          	jal	ra,800059b2 <initlock>
  lk->name = name;
    800035ae:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800035b2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800035b6:	0204a423          	sw	zero,40(s1)
}
    800035ba:	60e2                	ld	ra,24(sp)
    800035bc:	6442                	ld	s0,16(sp)
    800035be:	64a2                	ld	s1,8(sp)
    800035c0:	6902                	ld	s2,0(sp)
    800035c2:	6105                	addi	sp,sp,32
    800035c4:	8082                	ret

00000000800035c6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800035c6:	1101                	addi	sp,sp,-32
    800035c8:	ec06                	sd	ra,24(sp)
    800035ca:	e822                	sd	s0,16(sp)
    800035cc:	e426                	sd	s1,8(sp)
    800035ce:	e04a                	sd	s2,0(sp)
    800035d0:	1000                	addi	s0,sp,32
    800035d2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800035d4:	00850913          	addi	s2,a0,8
    800035d8:	854a                	mv	a0,s2
    800035da:	458020ef          	jal	ra,80005a32 <acquire>
  while (lk->locked) {
    800035de:	409c                	lw	a5,0(s1)
    800035e0:	c799                	beqz	a5,800035ee <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800035e2:	85ca                	mv	a1,s2
    800035e4:	8526                	mv	a0,s1
    800035e6:	982fe0ef          	jal	ra,80001768 <sleep>
  while (lk->locked) {
    800035ea:	409c                	lw	a5,0(s1)
    800035ec:	fbfd                	bnez	a5,800035e2 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800035ee:	4785                	li	a5,1
    800035f0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800035f2:	babfd0ef          	jal	ra,8000119c <myproc>
    800035f6:	591c                	lw	a5,48(a0)
    800035f8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800035fa:	854a                	mv	a0,s2
    800035fc:	4ce020ef          	jal	ra,80005aca <release>
}
    80003600:	60e2                	ld	ra,24(sp)
    80003602:	6442                	ld	s0,16(sp)
    80003604:	64a2                	ld	s1,8(sp)
    80003606:	6902                	ld	s2,0(sp)
    80003608:	6105                	addi	sp,sp,32
    8000360a:	8082                	ret

000000008000360c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000360c:	1101                	addi	sp,sp,-32
    8000360e:	ec06                	sd	ra,24(sp)
    80003610:	e822                	sd	s0,16(sp)
    80003612:	e426                	sd	s1,8(sp)
    80003614:	e04a                	sd	s2,0(sp)
    80003616:	1000                	addi	s0,sp,32
    80003618:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000361a:	00850913          	addi	s2,a0,8
    8000361e:	854a                	mv	a0,s2
    80003620:	412020ef          	jal	ra,80005a32 <acquire>
  lk->locked = 0;
    80003624:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003628:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000362c:	8526                	mv	a0,s1
    8000362e:	986fe0ef          	jal	ra,800017b4 <wakeup>
  release(&lk->lk);
    80003632:	854a                	mv	a0,s2
    80003634:	496020ef          	jal	ra,80005aca <release>
}
    80003638:	60e2                	ld	ra,24(sp)
    8000363a:	6442                	ld	s0,16(sp)
    8000363c:	64a2                	ld	s1,8(sp)
    8000363e:	6902                	ld	s2,0(sp)
    80003640:	6105                	addi	sp,sp,32
    80003642:	8082                	ret

0000000080003644 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003644:	7179                	addi	sp,sp,-48
    80003646:	f406                	sd	ra,40(sp)
    80003648:	f022                	sd	s0,32(sp)
    8000364a:	ec26                	sd	s1,24(sp)
    8000364c:	e84a                	sd	s2,16(sp)
    8000364e:	e44e                	sd	s3,8(sp)
    80003650:	1800                	addi	s0,sp,48
    80003652:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80003654:	00850913          	addi	s2,a0,8
    80003658:	854a                	mv	a0,s2
    8000365a:	3d8020ef          	jal	ra,80005a32 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000365e:	409c                	lw	a5,0(s1)
    80003660:	ef89                	bnez	a5,8000367a <holdingsleep+0x36>
    80003662:	4481                	li	s1,0
  release(&lk->lk);
    80003664:	854a                	mv	a0,s2
    80003666:	464020ef          	jal	ra,80005aca <release>
  return r;
}
    8000366a:	8526                	mv	a0,s1
    8000366c:	70a2                	ld	ra,40(sp)
    8000366e:	7402                	ld	s0,32(sp)
    80003670:	64e2                	ld	s1,24(sp)
    80003672:	6942                	ld	s2,16(sp)
    80003674:	69a2                	ld	s3,8(sp)
    80003676:	6145                	addi	sp,sp,48
    80003678:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000367a:	0284a983          	lw	s3,40(s1)
    8000367e:	b1ffd0ef          	jal	ra,8000119c <myproc>
    80003682:	5904                	lw	s1,48(a0)
    80003684:	413484b3          	sub	s1,s1,s3
    80003688:	0014b493          	seqz	s1,s1
    8000368c:	bfe1                	j	80003664 <holdingsleep+0x20>

000000008000368e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000368e:	1141                	addi	sp,sp,-16
    80003690:	e406                	sd	ra,8(sp)
    80003692:	e022                	sd	s0,0(sp)
    80003694:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003696:	00004597          	auipc	a1,0x4
    8000369a:	13a58593          	addi	a1,a1,314 # 800077d0 <syscalls+0x2a0>
    8000369e:	00014517          	auipc	a0,0x14
    800036a2:	73a50513          	addi	a0,a0,1850 # 80017dd8 <ftable>
    800036a6:	30c020ef          	jal	ra,800059b2 <initlock>
}
    800036aa:	60a2                	ld	ra,8(sp)
    800036ac:	6402                	ld	s0,0(sp)
    800036ae:	0141                	addi	sp,sp,16
    800036b0:	8082                	ret

00000000800036b2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800036b2:	1101                	addi	sp,sp,-32
    800036b4:	ec06                	sd	ra,24(sp)
    800036b6:	e822                	sd	s0,16(sp)
    800036b8:	e426                	sd	s1,8(sp)
    800036ba:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800036bc:	00014517          	auipc	a0,0x14
    800036c0:	71c50513          	addi	a0,a0,1820 # 80017dd8 <ftable>
    800036c4:	36e020ef          	jal	ra,80005a32 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800036c8:	00014497          	auipc	s1,0x14
    800036cc:	72848493          	addi	s1,s1,1832 # 80017df0 <ftable+0x18>
    800036d0:	00015717          	auipc	a4,0x15
    800036d4:	6c070713          	addi	a4,a4,1728 # 80018d90 <disk>
    if(f->ref == 0){
    800036d8:	40dc                	lw	a5,4(s1)
    800036da:	cf89                	beqz	a5,800036f4 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800036dc:	02848493          	addi	s1,s1,40
    800036e0:	fee49ce3          	bne	s1,a4,800036d8 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800036e4:	00014517          	auipc	a0,0x14
    800036e8:	6f450513          	addi	a0,a0,1780 # 80017dd8 <ftable>
    800036ec:	3de020ef          	jal	ra,80005aca <release>
  return 0;
    800036f0:	4481                	li	s1,0
    800036f2:	a809                	j	80003704 <filealloc+0x52>
      f->ref = 1;
    800036f4:	4785                	li	a5,1
    800036f6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800036f8:	00014517          	auipc	a0,0x14
    800036fc:	6e050513          	addi	a0,a0,1760 # 80017dd8 <ftable>
    80003700:	3ca020ef          	jal	ra,80005aca <release>
}
    80003704:	8526                	mv	a0,s1
    80003706:	60e2                	ld	ra,24(sp)
    80003708:	6442                	ld	s0,16(sp)
    8000370a:	64a2                	ld	s1,8(sp)
    8000370c:	6105                	addi	sp,sp,32
    8000370e:	8082                	ret

0000000080003710 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003710:	1101                	addi	sp,sp,-32
    80003712:	ec06                	sd	ra,24(sp)
    80003714:	e822                	sd	s0,16(sp)
    80003716:	e426                	sd	s1,8(sp)
    80003718:	1000                	addi	s0,sp,32
    8000371a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000371c:	00014517          	auipc	a0,0x14
    80003720:	6bc50513          	addi	a0,a0,1724 # 80017dd8 <ftable>
    80003724:	30e020ef          	jal	ra,80005a32 <acquire>
  if(f->ref < 1)
    80003728:	40dc                	lw	a5,4(s1)
    8000372a:	02f05063          	blez	a5,8000374a <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000372e:	2785                	addiw	a5,a5,1
    80003730:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003732:	00014517          	auipc	a0,0x14
    80003736:	6a650513          	addi	a0,a0,1702 # 80017dd8 <ftable>
    8000373a:	390020ef          	jal	ra,80005aca <release>
  return f;
}
    8000373e:	8526                	mv	a0,s1
    80003740:	60e2                	ld	ra,24(sp)
    80003742:	6442                	ld	s0,16(sp)
    80003744:	64a2                	ld	s1,8(sp)
    80003746:	6105                	addi	sp,sp,32
    80003748:	8082                	ret
    panic("filedup");
    8000374a:	00004517          	auipc	a0,0x4
    8000374e:	08e50513          	addi	a0,a0,142 # 800077d8 <syscalls+0x2a8>
    80003752:	7d1010ef          	jal	ra,80005722 <panic>

0000000080003756 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003756:	7139                	addi	sp,sp,-64
    80003758:	fc06                	sd	ra,56(sp)
    8000375a:	f822                	sd	s0,48(sp)
    8000375c:	f426                	sd	s1,40(sp)
    8000375e:	f04a                	sd	s2,32(sp)
    80003760:	ec4e                	sd	s3,24(sp)
    80003762:	e852                	sd	s4,16(sp)
    80003764:	e456                	sd	s5,8(sp)
    80003766:	0080                	addi	s0,sp,64
    80003768:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000376a:	00014517          	auipc	a0,0x14
    8000376e:	66e50513          	addi	a0,a0,1646 # 80017dd8 <ftable>
    80003772:	2c0020ef          	jal	ra,80005a32 <acquire>
  if(f->ref < 1)
    80003776:	40dc                	lw	a5,4(s1)
    80003778:	04f05963          	blez	a5,800037ca <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    8000377c:	37fd                	addiw	a5,a5,-1
    8000377e:	0007871b          	sext.w	a4,a5
    80003782:	c0dc                	sw	a5,4(s1)
    80003784:	04e04963          	bgtz	a4,800037d6 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003788:	0004a903          	lw	s2,0(s1)
    8000378c:	0094ca83          	lbu	s5,9(s1)
    80003790:	0104ba03          	ld	s4,16(s1)
    80003794:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003798:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000379c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800037a0:	00014517          	auipc	a0,0x14
    800037a4:	63850513          	addi	a0,a0,1592 # 80017dd8 <ftable>
    800037a8:	322020ef          	jal	ra,80005aca <release>

  if(ff.type == FD_PIPE){
    800037ac:	4785                	li	a5,1
    800037ae:	04f90363          	beq	s2,a5,800037f4 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800037b2:	3979                	addiw	s2,s2,-2
    800037b4:	4785                	li	a5,1
    800037b6:	0327e663          	bltu	a5,s2,800037e2 <fileclose+0x8c>
    begin_op();
    800037ba:	b85ff0ef          	jal	ra,8000333e <begin_op>
    iput(ff.ip);
    800037be:	854e                	mv	a0,s3
    800037c0:	c68ff0ef          	jal	ra,80002c28 <iput>
    end_op();
    800037c4:	be9ff0ef          	jal	ra,800033ac <end_op>
    800037c8:	a829                	j	800037e2 <fileclose+0x8c>
    panic("fileclose");
    800037ca:	00004517          	auipc	a0,0x4
    800037ce:	01650513          	addi	a0,a0,22 # 800077e0 <syscalls+0x2b0>
    800037d2:	751010ef          	jal	ra,80005722 <panic>
    release(&ftable.lock);
    800037d6:	00014517          	auipc	a0,0x14
    800037da:	60250513          	addi	a0,a0,1538 # 80017dd8 <ftable>
    800037de:	2ec020ef          	jal	ra,80005aca <release>
  }
}
    800037e2:	70e2                	ld	ra,56(sp)
    800037e4:	7442                	ld	s0,48(sp)
    800037e6:	74a2                	ld	s1,40(sp)
    800037e8:	7902                	ld	s2,32(sp)
    800037ea:	69e2                	ld	s3,24(sp)
    800037ec:	6a42                	ld	s4,16(sp)
    800037ee:	6aa2                	ld	s5,8(sp)
    800037f0:	6121                	addi	sp,sp,64
    800037f2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800037f4:	85d6                	mv	a1,s5
    800037f6:	8552                	mv	a0,s4
    800037f8:	2ec000ef          	jal	ra,80003ae4 <pipeclose>
    800037fc:	b7dd                	j	800037e2 <fileclose+0x8c>

00000000800037fe <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800037fe:	715d                	addi	sp,sp,-80
    80003800:	e486                	sd	ra,72(sp)
    80003802:	e0a2                	sd	s0,64(sp)
    80003804:	fc26                	sd	s1,56(sp)
    80003806:	f84a                	sd	s2,48(sp)
    80003808:	f44e                	sd	s3,40(sp)
    8000380a:	0880                	addi	s0,sp,80
    8000380c:	84aa                	mv	s1,a0
    8000380e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003810:	98dfd0ef          	jal	ra,8000119c <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003814:	409c                	lw	a5,0(s1)
    80003816:	37f9                	addiw	a5,a5,-2
    80003818:	4705                	li	a4,1
    8000381a:	02f76f63          	bltu	a4,a5,80003858 <filestat+0x5a>
    8000381e:	892a                	mv	s2,a0
    ilock(f->ip);
    80003820:	6c88                	ld	a0,24(s1)
    80003822:	a88ff0ef          	jal	ra,80002aaa <ilock>
    stati(f->ip, &st);
    80003826:	fb840593          	addi	a1,s0,-72
    8000382a:	6c88                	ld	a0,24(s1)
    8000382c:	ca4ff0ef          	jal	ra,80002cd0 <stati>
    iunlock(f->ip);
    80003830:	6c88                	ld	a0,24(s1)
    80003832:	b22ff0ef          	jal	ra,80002b54 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003836:	46e1                	li	a3,24
    80003838:	fb840613          	addi	a2,s0,-72
    8000383c:	85ce                	mv	a1,s3
    8000383e:	05093503          	ld	a0,80(s2)
    80003842:	cfefd0ef          	jal	ra,80000d40 <copyout>
    80003846:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000384a:	60a6                	ld	ra,72(sp)
    8000384c:	6406                	ld	s0,64(sp)
    8000384e:	74e2                	ld	s1,56(sp)
    80003850:	7942                	ld	s2,48(sp)
    80003852:	79a2                	ld	s3,40(sp)
    80003854:	6161                	addi	sp,sp,80
    80003856:	8082                	ret
  return -1;
    80003858:	557d                	li	a0,-1
    8000385a:	bfc5                	j	8000384a <filestat+0x4c>

000000008000385c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000385c:	7179                	addi	sp,sp,-48
    8000385e:	f406                	sd	ra,40(sp)
    80003860:	f022                	sd	s0,32(sp)
    80003862:	ec26                	sd	s1,24(sp)
    80003864:	e84a                	sd	s2,16(sp)
    80003866:	e44e                	sd	s3,8(sp)
    80003868:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000386a:	00854783          	lbu	a5,8(a0)
    8000386e:	cbc1                	beqz	a5,800038fe <fileread+0xa2>
    80003870:	84aa                	mv	s1,a0
    80003872:	89ae                	mv	s3,a1
    80003874:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003876:	411c                	lw	a5,0(a0)
    80003878:	4705                	li	a4,1
    8000387a:	04e78363          	beq	a5,a4,800038c0 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000387e:	470d                	li	a4,3
    80003880:	04e78563          	beq	a5,a4,800038ca <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003884:	4709                	li	a4,2
    80003886:	06e79663          	bne	a5,a4,800038f2 <fileread+0x96>
    ilock(f->ip);
    8000388a:	6d08                	ld	a0,24(a0)
    8000388c:	a1eff0ef          	jal	ra,80002aaa <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003890:	874a                	mv	a4,s2
    80003892:	5094                	lw	a3,32(s1)
    80003894:	864e                	mv	a2,s3
    80003896:	4585                	li	a1,1
    80003898:	6c88                	ld	a0,24(s1)
    8000389a:	c60ff0ef          	jal	ra,80002cfa <readi>
    8000389e:	892a                	mv	s2,a0
    800038a0:	00a05563          	blez	a0,800038aa <fileread+0x4e>
      f->off += r;
    800038a4:	509c                	lw	a5,32(s1)
    800038a6:	9fa9                	addw	a5,a5,a0
    800038a8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800038aa:	6c88                	ld	a0,24(s1)
    800038ac:	aa8ff0ef          	jal	ra,80002b54 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800038b0:	854a                	mv	a0,s2
    800038b2:	70a2                	ld	ra,40(sp)
    800038b4:	7402                	ld	s0,32(sp)
    800038b6:	64e2                	ld	s1,24(sp)
    800038b8:	6942                	ld	s2,16(sp)
    800038ba:	69a2                	ld	s3,8(sp)
    800038bc:	6145                	addi	sp,sp,48
    800038be:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800038c0:	6908                	ld	a0,16(a0)
    800038c2:	34e000ef          	jal	ra,80003c10 <piperead>
    800038c6:	892a                	mv	s2,a0
    800038c8:	b7e5                	j	800038b0 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800038ca:	02451783          	lh	a5,36(a0)
    800038ce:	03079693          	slli	a3,a5,0x30
    800038d2:	92c1                	srli	a3,a3,0x30
    800038d4:	4725                	li	a4,9
    800038d6:	02d76663          	bltu	a4,a3,80003902 <fileread+0xa6>
    800038da:	0792                	slli	a5,a5,0x4
    800038dc:	00014717          	auipc	a4,0x14
    800038e0:	45c70713          	addi	a4,a4,1116 # 80017d38 <devsw>
    800038e4:	97ba                	add	a5,a5,a4
    800038e6:	639c                	ld	a5,0(a5)
    800038e8:	cf99                	beqz	a5,80003906 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    800038ea:	4505                	li	a0,1
    800038ec:	9782                	jalr	a5
    800038ee:	892a                	mv	s2,a0
    800038f0:	b7c1                	j	800038b0 <fileread+0x54>
    panic("fileread");
    800038f2:	00004517          	auipc	a0,0x4
    800038f6:	efe50513          	addi	a0,a0,-258 # 800077f0 <syscalls+0x2c0>
    800038fa:	629010ef          	jal	ra,80005722 <panic>
    return -1;
    800038fe:	597d                	li	s2,-1
    80003900:	bf45                	j	800038b0 <fileread+0x54>
      return -1;
    80003902:	597d                	li	s2,-1
    80003904:	b775                	j	800038b0 <fileread+0x54>
    80003906:	597d                	li	s2,-1
    80003908:	b765                	j	800038b0 <fileread+0x54>

000000008000390a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000390a:	715d                	addi	sp,sp,-80
    8000390c:	e486                	sd	ra,72(sp)
    8000390e:	e0a2                	sd	s0,64(sp)
    80003910:	fc26                	sd	s1,56(sp)
    80003912:	f84a                	sd	s2,48(sp)
    80003914:	f44e                	sd	s3,40(sp)
    80003916:	f052                	sd	s4,32(sp)
    80003918:	ec56                	sd	s5,24(sp)
    8000391a:	e85a                	sd	s6,16(sp)
    8000391c:	e45e                	sd	s7,8(sp)
    8000391e:	e062                	sd	s8,0(sp)
    80003920:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003922:	00954783          	lbu	a5,9(a0)
    80003926:	0e078863          	beqz	a5,80003a16 <filewrite+0x10c>
    8000392a:	892a                	mv	s2,a0
    8000392c:	8b2e                	mv	s6,a1
    8000392e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003930:	411c                	lw	a5,0(a0)
    80003932:	4705                	li	a4,1
    80003934:	02e78263          	beq	a5,a4,80003958 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003938:	470d                	li	a4,3
    8000393a:	02e78463          	beq	a5,a4,80003962 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000393e:	4709                	li	a4,2
    80003940:	0ce79563          	bne	a5,a4,80003a0a <filewrite+0x100>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003944:	0ac05163          	blez	a2,800039e6 <filewrite+0xdc>
    int i = 0;
    80003948:	4981                	li	s3,0
    8000394a:	6b85                	lui	s7,0x1
    8000394c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80003950:	6c05                	lui	s8,0x1
    80003952:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80003956:	a041                	j	800039d6 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80003958:	6908                	ld	a0,16(a0)
    8000395a:	1e2000ef          	jal	ra,80003b3c <pipewrite>
    8000395e:	8a2a                	mv	s4,a0
    80003960:	a071                	j	800039ec <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003962:	02451783          	lh	a5,36(a0)
    80003966:	03079693          	slli	a3,a5,0x30
    8000396a:	92c1                	srli	a3,a3,0x30
    8000396c:	4725                	li	a4,9
    8000396e:	0ad76663          	bltu	a4,a3,80003a1a <filewrite+0x110>
    80003972:	0792                	slli	a5,a5,0x4
    80003974:	00014717          	auipc	a4,0x14
    80003978:	3c470713          	addi	a4,a4,964 # 80017d38 <devsw>
    8000397c:	97ba                	add	a5,a5,a4
    8000397e:	679c                	ld	a5,8(a5)
    80003980:	cfd9                	beqz	a5,80003a1e <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80003982:	4505                	li	a0,1
    80003984:	9782                	jalr	a5
    80003986:	8a2a                	mv	s4,a0
    80003988:	a095                	j	800039ec <filewrite+0xe2>
    8000398a:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000398e:	9b1ff0ef          	jal	ra,8000333e <begin_op>
      ilock(f->ip);
    80003992:	01893503          	ld	a0,24(s2)
    80003996:	914ff0ef          	jal	ra,80002aaa <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000399a:	8756                	mv	a4,s5
    8000399c:	02092683          	lw	a3,32(s2)
    800039a0:	01698633          	add	a2,s3,s6
    800039a4:	4585                	li	a1,1
    800039a6:	01893503          	ld	a0,24(s2)
    800039aa:	c34ff0ef          	jal	ra,80002dde <writei>
    800039ae:	84aa                	mv	s1,a0
    800039b0:	00a05763          	blez	a0,800039be <filewrite+0xb4>
        f->off += r;
    800039b4:	02092783          	lw	a5,32(s2)
    800039b8:	9fa9                	addw	a5,a5,a0
    800039ba:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800039be:	01893503          	ld	a0,24(s2)
    800039c2:	992ff0ef          	jal	ra,80002b54 <iunlock>
      end_op();
    800039c6:	9e7ff0ef          	jal	ra,800033ac <end_op>

      if(r != n1){
    800039ca:	009a9f63          	bne	s5,s1,800039e8 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    800039ce:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800039d2:	0149db63          	bge	s3,s4,800039e8 <filewrite+0xde>
      int n1 = n - i;
    800039d6:	413a04bb          	subw	s1,s4,s3
    800039da:	0004879b          	sext.w	a5,s1
    800039de:	fafbd6e3          	bge	s7,a5,8000398a <filewrite+0x80>
    800039e2:	84e2                	mv	s1,s8
    800039e4:	b75d                	j	8000398a <filewrite+0x80>
    int i = 0;
    800039e6:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800039e8:	013a1f63          	bne	s4,s3,80003a06 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800039ec:	8552                	mv	a0,s4
    800039ee:	60a6                	ld	ra,72(sp)
    800039f0:	6406                	ld	s0,64(sp)
    800039f2:	74e2                	ld	s1,56(sp)
    800039f4:	7942                	ld	s2,48(sp)
    800039f6:	79a2                	ld	s3,40(sp)
    800039f8:	7a02                	ld	s4,32(sp)
    800039fa:	6ae2                	ld	s5,24(sp)
    800039fc:	6b42                	ld	s6,16(sp)
    800039fe:	6ba2                	ld	s7,8(sp)
    80003a00:	6c02                	ld	s8,0(sp)
    80003a02:	6161                	addi	sp,sp,80
    80003a04:	8082                	ret
    ret = (i == n ? n : -1);
    80003a06:	5a7d                	li	s4,-1
    80003a08:	b7d5                	j	800039ec <filewrite+0xe2>
    panic("filewrite");
    80003a0a:	00004517          	auipc	a0,0x4
    80003a0e:	df650513          	addi	a0,a0,-522 # 80007800 <syscalls+0x2d0>
    80003a12:	511010ef          	jal	ra,80005722 <panic>
    return -1;
    80003a16:	5a7d                	li	s4,-1
    80003a18:	bfd1                	j	800039ec <filewrite+0xe2>
      return -1;
    80003a1a:	5a7d                	li	s4,-1
    80003a1c:	bfc1                	j	800039ec <filewrite+0xe2>
    80003a1e:	5a7d                	li	s4,-1
    80003a20:	b7f1                	j	800039ec <filewrite+0xe2>

0000000080003a22 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003a22:	7179                	addi	sp,sp,-48
    80003a24:	f406                	sd	ra,40(sp)
    80003a26:	f022                	sd	s0,32(sp)
    80003a28:	ec26                	sd	s1,24(sp)
    80003a2a:	e84a                	sd	s2,16(sp)
    80003a2c:	e44e                	sd	s3,8(sp)
    80003a2e:	e052                	sd	s4,0(sp)
    80003a30:	1800                	addi	s0,sp,48
    80003a32:	84aa                	mv	s1,a0
    80003a34:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003a36:	0005b023          	sd	zero,0(a1)
    80003a3a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003a3e:	c75ff0ef          	jal	ra,800036b2 <filealloc>
    80003a42:	e088                	sd	a0,0(s1)
    80003a44:	cd35                	beqz	a0,80003ac0 <pipealloc+0x9e>
    80003a46:	c6dff0ef          	jal	ra,800036b2 <filealloc>
    80003a4a:	00aa3023          	sd	a0,0(s4)
    80003a4e:	c52d                	beqz	a0,80003ab8 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003a50:	f14fc0ef          	jal	ra,80000164 <kalloc>
    80003a54:	892a                	mv	s2,a0
    80003a56:	cd31                	beqz	a0,80003ab2 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80003a58:	4985                	li	s3,1
    80003a5a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003a5e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003a62:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003a66:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003a6a:	00004597          	auipc	a1,0x4
    80003a6e:	da658593          	addi	a1,a1,-602 # 80007810 <syscalls+0x2e0>
    80003a72:	741010ef          	jal	ra,800059b2 <initlock>
  (*f0)->type = FD_PIPE;
    80003a76:	609c                	ld	a5,0(s1)
    80003a78:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003a7c:	609c                	ld	a5,0(s1)
    80003a7e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003a82:	609c                	ld	a5,0(s1)
    80003a84:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003a88:	609c                	ld	a5,0(s1)
    80003a8a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003a8e:	000a3783          	ld	a5,0(s4)
    80003a92:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003a96:	000a3783          	ld	a5,0(s4)
    80003a9a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003a9e:	000a3783          	ld	a5,0(s4)
    80003aa2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003aa6:	000a3783          	ld	a5,0(s4)
    80003aaa:	0127b823          	sd	s2,16(a5)
  return 0;
    80003aae:	4501                	li	a0,0
    80003ab0:	a005                	j	80003ad0 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003ab2:	6088                	ld	a0,0(s1)
    80003ab4:	e501                	bnez	a0,80003abc <pipealloc+0x9a>
    80003ab6:	a029                	j	80003ac0 <pipealloc+0x9e>
    80003ab8:	6088                	ld	a0,0(s1)
    80003aba:	c11d                	beqz	a0,80003ae0 <pipealloc+0xbe>
    fileclose(*f0);
    80003abc:	c9bff0ef          	jal	ra,80003756 <fileclose>
  if(*f1)
    80003ac0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003ac4:	557d                	li	a0,-1
  if(*f1)
    80003ac6:	c789                	beqz	a5,80003ad0 <pipealloc+0xae>
    fileclose(*f1);
    80003ac8:	853e                	mv	a0,a5
    80003aca:	c8dff0ef          	jal	ra,80003756 <fileclose>
  return -1;
    80003ace:	557d                	li	a0,-1
}
    80003ad0:	70a2                	ld	ra,40(sp)
    80003ad2:	7402                	ld	s0,32(sp)
    80003ad4:	64e2                	ld	s1,24(sp)
    80003ad6:	6942                	ld	s2,16(sp)
    80003ad8:	69a2                	ld	s3,8(sp)
    80003ada:	6a02                	ld	s4,0(sp)
    80003adc:	6145                	addi	sp,sp,48
    80003ade:	8082                	ret
  return -1;
    80003ae0:	557d                	li	a0,-1
    80003ae2:	b7fd                	j	80003ad0 <pipealloc+0xae>

0000000080003ae4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003ae4:	1101                	addi	sp,sp,-32
    80003ae6:	ec06                	sd	ra,24(sp)
    80003ae8:	e822                	sd	s0,16(sp)
    80003aea:	e426                	sd	s1,8(sp)
    80003aec:	e04a                	sd	s2,0(sp)
    80003aee:	1000                	addi	s0,sp,32
    80003af0:	84aa                	mv	s1,a0
    80003af2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003af4:	73f010ef          	jal	ra,80005a32 <acquire>
  if(writable){
    80003af8:	02090763          	beqz	s2,80003b26 <pipeclose+0x42>
    pi->writeopen = 0;
    80003afc:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003b00:	21848513          	addi	a0,s1,536
    80003b04:	cb1fd0ef          	jal	ra,800017b4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003b08:	2204b783          	ld	a5,544(s1)
    80003b0c:	e785                	bnez	a5,80003b34 <pipeclose+0x50>
    release(&pi->lock);
    80003b0e:	8526                	mv	a0,s1
    80003b10:	7bb010ef          	jal	ra,80005aca <release>
    kfree((char*)pi);
    80003b14:	8526                	mv	a0,s1
    80003b16:	d5afc0ef          	jal	ra,80000070 <kfree>
  } else
    release(&pi->lock);
}
    80003b1a:	60e2                	ld	ra,24(sp)
    80003b1c:	6442                	ld	s0,16(sp)
    80003b1e:	64a2                	ld	s1,8(sp)
    80003b20:	6902                	ld	s2,0(sp)
    80003b22:	6105                	addi	sp,sp,32
    80003b24:	8082                	ret
    pi->readopen = 0;
    80003b26:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003b2a:	21c48513          	addi	a0,s1,540
    80003b2e:	c87fd0ef          	jal	ra,800017b4 <wakeup>
    80003b32:	bfd9                	j	80003b08 <pipeclose+0x24>
    release(&pi->lock);
    80003b34:	8526                	mv	a0,s1
    80003b36:	795010ef          	jal	ra,80005aca <release>
}
    80003b3a:	b7c5                	j	80003b1a <pipeclose+0x36>

0000000080003b3c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003b3c:	711d                	addi	sp,sp,-96
    80003b3e:	ec86                	sd	ra,88(sp)
    80003b40:	e8a2                	sd	s0,80(sp)
    80003b42:	e4a6                	sd	s1,72(sp)
    80003b44:	e0ca                	sd	s2,64(sp)
    80003b46:	fc4e                	sd	s3,56(sp)
    80003b48:	f852                	sd	s4,48(sp)
    80003b4a:	f456                	sd	s5,40(sp)
    80003b4c:	f05a                	sd	s6,32(sp)
    80003b4e:	ec5e                	sd	s7,24(sp)
    80003b50:	e862                	sd	s8,16(sp)
    80003b52:	1080                	addi	s0,sp,96
    80003b54:	84aa                	mv	s1,a0
    80003b56:	8aae                	mv	s5,a1
    80003b58:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003b5a:	e42fd0ef          	jal	ra,8000119c <myproc>
    80003b5e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003b60:	8526                	mv	a0,s1
    80003b62:	6d1010ef          	jal	ra,80005a32 <acquire>
  while(i < n){
    80003b66:	09405c63          	blez	s4,80003bfe <pipewrite+0xc2>
  int i = 0;
    80003b6a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003b6c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003b6e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003b72:	21c48b93          	addi	s7,s1,540
    80003b76:	a81d                	j	80003bac <pipewrite+0x70>
      release(&pi->lock);
    80003b78:	8526                	mv	a0,s1
    80003b7a:	751010ef          	jal	ra,80005aca <release>
      return -1;
    80003b7e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003b80:	854a                	mv	a0,s2
    80003b82:	60e6                	ld	ra,88(sp)
    80003b84:	6446                	ld	s0,80(sp)
    80003b86:	64a6                	ld	s1,72(sp)
    80003b88:	6906                	ld	s2,64(sp)
    80003b8a:	79e2                	ld	s3,56(sp)
    80003b8c:	7a42                	ld	s4,48(sp)
    80003b8e:	7aa2                	ld	s5,40(sp)
    80003b90:	7b02                	ld	s6,32(sp)
    80003b92:	6be2                	ld	s7,24(sp)
    80003b94:	6c42                	ld	s8,16(sp)
    80003b96:	6125                	addi	sp,sp,96
    80003b98:	8082                	ret
      wakeup(&pi->nread);
    80003b9a:	8562                	mv	a0,s8
    80003b9c:	c19fd0ef          	jal	ra,800017b4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003ba0:	85a6                	mv	a1,s1
    80003ba2:	855e                	mv	a0,s7
    80003ba4:	bc5fd0ef          	jal	ra,80001768 <sleep>
  while(i < n){
    80003ba8:	05495c63          	bge	s2,s4,80003c00 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80003bac:	2204a783          	lw	a5,544(s1)
    80003bb0:	d7e1                	beqz	a5,80003b78 <pipewrite+0x3c>
    80003bb2:	854e                	mv	a0,s3
    80003bb4:	dedfd0ef          	jal	ra,800019a0 <killed>
    80003bb8:	f161                	bnez	a0,80003b78 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003bba:	2184a783          	lw	a5,536(s1)
    80003bbe:	21c4a703          	lw	a4,540(s1)
    80003bc2:	2007879b          	addiw	a5,a5,512
    80003bc6:	fcf70ae3          	beq	a4,a5,80003b9a <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003bca:	4685                	li	a3,1
    80003bcc:	01590633          	add	a2,s2,s5
    80003bd0:	faf40593          	addi	a1,s0,-81
    80003bd4:	0509b503          	ld	a0,80(s3)
    80003bd8:	a20fd0ef          	jal	ra,80000df8 <copyin>
    80003bdc:	03650263          	beq	a0,s6,80003c00 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003be0:	21c4a783          	lw	a5,540(s1)
    80003be4:	0017871b          	addiw	a4,a5,1
    80003be8:	20e4ae23          	sw	a4,540(s1)
    80003bec:	1ff7f793          	andi	a5,a5,511
    80003bf0:	97a6                	add	a5,a5,s1
    80003bf2:	faf44703          	lbu	a4,-81(s0)
    80003bf6:	00e78c23          	sb	a4,24(a5)
      i++;
    80003bfa:	2905                	addiw	s2,s2,1
    80003bfc:	b775                	j	80003ba8 <pipewrite+0x6c>
  int i = 0;
    80003bfe:	4901                	li	s2,0
  wakeup(&pi->nread);
    80003c00:	21848513          	addi	a0,s1,536
    80003c04:	bb1fd0ef          	jal	ra,800017b4 <wakeup>
  release(&pi->lock);
    80003c08:	8526                	mv	a0,s1
    80003c0a:	6c1010ef          	jal	ra,80005aca <release>
  return i;
    80003c0e:	bf8d                	j	80003b80 <pipewrite+0x44>

0000000080003c10 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003c10:	715d                	addi	sp,sp,-80
    80003c12:	e486                	sd	ra,72(sp)
    80003c14:	e0a2                	sd	s0,64(sp)
    80003c16:	fc26                	sd	s1,56(sp)
    80003c18:	f84a                	sd	s2,48(sp)
    80003c1a:	f44e                	sd	s3,40(sp)
    80003c1c:	f052                	sd	s4,32(sp)
    80003c1e:	ec56                	sd	s5,24(sp)
    80003c20:	e85a                	sd	s6,16(sp)
    80003c22:	0880                	addi	s0,sp,80
    80003c24:	84aa                	mv	s1,a0
    80003c26:	892e                	mv	s2,a1
    80003c28:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003c2a:	d72fd0ef          	jal	ra,8000119c <myproc>
    80003c2e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003c30:	8526                	mv	a0,s1
    80003c32:	601010ef          	jal	ra,80005a32 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003c36:	2184a703          	lw	a4,536(s1)
    80003c3a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003c3e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003c42:	02f71363          	bne	a4,a5,80003c68 <piperead+0x58>
    80003c46:	2244a783          	lw	a5,548(s1)
    80003c4a:	cf99                	beqz	a5,80003c68 <piperead+0x58>
    if(killed(pr)){
    80003c4c:	8552                	mv	a0,s4
    80003c4e:	d53fd0ef          	jal	ra,800019a0 <killed>
    80003c52:	e149                	bnez	a0,80003cd4 <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003c54:	85a6                	mv	a1,s1
    80003c56:	854e                	mv	a0,s3
    80003c58:	b11fd0ef          	jal	ra,80001768 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003c5c:	2184a703          	lw	a4,536(s1)
    80003c60:	21c4a783          	lw	a5,540(s1)
    80003c64:	fef701e3          	beq	a4,a5,80003c46 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003c68:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003c6a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003c6c:	05505263          	blez	s5,80003cb0 <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    80003c70:	2184a783          	lw	a5,536(s1)
    80003c74:	21c4a703          	lw	a4,540(s1)
    80003c78:	02f70c63          	beq	a4,a5,80003cb0 <piperead+0xa0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003c7c:	0017871b          	addiw	a4,a5,1
    80003c80:	20e4ac23          	sw	a4,536(s1)
    80003c84:	1ff7f793          	andi	a5,a5,511
    80003c88:	97a6                	add	a5,a5,s1
    80003c8a:	0187c783          	lbu	a5,24(a5)
    80003c8e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003c92:	4685                	li	a3,1
    80003c94:	fbf40613          	addi	a2,s0,-65
    80003c98:	85ca                	mv	a1,s2
    80003c9a:	050a3503          	ld	a0,80(s4)
    80003c9e:	8a2fd0ef          	jal	ra,80000d40 <copyout>
    80003ca2:	01650763          	beq	a0,s6,80003cb0 <piperead+0xa0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003ca6:	2985                	addiw	s3,s3,1
    80003ca8:	0905                	addi	s2,s2,1
    80003caa:	fd3a93e3          	bne	s5,s3,80003c70 <piperead+0x60>
    80003cae:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003cb0:	21c48513          	addi	a0,s1,540
    80003cb4:	b01fd0ef          	jal	ra,800017b4 <wakeup>
  release(&pi->lock);
    80003cb8:	8526                	mv	a0,s1
    80003cba:	611010ef          	jal	ra,80005aca <release>
  return i;
}
    80003cbe:	854e                	mv	a0,s3
    80003cc0:	60a6                	ld	ra,72(sp)
    80003cc2:	6406                	ld	s0,64(sp)
    80003cc4:	74e2                	ld	s1,56(sp)
    80003cc6:	7942                	ld	s2,48(sp)
    80003cc8:	79a2                	ld	s3,40(sp)
    80003cca:	7a02                	ld	s4,32(sp)
    80003ccc:	6ae2                	ld	s5,24(sp)
    80003cce:	6b42                	ld	s6,16(sp)
    80003cd0:	6161                	addi	sp,sp,80
    80003cd2:	8082                	ret
      release(&pi->lock);
    80003cd4:	8526                	mv	a0,s1
    80003cd6:	5f5010ef          	jal	ra,80005aca <release>
      return -1;
    80003cda:	59fd                	li	s3,-1
    80003cdc:	b7cd                	j	80003cbe <piperead+0xae>

0000000080003cde <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80003cde:	1141                	addi	sp,sp,-16
    80003ce0:	e422                	sd	s0,8(sp)
    80003ce2:	0800                	addi	s0,sp,16
    80003ce4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003ce6:	8905                	andi	a0,a0,1
    80003ce8:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003cea:	8b89                	andi	a5,a5,2
    80003cec:	c399                	beqz	a5,80003cf2 <flags2perm+0x14>
      perm |= PTE_W;
    80003cee:	00456513          	ori	a0,a0,4
    return perm;
}
    80003cf2:	6422                	ld	s0,8(sp)
    80003cf4:	0141                	addi	sp,sp,16
    80003cf6:	8082                	ret

0000000080003cf8 <exec>:

int
exec(char *path, char **argv)
{
    80003cf8:	de010113          	addi	sp,sp,-544
    80003cfc:	20113c23          	sd	ra,536(sp)
    80003d00:	20813823          	sd	s0,528(sp)
    80003d04:	20913423          	sd	s1,520(sp)
    80003d08:	21213023          	sd	s2,512(sp)
    80003d0c:	ffce                	sd	s3,504(sp)
    80003d0e:	fbd2                	sd	s4,496(sp)
    80003d10:	f7d6                	sd	s5,488(sp)
    80003d12:	f3da                	sd	s6,480(sp)
    80003d14:	efde                	sd	s7,472(sp)
    80003d16:	ebe2                	sd	s8,464(sp)
    80003d18:	e7e6                	sd	s9,456(sp)
    80003d1a:	e3ea                	sd	s10,448(sp)
    80003d1c:	ff6e                	sd	s11,440(sp)
    80003d1e:	1400                	addi	s0,sp,544
    80003d20:	892a                	mv	s2,a0
    80003d22:	dea43423          	sd	a0,-536(s0)
    80003d26:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003d2a:	c72fd0ef          	jal	ra,8000119c <myproc>
    80003d2e:	84aa                	mv	s1,a0

  begin_op();
    80003d30:	e0eff0ef          	jal	ra,8000333e <begin_op>

  if((ip = namei(path)) == 0){
    80003d34:	854a                	mv	a0,s2
    80003d36:	c2cff0ef          	jal	ra,80003162 <namei>
    80003d3a:	c13d                	beqz	a0,80003da0 <exec+0xa8>
    80003d3c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003d3e:	d6dfe0ef          	jal	ra,80002aaa <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003d42:	04000713          	li	a4,64
    80003d46:	4681                	li	a3,0
    80003d48:	e5040613          	addi	a2,s0,-432
    80003d4c:	4581                	li	a1,0
    80003d4e:	8556                	mv	a0,s5
    80003d50:	fabfe0ef          	jal	ra,80002cfa <readi>
    80003d54:	04000793          	li	a5,64
    80003d58:	00f51a63          	bne	a0,a5,80003d6c <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80003d5c:	e5042703          	lw	a4,-432(s0)
    80003d60:	464c47b7          	lui	a5,0x464c4
    80003d64:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003d68:	04f70063          	beq	a4,a5,80003da8 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003d6c:	8556                	mv	a0,s5
    80003d6e:	f43fe0ef          	jal	ra,80002cb0 <iunlockput>
    end_op();
    80003d72:	e3aff0ef          	jal	ra,800033ac <end_op>
  }
  return -1;
    80003d76:	557d                	li	a0,-1
}
    80003d78:	21813083          	ld	ra,536(sp)
    80003d7c:	21013403          	ld	s0,528(sp)
    80003d80:	20813483          	ld	s1,520(sp)
    80003d84:	20013903          	ld	s2,512(sp)
    80003d88:	79fe                	ld	s3,504(sp)
    80003d8a:	7a5e                	ld	s4,496(sp)
    80003d8c:	7abe                	ld	s5,488(sp)
    80003d8e:	7b1e                	ld	s6,480(sp)
    80003d90:	6bfe                	ld	s7,472(sp)
    80003d92:	6c5e                	ld	s8,464(sp)
    80003d94:	6cbe                	ld	s9,456(sp)
    80003d96:	6d1e                	ld	s10,448(sp)
    80003d98:	7dfa                	ld	s11,440(sp)
    80003d9a:	22010113          	addi	sp,sp,544
    80003d9e:	8082                	ret
    end_op();
    80003da0:	e0cff0ef          	jal	ra,800033ac <end_op>
    return -1;
    80003da4:	557d                	li	a0,-1
    80003da6:	bfc9                	j	80003d78 <exec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    80003da8:	8526                	mv	a0,s1
    80003daa:	c9afd0ef          	jal	ra,80001244 <proc_pagetable>
    80003dae:	8b2a                	mv	s6,a0
    80003db0:	dd55                	beqz	a0,80003d6c <exec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003db2:	e7042783          	lw	a5,-400(s0)
    80003db6:	e8845703          	lhu	a4,-376(s0)
    80003dba:	c325                	beqz	a4,80003e1a <exec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003dbc:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003dbe:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80003dc2:	6a05                	lui	s4,0x1
    80003dc4:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80003dc8:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80003dcc:	6d85                	lui	s11,0x1
    80003dce:	7d7d                	lui	s10,0xfffff
    80003dd0:	a409                	j	80003fd2 <exec+0x2da>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80003dd2:	00004517          	auipc	a0,0x4
    80003dd6:	a4650513          	addi	a0,a0,-1466 # 80007818 <syscalls+0x2e8>
    80003dda:	149010ef          	jal	ra,80005722 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003dde:	874a                	mv	a4,s2
    80003de0:	009c86bb          	addw	a3,s9,s1
    80003de4:	4581                	li	a1,0
    80003de6:	8556                	mv	a0,s5
    80003de8:	f13fe0ef          	jal	ra,80002cfa <readi>
    80003dec:	2501                	sext.w	a0,a0
    80003dee:	18a91163          	bne	s2,a0,80003f70 <exec+0x278>
  for(i = 0; i < sz; i += PGSIZE){
    80003df2:	009d84bb          	addw	s1,s11,s1
    80003df6:	013d09bb          	addw	s3,s10,s3
    80003dfa:	1b74fc63          	bgeu	s1,s7,80003fb2 <exec+0x2ba>
    pa = walkaddr(pagetable, va + i);
    80003dfe:	02049593          	slli	a1,s1,0x20
    80003e02:	9181                	srli	a1,a1,0x20
    80003e04:	95e2                	add	a1,a1,s8
    80003e06:	855a                	mv	a0,s6
    80003e08:	847fc0ef          	jal	ra,8000064e <walkaddr>
    80003e0c:	862a                	mv	a2,a0
    if(pa == 0)
    80003e0e:	d171                	beqz	a0,80003dd2 <exec+0xda>
      n = PGSIZE;
    80003e10:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80003e12:	fd49f6e3          	bgeu	s3,s4,80003dde <exec+0xe6>
      n = sz - i;
    80003e16:	894e                	mv	s2,s3
    80003e18:	b7d9                	j	80003dde <exec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003e1a:	4901                	li	s2,0
  iunlockput(ip);
    80003e1c:	8556                	mv	a0,s5
    80003e1e:	e93fe0ef          	jal	ra,80002cb0 <iunlockput>
  end_op();
    80003e22:	d8aff0ef          	jal	ra,800033ac <end_op>
  p = myproc();
    80003e26:	b76fd0ef          	jal	ra,8000119c <myproc>
    80003e2a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80003e2c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80003e30:	6785                	lui	a5,0x1
    80003e32:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80003e34:	97ca                	add	a5,a5,s2
    80003e36:	777d                	lui	a4,0xfffff
    80003e38:	8ff9                	and	a5,a5,a4
    80003e3a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003e3e:	4691                	li	a3,4
    80003e40:	6609                	lui	a2,0x2
    80003e42:	963e                	add	a2,a2,a5
    80003e44:	85be                	mv	a1,a5
    80003e46:	855a                	mv	a0,s6
    80003e48:	c1bfc0ef          	jal	ra,80000a62 <uvmalloc>
    80003e4c:	8c2a                	mv	s8,a0
  ip = 0;
    80003e4e:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003e50:	12050063          	beqz	a0,80003f70 <exec+0x278>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003e54:	75f9                	lui	a1,0xffffe
    80003e56:	95aa                	add	a1,a1,a0
    80003e58:	855a                	mv	a0,s6
    80003e5a:	ebdfc0ef          	jal	ra,80000d16 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003e5e:	7afd                	lui	s5,0xfffff
    80003e60:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80003e62:	df043783          	ld	a5,-528(s0)
    80003e66:	6388                	ld	a0,0(a5)
    80003e68:	c135                	beqz	a0,80003ecc <exec+0x1d4>
    80003e6a:	e9040993          	addi	s3,s0,-368
    80003e6e:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80003e72:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003e74:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003e76:	db4fc0ef          	jal	ra,8000042a <strlen>
    80003e7a:	0015079b          	addiw	a5,a0,1
    80003e7e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003e82:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003e86:	11596a63          	bltu	s2,s5,80003f9a <exec+0x2a2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003e8a:	df043d83          	ld	s11,-528(s0)
    80003e8e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80003e92:	8552                	mv	a0,s4
    80003e94:	d96fc0ef          	jal	ra,8000042a <strlen>
    80003e98:	0015069b          	addiw	a3,a0,1
    80003e9c:	8652                	mv	a2,s4
    80003e9e:	85ca                	mv	a1,s2
    80003ea0:	855a                	mv	a0,s6
    80003ea2:	e9ffc0ef          	jal	ra,80000d40 <copyout>
    80003ea6:	0e054e63          	bltz	a0,80003fa2 <exec+0x2aa>
    ustack[argc] = sp;
    80003eaa:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003eae:	0485                	addi	s1,s1,1
    80003eb0:	008d8793          	addi	a5,s11,8
    80003eb4:	def43823          	sd	a5,-528(s0)
    80003eb8:	008db503          	ld	a0,8(s11)
    80003ebc:	c911                	beqz	a0,80003ed0 <exec+0x1d8>
    if(argc >= MAXARG)
    80003ebe:	09a1                	addi	s3,s3,8
    80003ec0:	fb3c9be3          	bne	s9,s3,80003e76 <exec+0x17e>
  sz = sz1;
    80003ec4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003ec8:	4a81                	li	s5,0
    80003eca:	a05d                	j	80003f70 <exec+0x278>
  sp = sz;
    80003ecc:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003ece:	4481                	li	s1,0
  ustack[argc] = 0;
    80003ed0:	00349793          	slli	a5,s1,0x3
    80003ed4:	f9078793          	addi	a5,a5,-112
    80003ed8:	97a2                	add	a5,a5,s0
    80003eda:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003ede:	00148693          	addi	a3,s1,1
    80003ee2:	068e                	slli	a3,a3,0x3
    80003ee4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003ee8:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80003eec:	01597663          	bgeu	s2,s5,80003ef8 <exec+0x200>
  sz = sz1;
    80003ef0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003ef4:	4a81                	li	s5,0
    80003ef6:	a8ad                	j	80003f70 <exec+0x278>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003ef8:	e9040613          	addi	a2,s0,-368
    80003efc:	85ca                	mv	a1,s2
    80003efe:	855a                	mv	a0,s6
    80003f00:	e41fc0ef          	jal	ra,80000d40 <copyout>
    80003f04:	0a054363          	bltz	a0,80003faa <exec+0x2b2>
  p->trapframe->a1 = sp;
    80003f08:	058bb783          	ld	a5,88(s7)
    80003f0c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003f10:	de843783          	ld	a5,-536(s0)
    80003f14:	0007c703          	lbu	a4,0(a5)
    80003f18:	cf11                	beqz	a4,80003f34 <exec+0x23c>
    80003f1a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003f1c:	02f00693          	li	a3,47
    80003f20:	a039                	j	80003f2e <exec+0x236>
      last = s+1;
    80003f22:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80003f26:	0785                	addi	a5,a5,1
    80003f28:	fff7c703          	lbu	a4,-1(a5)
    80003f2c:	c701                	beqz	a4,80003f34 <exec+0x23c>
    if(*s == '/')
    80003f2e:	fed71ce3          	bne	a4,a3,80003f26 <exec+0x22e>
    80003f32:	bfc5                	j	80003f22 <exec+0x22a>
  safestrcpy(p->name, last, sizeof(p->name));
    80003f34:	4641                	li	a2,16
    80003f36:	de843583          	ld	a1,-536(s0)
    80003f3a:	158b8513          	addi	a0,s7,344
    80003f3e:	cbafc0ef          	jal	ra,800003f8 <safestrcpy>
  oldpagetable = p->pagetable;
    80003f42:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80003f46:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80003f4a:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003f4e:	058bb783          	ld	a5,88(s7)
    80003f52:	e6843703          	ld	a4,-408(s0)
    80003f56:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003f58:	058bb783          	ld	a5,88(s7)
    80003f5c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003f60:	85ea                	mv	a1,s10
    80003f62:	b66fd0ef          	jal	ra,800012c8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003f66:	0004851b          	sext.w	a0,s1
    80003f6a:	b539                	j	80003d78 <exec+0x80>
    80003f6c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80003f70:	df843583          	ld	a1,-520(s0)
    80003f74:	855a                	mv	a0,s6
    80003f76:	b52fd0ef          	jal	ra,800012c8 <proc_freepagetable>
  if(ip){
    80003f7a:	de0a99e3          	bnez	s5,80003d6c <exec+0x74>
  return -1;
    80003f7e:	557d                	li	a0,-1
    80003f80:	bbe5                	j	80003d78 <exec+0x80>
    80003f82:	df243c23          	sd	s2,-520(s0)
    80003f86:	b7ed                	j	80003f70 <exec+0x278>
    80003f88:	df243c23          	sd	s2,-520(s0)
    80003f8c:	b7d5                	j	80003f70 <exec+0x278>
    80003f8e:	df243c23          	sd	s2,-520(s0)
    80003f92:	bff9                	j	80003f70 <exec+0x278>
    80003f94:	df243c23          	sd	s2,-520(s0)
    80003f98:	bfe1                	j	80003f70 <exec+0x278>
  sz = sz1;
    80003f9a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003f9e:	4a81                	li	s5,0
    80003fa0:	bfc1                	j	80003f70 <exec+0x278>
  sz = sz1;
    80003fa2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003fa6:	4a81                	li	s5,0
    80003fa8:	b7e1                	j	80003f70 <exec+0x278>
  sz = sz1;
    80003faa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003fae:	4a81                	li	s5,0
    80003fb0:	b7c1                	j	80003f70 <exec+0x278>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003fb2:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003fb6:	e0843783          	ld	a5,-504(s0)
    80003fba:	0017869b          	addiw	a3,a5,1
    80003fbe:	e0d43423          	sd	a3,-504(s0)
    80003fc2:	e0043783          	ld	a5,-512(s0)
    80003fc6:	0387879b          	addiw	a5,a5,56
    80003fca:	e8845703          	lhu	a4,-376(s0)
    80003fce:	e4e6d7e3          	bge	a3,a4,80003e1c <exec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003fd2:	2781                	sext.w	a5,a5
    80003fd4:	e0f43023          	sd	a5,-512(s0)
    80003fd8:	03800713          	li	a4,56
    80003fdc:	86be                	mv	a3,a5
    80003fde:	e1840613          	addi	a2,s0,-488
    80003fe2:	4581                	li	a1,0
    80003fe4:	8556                	mv	a0,s5
    80003fe6:	d15fe0ef          	jal	ra,80002cfa <readi>
    80003fea:	03800793          	li	a5,56
    80003fee:	f6f51fe3          	bne	a0,a5,80003f6c <exec+0x274>
    if(ph.type != ELF_PROG_LOAD)
    80003ff2:	e1842783          	lw	a5,-488(s0)
    80003ff6:	4705                	li	a4,1
    80003ff8:	fae79fe3          	bne	a5,a4,80003fb6 <exec+0x2be>
    if(ph.memsz < ph.filesz)
    80003ffc:	e4043483          	ld	s1,-448(s0)
    80004000:	e3843783          	ld	a5,-456(s0)
    80004004:	f6f4efe3          	bltu	s1,a5,80003f82 <exec+0x28a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004008:	e2843783          	ld	a5,-472(s0)
    8000400c:	94be                	add	s1,s1,a5
    8000400e:	f6f4ede3          	bltu	s1,a5,80003f88 <exec+0x290>
    if(ph.vaddr % PGSIZE != 0)
    80004012:	de043703          	ld	a4,-544(s0)
    80004016:	8ff9                	and	a5,a5,a4
    80004018:	fbbd                	bnez	a5,80003f8e <exec+0x296>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000401a:	e1c42503          	lw	a0,-484(s0)
    8000401e:	cc1ff0ef          	jal	ra,80003cde <flags2perm>
    80004022:	86aa                	mv	a3,a0
    80004024:	8626                	mv	a2,s1
    80004026:	85ca                	mv	a1,s2
    80004028:	855a                	mv	a0,s6
    8000402a:	a39fc0ef          	jal	ra,80000a62 <uvmalloc>
    8000402e:	dea43c23          	sd	a0,-520(s0)
    80004032:	d12d                	beqz	a0,80003f94 <exec+0x29c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004034:	e2843c03          	ld	s8,-472(s0)
    80004038:	e2042c83          	lw	s9,-480(s0)
    8000403c:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004040:	f60b89e3          	beqz	s7,80003fb2 <exec+0x2ba>
    80004044:	89de                	mv	s3,s7
    80004046:	4481                	li	s1,0
    80004048:	bb5d                	j	80003dfe <exec+0x106>

000000008000404a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000404a:	7179                	addi	sp,sp,-48
    8000404c:	f406                	sd	ra,40(sp)
    8000404e:	f022                	sd	s0,32(sp)
    80004050:	ec26                	sd	s1,24(sp)
    80004052:	e84a                	sd	s2,16(sp)
    80004054:	1800                	addi	s0,sp,48
    80004056:	892e                	mv	s2,a1
    80004058:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000405a:	fdc40593          	addi	a1,s0,-36
    8000405e:	fedfd0ef          	jal	ra,8000204a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004062:	fdc42703          	lw	a4,-36(s0)
    80004066:	47bd                	li	a5,15
    80004068:	02e7e963          	bltu	a5,a4,8000409a <argfd+0x50>
    8000406c:	930fd0ef          	jal	ra,8000119c <myproc>
    80004070:	fdc42703          	lw	a4,-36(s0)
    80004074:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffde04a>
    80004078:	078e                	slli	a5,a5,0x3
    8000407a:	953e                	add	a0,a0,a5
    8000407c:	611c                	ld	a5,0(a0)
    8000407e:	c385                	beqz	a5,8000409e <argfd+0x54>
    return -1;
  if(pfd)
    80004080:	00090463          	beqz	s2,80004088 <argfd+0x3e>
    *pfd = fd;
    80004084:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004088:	4501                	li	a0,0
  if(pf)
    8000408a:	c091                	beqz	s1,8000408e <argfd+0x44>
    *pf = f;
    8000408c:	e09c                	sd	a5,0(s1)
}
    8000408e:	70a2                	ld	ra,40(sp)
    80004090:	7402                	ld	s0,32(sp)
    80004092:	64e2                	ld	s1,24(sp)
    80004094:	6942                	ld	s2,16(sp)
    80004096:	6145                	addi	sp,sp,48
    80004098:	8082                	ret
    return -1;
    8000409a:	557d                	li	a0,-1
    8000409c:	bfcd                	j	8000408e <argfd+0x44>
    8000409e:	557d                	li	a0,-1
    800040a0:	b7fd                	j	8000408e <argfd+0x44>

00000000800040a2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800040a2:	1101                	addi	sp,sp,-32
    800040a4:	ec06                	sd	ra,24(sp)
    800040a6:	e822                	sd	s0,16(sp)
    800040a8:	e426                	sd	s1,8(sp)
    800040aa:	1000                	addi	s0,sp,32
    800040ac:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800040ae:	8eefd0ef          	jal	ra,8000119c <myproc>
    800040b2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800040b4:	0d050793          	addi	a5,a0,208
    800040b8:	4501                	li	a0,0
    800040ba:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800040bc:	6398                	ld	a4,0(a5)
    800040be:	cb19                	beqz	a4,800040d4 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800040c0:	2505                	addiw	a0,a0,1
    800040c2:	07a1                	addi	a5,a5,8
    800040c4:	fed51ce3          	bne	a0,a3,800040bc <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800040c8:	557d                	li	a0,-1
}
    800040ca:	60e2                	ld	ra,24(sp)
    800040cc:	6442                	ld	s0,16(sp)
    800040ce:	64a2                	ld	s1,8(sp)
    800040d0:	6105                	addi	sp,sp,32
    800040d2:	8082                	ret
      p->ofile[fd] = f;
    800040d4:	01a50793          	addi	a5,a0,26
    800040d8:	078e                	slli	a5,a5,0x3
    800040da:	963e                	add	a2,a2,a5
    800040dc:	e204                	sd	s1,0(a2)
      return fd;
    800040de:	b7f5                	j	800040ca <fdalloc+0x28>

00000000800040e0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800040e0:	715d                	addi	sp,sp,-80
    800040e2:	e486                	sd	ra,72(sp)
    800040e4:	e0a2                	sd	s0,64(sp)
    800040e6:	fc26                	sd	s1,56(sp)
    800040e8:	f84a                	sd	s2,48(sp)
    800040ea:	f44e                	sd	s3,40(sp)
    800040ec:	f052                	sd	s4,32(sp)
    800040ee:	ec56                	sd	s5,24(sp)
    800040f0:	e85a                	sd	s6,16(sp)
    800040f2:	0880                	addi	s0,sp,80
    800040f4:	8b2e                	mv	s6,a1
    800040f6:	89b2                	mv	s3,a2
    800040f8:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800040fa:	fb040593          	addi	a1,s0,-80
    800040fe:	87eff0ef          	jal	ra,8000317c <nameiparent>
    80004102:	84aa                	mv	s1,a0
    80004104:	10050b63          	beqz	a0,8000421a <create+0x13a>
    return 0;

  ilock(dp);
    80004108:	9a3fe0ef          	jal	ra,80002aaa <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000410c:	4601                	li	a2,0
    8000410e:	fb040593          	addi	a1,s0,-80
    80004112:	8526                	mv	a0,s1
    80004114:	de3fe0ef          	jal	ra,80002ef6 <dirlookup>
    80004118:	8aaa                	mv	s5,a0
    8000411a:	c521                	beqz	a0,80004162 <create+0x82>
    iunlockput(dp);
    8000411c:	8526                	mv	a0,s1
    8000411e:	b93fe0ef          	jal	ra,80002cb0 <iunlockput>
    ilock(ip);
    80004122:	8556                	mv	a0,s5
    80004124:	987fe0ef          	jal	ra,80002aaa <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004128:	000b059b          	sext.w	a1,s6
    8000412c:	4789                	li	a5,2
    8000412e:	02f59563          	bne	a1,a5,80004158 <create+0x78>
    80004132:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffde074>
    80004136:	37f9                	addiw	a5,a5,-2
    80004138:	17c2                	slli	a5,a5,0x30
    8000413a:	93c1                	srli	a5,a5,0x30
    8000413c:	4705                	li	a4,1
    8000413e:	00f76d63          	bltu	a4,a5,80004158 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004142:	8556                	mv	a0,s5
    80004144:	60a6                	ld	ra,72(sp)
    80004146:	6406                	ld	s0,64(sp)
    80004148:	74e2                	ld	s1,56(sp)
    8000414a:	7942                	ld	s2,48(sp)
    8000414c:	79a2                	ld	s3,40(sp)
    8000414e:	7a02                	ld	s4,32(sp)
    80004150:	6ae2                	ld	s5,24(sp)
    80004152:	6b42                	ld	s6,16(sp)
    80004154:	6161                	addi	sp,sp,80
    80004156:	8082                	ret
    iunlockput(ip);
    80004158:	8556                	mv	a0,s5
    8000415a:	b57fe0ef          	jal	ra,80002cb0 <iunlockput>
    return 0;
    8000415e:	4a81                	li	s5,0
    80004160:	b7cd                	j	80004142 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004162:	85da                	mv	a1,s6
    80004164:	4088                	lw	a0,0(s1)
    80004166:	fdafe0ef          	jal	ra,80002940 <ialloc>
    8000416a:	8a2a                	mv	s4,a0
    8000416c:	cd1d                	beqz	a0,800041aa <create+0xca>
  ilock(ip);
    8000416e:	93dfe0ef          	jal	ra,80002aaa <ilock>
  ip->major = major;
    80004172:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004176:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000417a:	4905                	li	s2,1
    8000417c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004180:	8552                	mv	a0,s4
    80004182:	875fe0ef          	jal	ra,800029f6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004186:	000b059b          	sext.w	a1,s6
    8000418a:	03258563          	beq	a1,s2,800041b4 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    8000418e:	004a2603          	lw	a2,4(s4)
    80004192:	fb040593          	addi	a1,s0,-80
    80004196:	8526                	mv	a0,s1
    80004198:	f31fe0ef          	jal	ra,800030c8 <dirlink>
    8000419c:	06054363          	bltz	a0,80004202 <create+0x122>
  iunlockput(dp);
    800041a0:	8526                	mv	a0,s1
    800041a2:	b0ffe0ef          	jal	ra,80002cb0 <iunlockput>
  return ip;
    800041a6:	8ad2                	mv	s5,s4
    800041a8:	bf69                	j	80004142 <create+0x62>
    iunlockput(dp);
    800041aa:	8526                	mv	a0,s1
    800041ac:	b05fe0ef          	jal	ra,80002cb0 <iunlockput>
    return 0;
    800041b0:	8ad2                	mv	s5,s4
    800041b2:	bf41                	j	80004142 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800041b4:	004a2603          	lw	a2,4(s4)
    800041b8:	00003597          	auipc	a1,0x3
    800041bc:	68058593          	addi	a1,a1,1664 # 80007838 <syscalls+0x308>
    800041c0:	8552                	mv	a0,s4
    800041c2:	f07fe0ef          	jal	ra,800030c8 <dirlink>
    800041c6:	02054e63          	bltz	a0,80004202 <create+0x122>
    800041ca:	40d0                	lw	a2,4(s1)
    800041cc:	00003597          	auipc	a1,0x3
    800041d0:	67458593          	addi	a1,a1,1652 # 80007840 <syscalls+0x310>
    800041d4:	8552                	mv	a0,s4
    800041d6:	ef3fe0ef          	jal	ra,800030c8 <dirlink>
    800041da:	02054463          	bltz	a0,80004202 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    800041de:	004a2603          	lw	a2,4(s4)
    800041e2:	fb040593          	addi	a1,s0,-80
    800041e6:	8526                	mv	a0,s1
    800041e8:	ee1fe0ef          	jal	ra,800030c8 <dirlink>
    800041ec:	00054b63          	bltz	a0,80004202 <create+0x122>
    dp->nlink++;  // for ".."
    800041f0:	04a4d783          	lhu	a5,74(s1)
    800041f4:	2785                	addiw	a5,a5,1
    800041f6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800041fa:	8526                	mv	a0,s1
    800041fc:	ffafe0ef          	jal	ra,800029f6 <iupdate>
    80004200:	b745                	j	800041a0 <create+0xc0>
  ip->nlink = 0;
    80004202:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004206:	8552                	mv	a0,s4
    80004208:	feefe0ef          	jal	ra,800029f6 <iupdate>
  iunlockput(ip);
    8000420c:	8552                	mv	a0,s4
    8000420e:	aa3fe0ef          	jal	ra,80002cb0 <iunlockput>
  iunlockput(dp);
    80004212:	8526                	mv	a0,s1
    80004214:	a9dfe0ef          	jal	ra,80002cb0 <iunlockput>
  return 0;
    80004218:	b72d                	j	80004142 <create+0x62>
    return 0;
    8000421a:	8aaa                	mv	s5,a0
    8000421c:	b71d                	j	80004142 <create+0x62>

000000008000421e <sys_dup>:
{
    8000421e:	7179                	addi	sp,sp,-48
    80004220:	f406                	sd	ra,40(sp)
    80004222:	f022                	sd	s0,32(sp)
    80004224:	ec26                	sd	s1,24(sp)
    80004226:	e84a                	sd	s2,16(sp)
    80004228:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000422a:	fd840613          	addi	a2,s0,-40
    8000422e:	4581                	li	a1,0
    80004230:	4501                	li	a0,0
    80004232:	e19ff0ef          	jal	ra,8000404a <argfd>
    return -1;
    80004236:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004238:	00054f63          	bltz	a0,80004256 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    8000423c:	fd843903          	ld	s2,-40(s0)
    80004240:	854a                	mv	a0,s2
    80004242:	e61ff0ef          	jal	ra,800040a2 <fdalloc>
    80004246:	84aa                	mv	s1,a0
    return -1;
    80004248:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000424a:	00054663          	bltz	a0,80004256 <sys_dup+0x38>
  filedup(f);
    8000424e:	854a                	mv	a0,s2
    80004250:	cc0ff0ef          	jal	ra,80003710 <filedup>
  return fd;
    80004254:	87a6                	mv	a5,s1
}
    80004256:	853e                	mv	a0,a5
    80004258:	70a2                	ld	ra,40(sp)
    8000425a:	7402                	ld	s0,32(sp)
    8000425c:	64e2                	ld	s1,24(sp)
    8000425e:	6942                	ld	s2,16(sp)
    80004260:	6145                	addi	sp,sp,48
    80004262:	8082                	ret

0000000080004264 <sys_read>:
{
    80004264:	7179                	addi	sp,sp,-48
    80004266:	f406                	sd	ra,40(sp)
    80004268:	f022                	sd	s0,32(sp)
    8000426a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000426c:	fd840593          	addi	a1,s0,-40
    80004270:	4505                	li	a0,1
    80004272:	df5fd0ef          	jal	ra,80002066 <argaddr>
  argint(2, &n);
    80004276:	fe440593          	addi	a1,s0,-28
    8000427a:	4509                	li	a0,2
    8000427c:	dcffd0ef          	jal	ra,8000204a <argint>
  if(argfd(0, 0, &f) < 0)
    80004280:	fe840613          	addi	a2,s0,-24
    80004284:	4581                	li	a1,0
    80004286:	4501                	li	a0,0
    80004288:	dc3ff0ef          	jal	ra,8000404a <argfd>
    8000428c:	87aa                	mv	a5,a0
    return -1;
    8000428e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004290:	0007ca63          	bltz	a5,800042a4 <sys_read+0x40>
  return fileread(f, p, n);
    80004294:	fe442603          	lw	a2,-28(s0)
    80004298:	fd843583          	ld	a1,-40(s0)
    8000429c:	fe843503          	ld	a0,-24(s0)
    800042a0:	dbcff0ef          	jal	ra,8000385c <fileread>
}
    800042a4:	70a2                	ld	ra,40(sp)
    800042a6:	7402                	ld	s0,32(sp)
    800042a8:	6145                	addi	sp,sp,48
    800042aa:	8082                	ret

00000000800042ac <sys_write>:
{
    800042ac:	7179                	addi	sp,sp,-48
    800042ae:	f406                	sd	ra,40(sp)
    800042b0:	f022                	sd	s0,32(sp)
    800042b2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800042b4:	fd840593          	addi	a1,s0,-40
    800042b8:	4505                	li	a0,1
    800042ba:	dadfd0ef          	jal	ra,80002066 <argaddr>
  argint(2, &n);
    800042be:	fe440593          	addi	a1,s0,-28
    800042c2:	4509                	li	a0,2
    800042c4:	d87fd0ef          	jal	ra,8000204a <argint>
  if(argfd(0, 0, &f) < 0)
    800042c8:	fe840613          	addi	a2,s0,-24
    800042cc:	4581                	li	a1,0
    800042ce:	4501                	li	a0,0
    800042d0:	d7bff0ef          	jal	ra,8000404a <argfd>
    800042d4:	87aa                	mv	a5,a0
    return -1;
    800042d6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800042d8:	0007ca63          	bltz	a5,800042ec <sys_write+0x40>
  return filewrite(f, p, n);
    800042dc:	fe442603          	lw	a2,-28(s0)
    800042e0:	fd843583          	ld	a1,-40(s0)
    800042e4:	fe843503          	ld	a0,-24(s0)
    800042e8:	e22ff0ef          	jal	ra,8000390a <filewrite>
}
    800042ec:	70a2                	ld	ra,40(sp)
    800042ee:	7402                	ld	s0,32(sp)
    800042f0:	6145                	addi	sp,sp,48
    800042f2:	8082                	ret

00000000800042f4 <sys_close>:
{
    800042f4:	1101                	addi	sp,sp,-32
    800042f6:	ec06                	sd	ra,24(sp)
    800042f8:	e822                	sd	s0,16(sp)
    800042fa:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800042fc:	fe040613          	addi	a2,s0,-32
    80004300:	fec40593          	addi	a1,s0,-20
    80004304:	4501                	li	a0,0
    80004306:	d45ff0ef          	jal	ra,8000404a <argfd>
    return -1;
    8000430a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000430c:	02054063          	bltz	a0,8000432c <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004310:	e8dfc0ef          	jal	ra,8000119c <myproc>
    80004314:	fec42783          	lw	a5,-20(s0)
    80004318:	07e9                	addi	a5,a5,26
    8000431a:	078e                	slli	a5,a5,0x3
    8000431c:	953e                	add	a0,a0,a5
    8000431e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004322:	fe043503          	ld	a0,-32(s0)
    80004326:	c30ff0ef          	jal	ra,80003756 <fileclose>
  return 0;
    8000432a:	4781                	li	a5,0
}
    8000432c:	853e                	mv	a0,a5
    8000432e:	60e2                	ld	ra,24(sp)
    80004330:	6442                	ld	s0,16(sp)
    80004332:	6105                	addi	sp,sp,32
    80004334:	8082                	ret

0000000080004336 <sys_fstat>:
{
    80004336:	1101                	addi	sp,sp,-32
    80004338:	ec06                	sd	ra,24(sp)
    8000433a:	e822                	sd	s0,16(sp)
    8000433c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000433e:	fe040593          	addi	a1,s0,-32
    80004342:	4505                	li	a0,1
    80004344:	d23fd0ef          	jal	ra,80002066 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004348:	fe840613          	addi	a2,s0,-24
    8000434c:	4581                	li	a1,0
    8000434e:	4501                	li	a0,0
    80004350:	cfbff0ef          	jal	ra,8000404a <argfd>
    80004354:	87aa                	mv	a5,a0
    return -1;
    80004356:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004358:	0007c863          	bltz	a5,80004368 <sys_fstat+0x32>
  return filestat(f, st);
    8000435c:	fe043583          	ld	a1,-32(s0)
    80004360:	fe843503          	ld	a0,-24(s0)
    80004364:	c9aff0ef          	jal	ra,800037fe <filestat>
}
    80004368:	60e2                	ld	ra,24(sp)
    8000436a:	6442                	ld	s0,16(sp)
    8000436c:	6105                	addi	sp,sp,32
    8000436e:	8082                	ret

0000000080004370 <sys_link>:
{
    80004370:	7169                	addi	sp,sp,-304
    80004372:	f606                	sd	ra,296(sp)
    80004374:	f222                	sd	s0,288(sp)
    80004376:	ee26                	sd	s1,280(sp)
    80004378:	ea4a                	sd	s2,272(sp)
    8000437a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000437c:	08000613          	li	a2,128
    80004380:	ed040593          	addi	a1,s0,-304
    80004384:	4501                	li	a0,0
    80004386:	cfdfd0ef          	jal	ra,80002082 <argstr>
    return -1;
    8000438a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000438c:	0c054663          	bltz	a0,80004458 <sys_link+0xe8>
    80004390:	08000613          	li	a2,128
    80004394:	f5040593          	addi	a1,s0,-176
    80004398:	4505                	li	a0,1
    8000439a:	ce9fd0ef          	jal	ra,80002082 <argstr>
    return -1;
    8000439e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800043a0:	0a054c63          	bltz	a0,80004458 <sys_link+0xe8>
  begin_op();
    800043a4:	f9bfe0ef          	jal	ra,8000333e <begin_op>
  if((ip = namei(old)) == 0){
    800043a8:	ed040513          	addi	a0,s0,-304
    800043ac:	db7fe0ef          	jal	ra,80003162 <namei>
    800043b0:	84aa                	mv	s1,a0
    800043b2:	c525                	beqz	a0,8000441a <sys_link+0xaa>
  ilock(ip);
    800043b4:	ef6fe0ef          	jal	ra,80002aaa <ilock>
  if(ip->type == T_DIR){
    800043b8:	04449703          	lh	a4,68(s1)
    800043bc:	4785                	li	a5,1
    800043be:	06f70263          	beq	a4,a5,80004422 <sys_link+0xb2>
  ip->nlink++;
    800043c2:	04a4d783          	lhu	a5,74(s1)
    800043c6:	2785                	addiw	a5,a5,1
    800043c8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800043cc:	8526                	mv	a0,s1
    800043ce:	e28fe0ef          	jal	ra,800029f6 <iupdate>
  iunlock(ip);
    800043d2:	8526                	mv	a0,s1
    800043d4:	f80fe0ef          	jal	ra,80002b54 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800043d8:	fd040593          	addi	a1,s0,-48
    800043dc:	f5040513          	addi	a0,s0,-176
    800043e0:	d9dfe0ef          	jal	ra,8000317c <nameiparent>
    800043e4:	892a                	mv	s2,a0
    800043e6:	c921                	beqz	a0,80004436 <sys_link+0xc6>
  ilock(dp);
    800043e8:	ec2fe0ef          	jal	ra,80002aaa <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800043ec:	00092703          	lw	a4,0(s2)
    800043f0:	409c                	lw	a5,0(s1)
    800043f2:	02f71f63          	bne	a4,a5,80004430 <sys_link+0xc0>
    800043f6:	40d0                	lw	a2,4(s1)
    800043f8:	fd040593          	addi	a1,s0,-48
    800043fc:	854a                	mv	a0,s2
    800043fe:	ccbfe0ef          	jal	ra,800030c8 <dirlink>
    80004402:	02054763          	bltz	a0,80004430 <sys_link+0xc0>
  iunlockput(dp);
    80004406:	854a                	mv	a0,s2
    80004408:	8a9fe0ef          	jal	ra,80002cb0 <iunlockput>
  iput(ip);
    8000440c:	8526                	mv	a0,s1
    8000440e:	81bfe0ef          	jal	ra,80002c28 <iput>
  end_op();
    80004412:	f9bfe0ef          	jal	ra,800033ac <end_op>
  return 0;
    80004416:	4781                	li	a5,0
    80004418:	a081                	j	80004458 <sys_link+0xe8>
    end_op();
    8000441a:	f93fe0ef          	jal	ra,800033ac <end_op>
    return -1;
    8000441e:	57fd                	li	a5,-1
    80004420:	a825                	j	80004458 <sys_link+0xe8>
    iunlockput(ip);
    80004422:	8526                	mv	a0,s1
    80004424:	88dfe0ef          	jal	ra,80002cb0 <iunlockput>
    end_op();
    80004428:	f85fe0ef          	jal	ra,800033ac <end_op>
    return -1;
    8000442c:	57fd                	li	a5,-1
    8000442e:	a02d                	j	80004458 <sys_link+0xe8>
    iunlockput(dp);
    80004430:	854a                	mv	a0,s2
    80004432:	87ffe0ef          	jal	ra,80002cb0 <iunlockput>
  ilock(ip);
    80004436:	8526                	mv	a0,s1
    80004438:	e72fe0ef          	jal	ra,80002aaa <ilock>
  ip->nlink--;
    8000443c:	04a4d783          	lhu	a5,74(s1)
    80004440:	37fd                	addiw	a5,a5,-1
    80004442:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004446:	8526                	mv	a0,s1
    80004448:	daefe0ef          	jal	ra,800029f6 <iupdate>
  iunlockput(ip);
    8000444c:	8526                	mv	a0,s1
    8000444e:	863fe0ef          	jal	ra,80002cb0 <iunlockput>
  end_op();
    80004452:	f5bfe0ef          	jal	ra,800033ac <end_op>
  return -1;
    80004456:	57fd                	li	a5,-1
}
    80004458:	853e                	mv	a0,a5
    8000445a:	70b2                	ld	ra,296(sp)
    8000445c:	7412                	ld	s0,288(sp)
    8000445e:	64f2                	ld	s1,280(sp)
    80004460:	6952                	ld	s2,272(sp)
    80004462:	6155                	addi	sp,sp,304
    80004464:	8082                	ret

0000000080004466 <sys_unlink>:
{
    80004466:	7151                	addi	sp,sp,-240
    80004468:	f586                	sd	ra,232(sp)
    8000446a:	f1a2                	sd	s0,224(sp)
    8000446c:	eda6                	sd	s1,216(sp)
    8000446e:	e9ca                	sd	s2,208(sp)
    80004470:	e5ce                	sd	s3,200(sp)
    80004472:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004474:	08000613          	li	a2,128
    80004478:	f3040593          	addi	a1,s0,-208
    8000447c:	4501                	li	a0,0
    8000447e:	c05fd0ef          	jal	ra,80002082 <argstr>
    80004482:	12054b63          	bltz	a0,800045b8 <sys_unlink+0x152>
  begin_op();
    80004486:	eb9fe0ef          	jal	ra,8000333e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000448a:	fb040593          	addi	a1,s0,-80
    8000448e:	f3040513          	addi	a0,s0,-208
    80004492:	cebfe0ef          	jal	ra,8000317c <nameiparent>
    80004496:	84aa                	mv	s1,a0
    80004498:	c54d                	beqz	a0,80004542 <sys_unlink+0xdc>
  ilock(dp);
    8000449a:	e10fe0ef          	jal	ra,80002aaa <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000449e:	00003597          	auipc	a1,0x3
    800044a2:	39a58593          	addi	a1,a1,922 # 80007838 <syscalls+0x308>
    800044a6:	fb040513          	addi	a0,s0,-80
    800044aa:	a37fe0ef          	jal	ra,80002ee0 <namecmp>
    800044ae:	10050a63          	beqz	a0,800045c2 <sys_unlink+0x15c>
    800044b2:	00003597          	auipc	a1,0x3
    800044b6:	38e58593          	addi	a1,a1,910 # 80007840 <syscalls+0x310>
    800044ba:	fb040513          	addi	a0,s0,-80
    800044be:	a23fe0ef          	jal	ra,80002ee0 <namecmp>
    800044c2:	10050063          	beqz	a0,800045c2 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800044c6:	f2c40613          	addi	a2,s0,-212
    800044ca:	fb040593          	addi	a1,s0,-80
    800044ce:	8526                	mv	a0,s1
    800044d0:	a27fe0ef          	jal	ra,80002ef6 <dirlookup>
    800044d4:	892a                	mv	s2,a0
    800044d6:	0e050663          	beqz	a0,800045c2 <sys_unlink+0x15c>
  ilock(ip);
    800044da:	dd0fe0ef          	jal	ra,80002aaa <ilock>
  if(ip->nlink < 1)
    800044de:	04a91783          	lh	a5,74(s2)
    800044e2:	06f05463          	blez	a5,8000454a <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800044e6:	04491703          	lh	a4,68(s2)
    800044ea:	4785                	li	a5,1
    800044ec:	06f70563          	beq	a4,a5,80004556 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    800044f0:	4641                	li	a2,16
    800044f2:	4581                	li	a1,0
    800044f4:	fc040513          	addi	a0,s0,-64
    800044f8:	dbbfb0ef          	jal	ra,800002b2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044fc:	4741                	li	a4,16
    800044fe:	f2c42683          	lw	a3,-212(s0)
    80004502:	fc040613          	addi	a2,s0,-64
    80004506:	4581                	li	a1,0
    80004508:	8526                	mv	a0,s1
    8000450a:	8d5fe0ef          	jal	ra,80002dde <writei>
    8000450e:	47c1                	li	a5,16
    80004510:	08f51563          	bne	a0,a5,8000459a <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004514:	04491703          	lh	a4,68(s2)
    80004518:	4785                	li	a5,1
    8000451a:	08f70663          	beq	a4,a5,800045a6 <sys_unlink+0x140>
  iunlockput(dp);
    8000451e:	8526                	mv	a0,s1
    80004520:	f90fe0ef          	jal	ra,80002cb0 <iunlockput>
  ip->nlink--;
    80004524:	04a95783          	lhu	a5,74(s2)
    80004528:	37fd                	addiw	a5,a5,-1
    8000452a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000452e:	854a                	mv	a0,s2
    80004530:	cc6fe0ef          	jal	ra,800029f6 <iupdate>
  iunlockput(ip);
    80004534:	854a                	mv	a0,s2
    80004536:	f7afe0ef          	jal	ra,80002cb0 <iunlockput>
  end_op();
    8000453a:	e73fe0ef          	jal	ra,800033ac <end_op>
  return 0;
    8000453e:	4501                	li	a0,0
    80004540:	a079                	j	800045ce <sys_unlink+0x168>
    end_op();
    80004542:	e6bfe0ef          	jal	ra,800033ac <end_op>
    return -1;
    80004546:	557d                	li	a0,-1
    80004548:	a059                	j	800045ce <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    8000454a:	00003517          	auipc	a0,0x3
    8000454e:	2fe50513          	addi	a0,a0,766 # 80007848 <syscalls+0x318>
    80004552:	1d0010ef          	jal	ra,80005722 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004556:	04c92703          	lw	a4,76(s2)
    8000455a:	02000793          	li	a5,32
    8000455e:	f8e7f9e3          	bgeu	a5,a4,800044f0 <sys_unlink+0x8a>
    80004562:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004566:	4741                	li	a4,16
    80004568:	86ce                	mv	a3,s3
    8000456a:	f1840613          	addi	a2,s0,-232
    8000456e:	4581                	li	a1,0
    80004570:	854a                	mv	a0,s2
    80004572:	f88fe0ef          	jal	ra,80002cfa <readi>
    80004576:	47c1                	li	a5,16
    80004578:	00f51b63          	bne	a0,a5,8000458e <sys_unlink+0x128>
    if(de.inum != 0)
    8000457c:	f1845783          	lhu	a5,-232(s0)
    80004580:	ef95                	bnez	a5,800045bc <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004582:	29c1                	addiw	s3,s3,16
    80004584:	04c92783          	lw	a5,76(s2)
    80004588:	fcf9efe3          	bltu	s3,a5,80004566 <sys_unlink+0x100>
    8000458c:	b795                	j	800044f0 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000458e:	00003517          	auipc	a0,0x3
    80004592:	2d250513          	addi	a0,a0,722 # 80007860 <syscalls+0x330>
    80004596:	18c010ef          	jal	ra,80005722 <panic>
    panic("unlink: writei");
    8000459a:	00003517          	auipc	a0,0x3
    8000459e:	2de50513          	addi	a0,a0,734 # 80007878 <syscalls+0x348>
    800045a2:	180010ef          	jal	ra,80005722 <panic>
    dp->nlink--;
    800045a6:	04a4d783          	lhu	a5,74(s1)
    800045aa:	37fd                	addiw	a5,a5,-1
    800045ac:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800045b0:	8526                	mv	a0,s1
    800045b2:	c44fe0ef          	jal	ra,800029f6 <iupdate>
    800045b6:	b7a5                	j	8000451e <sys_unlink+0xb8>
    return -1;
    800045b8:	557d                	li	a0,-1
    800045ba:	a811                	j	800045ce <sys_unlink+0x168>
    iunlockput(ip);
    800045bc:	854a                	mv	a0,s2
    800045be:	ef2fe0ef          	jal	ra,80002cb0 <iunlockput>
  iunlockput(dp);
    800045c2:	8526                	mv	a0,s1
    800045c4:	eecfe0ef          	jal	ra,80002cb0 <iunlockput>
  end_op();
    800045c8:	de5fe0ef          	jal	ra,800033ac <end_op>
  return -1;
    800045cc:	557d                	li	a0,-1
}
    800045ce:	70ae                	ld	ra,232(sp)
    800045d0:	740e                	ld	s0,224(sp)
    800045d2:	64ee                	ld	s1,216(sp)
    800045d4:	694e                	ld	s2,208(sp)
    800045d6:	69ae                	ld	s3,200(sp)
    800045d8:	616d                	addi	sp,sp,240
    800045da:	8082                	ret

00000000800045dc <sys_open>:

uint64
sys_open(void)
{
    800045dc:	7131                	addi	sp,sp,-192
    800045de:	fd06                	sd	ra,184(sp)
    800045e0:	f922                	sd	s0,176(sp)
    800045e2:	f526                	sd	s1,168(sp)
    800045e4:	f14a                	sd	s2,160(sp)
    800045e6:	ed4e                	sd	s3,152(sp)
    800045e8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800045ea:	f4c40593          	addi	a1,s0,-180
    800045ee:	4505                	li	a0,1
    800045f0:	a5bfd0ef          	jal	ra,8000204a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800045f4:	08000613          	li	a2,128
    800045f8:	f5040593          	addi	a1,s0,-176
    800045fc:	4501                	li	a0,0
    800045fe:	a85fd0ef          	jal	ra,80002082 <argstr>
    80004602:	87aa                	mv	a5,a0
    return -1;
    80004604:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004606:	0807cd63          	bltz	a5,800046a0 <sys_open+0xc4>

  begin_op();
    8000460a:	d35fe0ef          	jal	ra,8000333e <begin_op>

  if(omode & O_CREATE){
    8000460e:	f4c42783          	lw	a5,-180(s0)
    80004612:	2007f793          	andi	a5,a5,512
    80004616:	c3c5                	beqz	a5,800046b6 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004618:	4681                	li	a3,0
    8000461a:	4601                	li	a2,0
    8000461c:	4589                	li	a1,2
    8000461e:	f5040513          	addi	a0,s0,-176
    80004622:	abfff0ef          	jal	ra,800040e0 <create>
    80004626:	84aa                	mv	s1,a0
    if(ip == 0){
    80004628:	c159                	beqz	a0,800046ae <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000462a:	04449703          	lh	a4,68(s1)
    8000462e:	478d                	li	a5,3
    80004630:	00f71763          	bne	a4,a5,8000463e <sys_open+0x62>
    80004634:	0464d703          	lhu	a4,70(s1)
    80004638:	47a5                	li	a5,9
    8000463a:	0ae7e963          	bltu	a5,a4,800046ec <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000463e:	874ff0ef          	jal	ra,800036b2 <filealloc>
    80004642:	89aa                	mv	s3,a0
    80004644:	0c050963          	beqz	a0,80004716 <sys_open+0x13a>
    80004648:	a5bff0ef          	jal	ra,800040a2 <fdalloc>
    8000464c:	892a                	mv	s2,a0
    8000464e:	0c054163          	bltz	a0,80004710 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004652:	04449703          	lh	a4,68(s1)
    80004656:	478d                	li	a5,3
    80004658:	0af70163          	beq	a4,a5,800046fa <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000465c:	4789                	li	a5,2
    8000465e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004662:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004666:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000466a:	f4c42783          	lw	a5,-180(s0)
    8000466e:	0017c713          	xori	a4,a5,1
    80004672:	8b05                	andi	a4,a4,1
    80004674:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004678:	0037f713          	andi	a4,a5,3
    8000467c:	00e03733          	snez	a4,a4
    80004680:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004684:	4007f793          	andi	a5,a5,1024
    80004688:	c791                	beqz	a5,80004694 <sys_open+0xb8>
    8000468a:	04449703          	lh	a4,68(s1)
    8000468e:	4789                	li	a5,2
    80004690:	06f70c63          	beq	a4,a5,80004708 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80004694:	8526                	mv	a0,s1
    80004696:	cbefe0ef          	jal	ra,80002b54 <iunlock>
  end_op();
    8000469a:	d13fe0ef          	jal	ra,800033ac <end_op>

  return fd;
    8000469e:	854a                	mv	a0,s2
}
    800046a0:	70ea                	ld	ra,184(sp)
    800046a2:	744a                	ld	s0,176(sp)
    800046a4:	74aa                	ld	s1,168(sp)
    800046a6:	790a                	ld	s2,160(sp)
    800046a8:	69ea                	ld	s3,152(sp)
    800046aa:	6129                	addi	sp,sp,192
    800046ac:	8082                	ret
      end_op();
    800046ae:	cfffe0ef          	jal	ra,800033ac <end_op>
      return -1;
    800046b2:	557d                	li	a0,-1
    800046b4:	b7f5                	j	800046a0 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    800046b6:	f5040513          	addi	a0,s0,-176
    800046ba:	aa9fe0ef          	jal	ra,80003162 <namei>
    800046be:	84aa                	mv	s1,a0
    800046c0:	c115                	beqz	a0,800046e4 <sys_open+0x108>
    ilock(ip);
    800046c2:	be8fe0ef          	jal	ra,80002aaa <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800046c6:	04449703          	lh	a4,68(s1)
    800046ca:	4785                	li	a5,1
    800046cc:	f4f71fe3          	bne	a4,a5,8000462a <sys_open+0x4e>
    800046d0:	f4c42783          	lw	a5,-180(s0)
    800046d4:	d7ad                	beqz	a5,8000463e <sys_open+0x62>
      iunlockput(ip);
    800046d6:	8526                	mv	a0,s1
    800046d8:	dd8fe0ef          	jal	ra,80002cb0 <iunlockput>
      end_op();
    800046dc:	cd1fe0ef          	jal	ra,800033ac <end_op>
      return -1;
    800046e0:	557d                	li	a0,-1
    800046e2:	bf7d                	j	800046a0 <sys_open+0xc4>
      end_op();
    800046e4:	cc9fe0ef          	jal	ra,800033ac <end_op>
      return -1;
    800046e8:	557d                	li	a0,-1
    800046ea:	bf5d                	j	800046a0 <sys_open+0xc4>
    iunlockput(ip);
    800046ec:	8526                	mv	a0,s1
    800046ee:	dc2fe0ef          	jal	ra,80002cb0 <iunlockput>
    end_op();
    800046f2:	cbbfe0ef          	jal	ra,800033ac <end_op>
    return -1;
    800046f6:	557d                	li	a0,-1
    800046f8:	b765                	j	800046a0 <sys_open+0xc4>
    f->type = FD_DEVICE;
    800046fa:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800046fe:	04649783          	lh	a5,70(s1)
    80004702:	02f99223          	sh	a5,36(s3)
    80004706:	b785                	j	80004666 <sys_open+0x8a>
    itrunc(ip);
    80004708:	8526                	mv	a0,s1
    8000470a:	c8afe0ef          	jal	ra,80002b94 <itrunc>
    8000470e:	b759                	j	80004694 <sys_open+0xb8>
      fileclose(f);
    80004710:	854e                	mv	a0,s3
    80004712:	844ff0ef          	jal	ra,80003756 <fileclose>
    iunlockput(ip);
    80004716:	8526                	mv	a0,s1
    80004718:	d98fe0ef          	jal	ra,80002cb0 <iunlockput>
    end_op();
    8000471c:	c91fe0ef          	jal	ra,800033ac <end_op>
    return -1;
    80004720:	557d                	li	a0,-1
    80004722:	bfbd                	j	800046a0 <sys_open+0xc4>

0000000080004724 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004724:	7175                	addi	sp,sp,-144
    80004726:	e506                	sd	ra,136(sp)
    80004728:	e122                	sd	s0,128(sp)
    8000472a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000472c:	c13fe0ef          	jal	ra,8000333e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004730:	08000613          	li	a2,128
    80004734:	f7040593          	addi	a1,s0,-144
    80004738:	4501                	li	a0,0
    8000473a:	949fd0ef          	jal	ra,80002082 <argstr>
    8000473e:	02054363          	bltz	a0,80004764 <sys_mkdir+0x40>
    80004742:	4681                	li	a3,0
    80004744:	4601                	li	a2,0
    80004746:	4585                	li	a1,1
    80004748:	f7040513          	addi	a0,s0,-144
    8000474c:	995ff0ef          	jal	ra,800040e0 <create>
    80004750:	c911                	beqz	a0,80004764 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004752:	d5efe0ef          	jal	ra,80002cb0 <iunlockput>
  end_op();
    80004756:	c57fe0ef          	jal	ra,800033ac <end_op>
  return 0;
    8000475a:	4501                	li	a0,0
}
    8000475c:	60aa                	ld	ra,136(sp)
    8000475e:	640a                	ld	s0,128(sp)
    80004760:	6149                	addi	sp,sp,144
    80004762:	8082                	ret
    end_op();
    80004764:	c49fe0ef          	jal	ra,800033ac <end_op>
    return -1;
    80004768:	557d                	li	a0,-1
    8000476a:	bfcd                	j	8000475c <sys_mkdir+0x38>

000000008000476c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000476c:	7135                	addi	sp,sp,-160
    8000476e:	ed06                	sd	ra,152(sp)
    80004770:	e922                	sd	s0,144(sp)
    80004772:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004774:	bcbfe0ef          	jal	ra,8000333e <begin_op>
  argint(1, &major);
    80004778:	f6c40593          	addi	a1,s0,-148
    8000477c:	4505                	li	a0,1
    8000477e:	8cdfd0ef          	jal	ra,8000204a <argint>
  argint(2, &minor);
    80004782:	f6840593          	addi	a1,s0,-152
    80004786:	4509                	li	a0,2
    80004788:	8c3fd0ef          	jal	ra,8000204a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000478c:	08000613          	li	a2,128
    80004790:	f7040593          	addi	a1,s0,-144
    80004794:	4501                	li	a0,0
    80004796:	8edfd0ef          	jal	ra,80002082 <argstr>
    8000479a:	02054563          	bltz	a0,800047c4 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000479e:	f6841683          	lh	a3,-152(s0)
    800047a2:	f6c41603          	lh	a2,-148(s0)
    800047a6:	458d                	li	a1,3
    800047a8:	f7040513          	addi	a0,s0,-144
    800047ac:	935ff0ef          	jal	ra,800040e0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800047b0:	c911                	beqz	a0,800047c4 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800047b2:	cfefe0ef          	jal	ra,80002cb0 <iunlockput>
  end_op();
    800047b6:	bf7fe0ef          	jal	ra,800033ac <end_op>
  return 0;
    800047ba:	4501                	li	a0,0
}
    800047bc:	60ea                	ld	ra,152(sp)
    800047be:	644a                	ld	s0,144(sp)
    800047c0:	610d                	addi	sp,sp,160
    800047c2:	8082                	ret
    end_op();
    800047c4:	be9fe0ef          	jal	ra,800033ac <end_op>
    return -1;
    800047c8:	557d                	li	a0,-1
    800047ca:	bfcd                	j	800047bc <sys_mknod+0x50>

00000000800047cc <sys_chdir>:

uint64
sys_chdir(void)
{
    800047cc:	7135                	addi	sp,sp,-160
    800047ce:	ed06                	sd	ra,152(sp)
    800047d0:	e922                	sd	s0,144(sp)
    800047d2:	e526                	sd	s1,136(sp)
    800047d4:	e14a                	sd	s2,128(sp)
    800047d6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800047d8:	9c5fc0ef          	jal	ra,8000119c <myproc>
    800047dc:	892a                	mv	s2,a0

  begin_op();
    800047de:	b61fe0ef          	jal	ra,8000333e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800047e2:	08000613          	li	a2,128
    800047e6:	f6040593          	addi	a1,s0,-160
    800047ea:	4501                	li	a0,0
    800047ec:	897fd0ef          	jal	ra,80002082 <argstr>
    800047f0:	04054163          	bltz	a0,80004832 <sys_chdir+0x66>
    800047f4:	f6040513          	addi	a0,s0,-160
    800047f8:	96bfe0ef          	jal	ra,80003162 <namei>
    800047fc:	84aa                	mv	s1,a0
    800047fe:	c915                	beqz	a0,80004832 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004800:	aaafe0ef          	jal	ra,80002aaa <ilock>
  if(ip->type != T_DIR){
    80004804:	04449703          	lh	a4,68(s1)
    80004808:	4785                	li	a5,1
    8000480a:	02f71863          	bne	a4,a5,8000483a <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000480e:	8526                	mv	a0,s1
    80004810:	b44fe0ef          	jal	ra,80002b54 <iunlock>
  iput(p->cwd);
    80004814:	15093503          	ld	a0,336(s2)
    80004818:	c10fe0ef          	jal	ra,80002c28 <iput>
  end_op();
    8000481c:	b91fe0ef          	jal	ra,800033ac <end_op>
  p->cwd = ip;
    80004820:	14993823          	sd	s1,336(s2)
  return 0;
    80004824:	4501                	li	a0,0
}
    80004826:	60ea                	ld	ra,152(sp)
    80004828:	644a                	ld	s0,144(sp)
    8000482a:	64aa                	ld	s1,136(sp)
    8000482c:	690a                	ld	s2,128(sp)
    8000482e:	610d                	addi	sp,sp,160
    80004830:	8082                	ret
    end_op();
    80004832:	b7bfe0ef          	jal	ra,800033ac <end_op>
    return -1;
    80004836:	557d                	li	a0,-1
    80004838:	b7fd                	j	80004826 <sys_chdir+0x5a>
    iunlockput(ip);
    8000483a:	8526                	mv	a0,s1
    8000483c:	c74fe0ef          	jal	ra,80002cb0 <iunlockput>
    end_op();
    80004840:	b6dfe0ef          	jal	ra,800033ac <end_op>
    return -1;
    80004844:	557d                	li	a0,-1
    80004846:	b7c5                	j	80004826 <sys_chdir+0x5a>

0000000080004848 <sys_exec>:

uint64
sys_exec(void)
{
    80004848:	7145                	addi	sp,sp,-464
    8000484a:	e786                	sd	ra,456(sp)
    8000484c:	e3a2                	sd	s0,448(sp)
    8000484e:	ff26                	sd	s1,440(sp)
    80004850:	fb4a                	sd	s2,432(sp)
    80004852:	f74e                	sd	s3,424(sp)
    80004854:	f352                	sd	s4,416(sp)
    80004856:	ef56                	sd	s5,408(sp)
    80004858:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000485a:	e3840593          	addi	a1,s0,-456
    8000485e:	4505                	li	a0,1
    80004860:	807fd0ef          	jal	ra,80002066 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004864:	08000613          	li	a2,128
    80004868:	f4040593          	addi	a1,s0,-192
    8000486c:	4501                	li	a0,0
    8000486e:	815fd0ef          	jal	ra,80002082 <argstr>
    80004872:	87aa                	mv	a5,a0
    return -1;
    80004874:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004876:	0a07c563          	bltz	a5,80004920 <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    8000487a:	10000613          	li	a2,256
    8000487e:	4581                	li	a1,0
    80004880:	e4040513          	addi	a0,s0,-448
    80004884:	a2ffb0ef          	jal	ra,800002b2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004888:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000488c:	89a6                	mv	s3,s1
    8000488e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004890:	02000a13          	li	s4,32
    80004894:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004898:	00391513          	slli	a0,s2,0x3
    8000489c:	e3040593          	addi	a1,s0,-464
    800048a0:	e3843783          	ld	a5,-456(s0)
    800048a4:	953e                	add	a0,a0,a5
    800048a6:	f1afd0ef          	jal	ra,80001fc0 <fetchaddr>
    800048aa:	02054663          	bltz	a0,800048d6 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    800048ae:	e3043783          	ld	a5,-464(s0)
    800048b2:	cf8d                	beqz	a5,800048ec <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800048b4:	8b1fb0ef          	jal	ra,80000164 <kalloc>
    800048b8:	85aa                	mv	a1,a0
    800048ba:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800048be:	cd01                	beqz	a0,800048d6 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800048c0:	6605                	lui	a2,0x1
    800048c2:	e3043503          	ld	a0,-464(s0)
    800048c6:	f44fd0ef          	jal	ra,8000200a <fetchstr>
    800048ca:	00054663          	bltz	a0,800048d6 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    800048ce:	0905                	addi	s2,s2,1
    800048d0:	09a1                	addi	s3,s3,8
    800048d2:	fd4911e3          	bne	s2,s4,80004894 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800048d6:	f4040913          	addi	s2,s0,-192
    800048da:	6088                	ld	a0,0(s1)
    800048dc:	c129                	beqz	a0,8000491e <sys_exec+0xd6>
    kfree(argv[i]);
    800048de:	f92fb0ef          	jal	ra,80000070 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800048e2:	04a1                	addi	s1,s1,8
    800048e4:	ff249be3          	bne	s1,s2,800048da <sys_exec+0x92>
  return -1;
    800048e8:	557d                	li	a0,-1
    800048ea:	a81d                	j	80004920 <sys_exec+0xd8>
      argv[i] = 0;
    800048ec:	0a8e                	slli	s5,s5,0x3
    800048ee:	fc0a8793          	addi	a5,s5,-64
    800048f2:	00878ab3          	add	s5,a5,s0
    800048f6:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800048fa:	e4040593          	addi	a1,s0,-448
    800048fe:	f4040513          	addi	a0,s0,-192
    80004902:	bf6ff0ef          	jal	ra,80003cf8 <exec>
    80004906:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004908:	f4040993          	addi	s3,s0,-192
    8000490c:	6088                	ld	a0,0(s1)
    8000490e:	c511                	beqz	a0,8000491a <sys_exec+0xd2>
    kfree(argv[i]);
    80004910:	f60fb0ef          	jal	ra,80000070 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004914:	04a1                	addi	s1,s1,8
    80004916:	ff349be3          	bne	s1,s3,8000490c <sys_exec+0xc4>
  return ret;
    8000491a:	854a                	mv	a0,s2
    8000491c:	a011                	j	80004920 <sys_exec+0xd8>
  return -1;
    8000491e:	557d                	li	a0,-1
}
    80004920:	60be                	ld	ra,456(sp)
    80004922:	641e                	ld	s0,448(sp)
    80004924:	74fa                	ld	s1,440(sp)
    80004926:	795a                	ld	s2,432(sp)
    80004928:	79ba                	ld	s3,424(sp)
    8000492a:	7a1a                	ld	s4,416(sp)
    8000492c:	6afa                	ld	s5,408(sp)
    8000492e:	6179                	addi	sp,sp,464
    80004930:	8082                	ret

0000000080004932 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004932:	7139                	addi	sp,sp,-64
    80004934:	fc06                	sd	ra,56(sp)
    80004936:	f822                	sd	s0,48(sp)
    80004938:	f426                	sd	s1,40(sp)
    8000493a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000493c:	861fc0ef          	jal	ra,8000119c <myproc>
    80004940:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004942:	fd840593          	addi	a1,s0,-40
    80004946:	4501                	li	a0,0
    80004948:	f1efd0ef          	jal	ra,80002066 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000494c:	fc840593          	addi	a1,s0,-56
    80004950:	fd040513          	addi	a0,s0,-48
    80004954:	8ceff0ef          	jal	ra,80003a22 <pipealloc>
    return -1;
    80004958:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000495a:	0a054463          	bltz	a0,80004a02 <sys_pipe+0xd0>
  fd0 = -1;
    8000495e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004962:	fd043503          	ld	a0,-48(s0)
    80004966:	f3cff0ef          	jal	ra,800040a2 <fdalloc>
    8000496a:	fca42223          	sw	a0,-60(s0)
    8000496e:	08054163          	bltz	a0,800049f0 <sys_pipe+0xbe>
    80004972:	fc843503          	ld	a0,-56(s0)
    80004976:	f2cff0ef          	jal	ra,800040a2 <fdalloc>
    8000497a:	fca42023          	sw	a0,-64(s0)
    8000497e:	06054063          	bltz	a0,800049de <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004982:	4691                	li	a3,4
    80004984:	fc440613          	addi	a2,s0,-60
    80004988:	fd843583          	ld	a1,-40(s0)
    8000498c:	68a8                	ld	a0,80(s1)
    8000498e:	bb2fc0ef          	jal	ra,80000d40 <copyout>
    80004992:	00054e63          	bltz	a0,800049ae <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004996:	4691                	li	a3,4
    80004998:	fc040613          	addi	a2,s0,-64
    8000499c:	fd843583          	ld	a1,-40(s0)
    800049a0:	0591                	addi	a1,a1,4
    800049a2:	68a8                	ld	a0,80(s1)
    800049a4:	b9cfc0ef          	jal	ra,80000d40 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800049a8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800049aa:	04055c63          	bgez	a0,80004a02 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800049ae:	fc442783          	lw	a5,-60(s0)
    800049b2:	07e9                	addi	a5,a5,26
    800049b4:	078e                	slli	a5,a5,0x3
    800049b6:	97a6                	add	a5,a5,s1
    800049b8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800049bc:	fc042783          	lw	a5,-64(s0)
    800049c0:	07e9                	addi	a5,a5,26
    800049c2:	078e                	slli	a5,a5,0x3
    800049c4:	94be                	add	s1,s1,a5
    800049c6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800049ca:	fd043503          	ld	a0,-48(s0)
    800049ce:	d89fe0ef          	jal	ra,80003756 <fileclose>
    fileclose(wf);
    800049d2:	fc843503          	ld	a0,-56(s0)
    800049d6:	d81fe0ef          	jal	ra,80003756 <fileclose>
    return -1;
    800049da:	57fd                	li	a5,-1
    800049dc:	a01d                	j	80004a02 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800049de:	fc442783          	lw	a5,-60(s0)
    800049e2:	0007c763          	bltz	a5,800049f0 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800049e6:	07e9                	addi	a5,a5,26
    800049e8:	078e                	slli	a5,a5,0x3
    800049ea:	97a6                	add	a5,a5,s1
    800049ec:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800049f0:	fd043503          	ld	a0,-48(s0)
    800049f4:	d63fe0ef          	jal	ra,80003756 <fileclose>
    fileclose(wf);
    800049f8:	fc843503          	ld	a0,-56(s0)
    800049fc:	d5bfe0ef          	jal	ra,80003756 <fileclose>
    return -1;
    80004a00:	57fd                	li	a5,-1
}
    80004a02:	853e                	mv	a0,a5
    80004a04:	70e2                	ld	ra,56(sp)
    80004a06:	7442                	ld	s0,48(sp)
    80004a08:	74a2                	ld	s1,40(sp)
    80004a0a:	6121                	addi	sp,sp,64
    80004a0c:	8082                	ret
	...

0000000080004a10 <kernelvec>:
    80004a10:	7111                	addi	sp,sp,-256
    80004a12:	e006                	sd	ra,0(sp)
    80004a14:	e40a                	sd	sp,8(sp)
    80004a16:	e80e                	sd	gp,16(sp)
    80004a18:	ec12                	sd	tp,24(sp)
    80004a1a:	f016                	sd	t0,32(sp)
    80004a1c:	f41a                	sd	t1,40(sp)
    80004a1e:	f81e                	sd	t2,48(sp)
    80004a20:	e4aa                	sd	a0,72(sp)
    80004a22:	e8ae                	sd	a1,80(sp)
    80004a24:	ecb2                	sd	a2,88(sp)
    80004a26:	f0b6                	sd	a3,96(sp)
    80004a28:	f4ba                	sd	a4,104(sp)
    80004a2a:	f8be                	sd	a5,112(sp)
    80004a2c:	fcc2                	sd	a6,120(sp)
    80004a2e:	e146                	sd	a7,128(sp)
    80004a30:	edf2                	sd	t3,216(sp)
    80004a32:	f1f6                	sd	t4,224(sp)
    80004a34:	f5fa                	sd	t5,232(sp)
    80004a36:	f9fe                	sd	t6,240(sp)
    80004a38:	c98fd0ef          	jal	ra,80001ed0 <kerneltrap>
    80004a3c:	6082                	ld	ra,0(sp)
    80004a3e:	6122                	ld	sp,8(sp)
    80004a40:	61c2                	ld	gp,16(sp)
    80004a42:	7282                	ld	t0,32(sp)
    80004a44:	7322                	ld	t1,40(sp)
    80004a46:	73c2                	ld	t2,48(sp)
    80004a48:	6526                	ld	a0,72(sp)
    80004a4a:	65c6                	ld	a1,80(sp)
    80004a4c:	6666                	ld	a2,88(sp)
    80004a4e:	7686                	ld	a3,96(sp)
    80004a50:	7726                	ld	a4,104(sp)
    80004a52:	77c6                	ld	a5,112(sp)
    80004a54:	7866                	ld	a6,120(sp)
    80004a56:	688a                	ld	a7,128(sp)
    80004a58:	6e6e                	ld	t3,216(sp)
    80004a5a:	7e8e                	ld	t4,224(sp)
    80004a5c:	7f2e                	ld	t5,232(sp)
    80004a5e:	7fce                	ld	t6,240(sp)
    80004a60:	6111                	addi	sp,sp,256
    80004a62:	10200073          	sret
	...

0000000080004a6e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80004a6e:	1141                	addi	sp,sp,-16
    80004a70:	e422                	sd	s0,8(sp)
    80004a72:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004a74:	0c0007b7          	lui	a5,0xc000
    80004a78:	4705                	li	a4,1
    80004a7a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80004a7c:	c3d8                	sw	a4,4(a5)
}
    80004a7e:	6422                	ld	s0,8(sp)
    80004a80:	0141                	addi	sp,sp,16
    80004a82:	8082                	ret

0000000080004a84 <plicinithart>:

void
plicinithart(void)
{
    80004a84:	1141                	addi	sp,sp,-16
    80004a86:	e406                	sd	ra,8(sp)
    80004a88:	e022                	sd	s0,0(sp)
    80004a8a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004a8c:	ee4fc0ef          	jal	ra,80001170 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004a90:	0085171b          	slliw	a4,a0,0x8
    80004a94:	0c0027b7          	lui	a5,0xc002
    80004a98:	97ba                	add	a5,a5,a4
    80004a9a:	40200713          	li	a4,1026
    80004a9e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004aa2:	00d5151b          	slliw	a0,a0,0xd
    80004aa6:	0c2017b7          	lui	a5,0xc201
    80004aaa:	97aa                	add	a5,a5,a0
    80004aac:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80004ab0:	60a2                	ld	ra,8(sp)
    80004ab2:	6402                	ld	s0,0(sp)
    80004ab4:	0141                	addi	sp,sp,16
    80004ab6:	8082                	ret

0000000080004ab8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80004ab8:	1141                	addi	sp,sp,-16
    80004aba:	e406                	sd	ra,8(sp)
    80004abc:	e022                	sd	s0,0(sp)
    80004abe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004ac0:	eb0fc0ef          	jal	ra,80001170 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80004ac4:	00d5151b          	slliw	a0,a0,0xd
    80004ac8:	0c2017b7          	lui	a5,0xc201
    80004acc:	97aa                	add	a5,a5,a0
  return irq;
}
    80004ace:	43c8                	lw	a0,4(a5)
    80004ad0:	60a2                	ld	ra,8(sp)
    80004ad2:	6402                	ld	s0,0(sp)
    80004ad4:	0141                	addi	sp,sp,16
    80004ad6:	8082                	ret

0000000080004ad8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80004ad8:	1101                	addi	sp,sp,-32
    80004ada:	ec06                	sd	ra,24(sp)
    80004adc:	e822                	sd	s0,16(sp)
    80004ade:	e426                	sd	s1,8(sp)
    80004ae0:	1000                	addi	s0,sp,32
    80004ae2:	84aa                	mv	s1,a0
  int hart = cpuid();
    80004ae4:	e8cfc0ef          	jal	ra,80001170 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80004ae8:	00d5151b          	slliw	a0,a0,0xd
    80004aec:	0c2017b7          	lui	a5,0xc201
    80004af0:	97aa                	add	a5,a5,a0
    80004af2:	c3c4                	sw	s1,4(a5)
}
    80004af4:	60e2                	ld	ra,24(sp)
    80004af6:	6442                	ld	s0,16(sp)
    80004af8:	64a2                	ld	s1,8(sp)
    80004afa:	6105                	addi	sp,sp,32
    80004afc:	8082                	ret

0000000080004afe <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80004afe:	1141                	addi	sp,sp,-16
    80004b00:	e406                	sd	ra,8(sp)
    80004b02:	e022                	sd	s0,0(sp)
    80004b04:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80004b06:	479d                	li	a5,7
    80004b08:	04a7ca63          	blt	a5,a0,80004b5c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80004b0c:	00014797          	auipc	a5,0x14
    80004b10:	28478793          	addi	a5,a5,644 # 80018d90 <disk>
    80004b14:	97aa                	add	a5,a5,a0
    80004b16:	0187c783          	lbu	a5,24(a5)
    80004b1a:	e7b9                	bnez	a5,80004b68 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004b1c:	00451693          	slli	a3,a0,0x4
    80004b20:	00014797          	auipc	a5,0x14
    80004b24:	27078793          	addi	a5,a5,624 # 80018d90 <disk>
    80004b28:	6398                	ld	a4,0(a5)
    80004b2a:	9736                	add	a4,a4,a3
    80004b2c:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004b30:	6398                	ld	a4,0(a5)
    80004b32:	9736                	add	a4,a4,a3
    80004b34:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80004b38:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004b3c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004b40:	97aa                	add	a5,a5,a0
    80004b42:	4705                	li	a4,1
    80004b44:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80004b48:	00014517          	auipc	a0,0x14
    80004b4c:	26050513          	addi	a0,a0,608 # 80018da8 <disk+0x18>
    80004b50:	c65fc0ef          	jal	ra,800017b4 <wakeup>
}
    80004b54:	60a2                	ld	ra,8(sp)
    80004b56:	6402                	ld	s0,0(sp)
    80004b58:	0141                	addi	sp,sp,16
    80004b5a:	8082                	ret
    panic("free_desc 1");
    80004b5c:	00003517          	auipc	a0,0x3
    80004b60:	d2c50513          	addi	a0,a0,-724 # 80007888 <syscalls+0x358>
    80004b64:	3bf000ef          	jal	ra,80005722 <panic>
    panic("free_desc 2");
    80004b68:	00003517          	auipc	a0,0x3
    80004b6c:	d3050513          	addi	a0,a0,-720 # 80007898 <syscalls+0x368>
    80004b70:	3b3000ef          	jal	ra,80005722 <panic>

0000000080004b74 <virtio_disk_init>:
{
    80004b74:	1101                	addi	sp,sp,-32
    80004b76:	ec06                	sd	ra,24(sp)
    80004b78:	e822                	sd	s0,16(sp)
    80004b7a:	e426                	sd	s1,8(sp)
    80004b7c:	e04a                	sd	s2,0(sp)
    80004b7e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004b80:	00003597          	auipc	a1,0x3
    80004b84:	d2858593          	addi	a1,a1,-728 # 800078a8 <syscalls+0x378>
    80004b88:	00014517          	auipc	a0,0x14
    80004b8c:	33050513          	addi	a0,a0,816 # 80018eb8 <disk+0x128>
    80004b90:	623000ef          	jal	ra,800059b2 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004b94:	100017b7          	lui	a5,0x10001
    80004b98:	4398                	lw	a4,0(a5)
    80004b9a:	2701                	sext.w	a4,a4
    80004b9c:	747277b7          	lui	a5,0x74727
    80004ba0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004ba4:	12f71f63          	bne	a4,a5,80004ce2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004ba8:	100017b7          	lui	a5,0x10001
    80004bac:	43dc                	lw	a5,4(a5)
    80004bae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004bb0:	4709                	li	a4,2
    80004bb2:	12e79863          	bne	a5,a4,80004ce2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004bb6:	100017b7          	lui	a5,0x10001
    80004bba:	479c                	lw	a5,8(a5)
    80004bbc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004bbe:	12e79263          	bne	a5,a4,80004ce2 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80004bc2:	100017b7          	lui	a5,0x10001
    80004bc6:	47d8                	lw	a4,12(a5)
    80004bc8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004bca:	554d47b7          	lui	a5,0x554d4
    80004bce:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004bd2:	10f71863          	bne	a4,a5,80004ce2 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004bd6:	100017b7          	lui	a5,0x10001
    80004bda:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004bde:	4705                	li	a4,1
    80004be0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004be2:	470d                	li	a4,3
    80004be4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004be6:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004be8:	c7ffe6b7          	lui	a3,0xc7ffe
    80004bec:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd78f>
    80004bf0:	8f75                	and	a4,a4,a3
    80004bf2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004bf4:	472d                	li	a4,11
    80004bf6:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80004bf8:	5bbc                	lw	a5,112(a5)
    80004bfa:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004bfe:	8ba1                	andi	a5,a5,8
    80004c00:	0e078763          	beqz	a5,80004cee <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004c04:	100017b7          	lui	a5,0x10001
    80004c08:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004c0c:	43fc                	lw	a5,68(a5)
    80004c0e:	2781                	sext.w	a5,a5
    80004c10:	0e079563          	bnez	a5,80004cfa <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004c14:	100017b7          	lui	a5,0x10001
    80004c18:	5bdc                	lw	a5,52(a5)
    80004c1a:	2781                	sext.w	a5,a5
  if(max == 0)
    80004c1c:	0e078563          	beqz	a5,80004d06 <virtio_disk_init+0x192>
  if(max < NUM)
    80004c20:	471d                	li	a4,7
    80004c22:	0ef77863          	bgeu	a4,a5,80004d12 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80004c26:	d3efb0ef          	jal	ra,80000164 <kalloc>
    80004c2a:	00014497          	auipc	s1,0x14
    80004c2e:	16648493          	addi	s1,s1,358 # 80018d90 <disk>
    80004c32:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004c34:	d30fb0ef          	jal	ra,80000164 <kalloc>
    80004c38:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004c3a:	d2afb0ef          	jal	ra,80000164 <kalloc>
    80004c3e:	87aa                	mv	a5,a0
    80004c40:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004c42:	6088                	ld	a0,0(s1)
    80004c44:	cd69                	beqz	a0,80004d1e <virtio_disk_init+0x1aa>
    80004c46:	00014717          	auipc	a4,0x14
    80004c4a:	15273703          	ld	a4,338(a4) # 80018d98 <disk+0x8>
    80004c4e:	cb61                	beqz	a4,80004d1e <virtio_disk_init+0x1aa>
    80004c50:	c7f9                	beqz	a5,80004d1e <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80004c52:	6605                	lui	a2,0x1
    80004c54:	4581                	li	a1,0
    80004c56:	e5cfb0ef          	jal	ra,800002b2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80004c5a:	00014497          	auipc	s1,0x14
    80004c5e:	13648493          	addi	s1,s1,310 # 80018d90 <disk>
    80004c62:	6605                	lui	a2,0x1
    80004c64:	4581                	li	a1,0
    80004c66:	6488                	ld	a0,8(s1)
    80004c68:	e4afb0ef          	jal	ra,800002b2 <memset>
  memset(disk.used, 0, PGSIZE);
    80004c6c:	6605                	lui	a2,0x1
    80004c6e:	4581                	li	a1,0
    80004c70:	6888                	ld	a0,16(s1)
    80004c72:	e40fb0ef          	jal	ra,800002b2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004c76:	100017b7          	lui	a5,0x10001
    80004c7a:	4721                	li	a4,8
    80004c7c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004c7e:	4098                	lw	a4,0(s1)
    80004c80:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004c84:	40d8                	lw	a4,4(s1)
    80004c86:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004c8a:	6498                	ld	a4,8(s1)
    80004c8c:	0007069b          	sext.w	a3,a4
    80004c90:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004c94:	9701                	srai	a4,a4,0x20
    80004c96:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004c9a:	6898                	ld	a4,16(s1)
    80004c9c:	0007069b          	sext.w	a3,a4
    80004ca0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004ca4:	9701                	srai	a4,a4,0x20
    80004ca6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004caa:	4705                	li	a4,1
    80004cac:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80004cae:	00e48c23          	sb	a4,24(s1)
    80004cb2:	00e48ca3          	sb	a4,25(s1)
    80004cb6:	00e48d23          	sb	a4,26(s1)
    80004cba:	00e48da3          	sb	a4,27(s1)
    80004cbe:	00e48e23          	sb	a4,28(s1)
    80004cc2:	00e48ea3          	sb	a4,29(s1)
    80004cc6:	00e48f23          	sb	a4,30(s1)
    80004cca:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004cce:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004cd2:	0727a823          	sw	s2,112(a5)
}
    80004cd6:	60e2                	ld	ra,24(sp)
    80004cd8:	6442                	ld	s0,16(sp)
    80004cda:	64a2                	ld	s1,8(sp)
    80004cdc:	6902                	ld	s2,0(sp)
    80004cde:	6105                	addi	sp,sp,32
    80004ce0:	8082                	ret
    panic("could not find virtio disk");
    80004ce2:	00003517          	auipc	a0,0x3
    80004ce6:	bd650513          	addi	a0,a0,-1066 # 800078b8 <syscalls+0x388>
    80004cea:	239000ef          	jal	ra,80005722 <panic>
    panic("virtio disk FEATURES_OK unset");
    80004cee:	00003517          	auipc	a0,0x3
    80004cf2:	bea50513          	addi	a0,a0,-1046 # 800078d8 <syscalls+0x3a8>
    80004cf6:	22d000ef          	jal	ra,80005722 <panic>
    panic("virtio disk should not be ready");
    80004cfa:	00003517          	auipc	a0,0x3
    80004cfe:	bfe50513          	addi	a0,a0,-1026 # 800078f8 <syscalls+0x3c8>
    80004d02:	221000ef          	jal	ra,80005722 <panic>
    panic("virtio disk has no queue 0");
    80004d06:	00003517          	auipc	a0,0x3
    80004d0a:	c1250513          	addi	a0,a0,-1006 # 80007918 <syscalls+0x3e8>
    80004d0e:	215000ef          	jal	ra,80005722 <panic>
    panic("virtio disk max queue too short");
    80004d12:	00003517          	auipc	a0,0x3
    80004d16:	c2650513          	addi	a0,a0,-986 # 80007938 <syscalls+0x408>
    80004d1a:	209000ef          	jal	ra,80005722 <panic>
    panic("virtio disk kalloc");
    80004d1e:	00003517          	auipc	a0,0x3
    80004d22:	c3a50513          	addi	a0,a0,-966 # 80007958 <syscalls+0x428>
    80004d26:	1fd000ef          	jal	ra,80005722 <panic>

0000000080004d2a <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004d2a:	7119                	addi	sp,sp,-128
    80004d2c:	fc86                	sd	ra,120(sp)
    80004d2e:	f8a2                	sd	s0,112(sp)
    80004d30:	f4a6                	sd	s1,104(sp)
    80004d32:	f0ca                	sd	s2,96(sp)
    80004d34:	ecce                	sd	s3,88(sp)
    80004d36:	e8d2                	sd	s4,80(sp)
    80004d38:	e4d6                	sd	s5,72(sp)
    80004d3a:	e0da                	sd	s6,64(sp)
    80004d3c:	fc5e                	sd	s7,56(sp)
    80004d3e:	f862                	sd	s8,48(sp)
    80004d40:	f466                	sd	s9,40(sp)
    80004d42:	f06a                	sd	s10,32(sp)
    80004d44:	ec6e                	sd	s11,24(sp)
    80004d46:	0100                	addi	s0,sp,128
    80004d48:	8aaa                	mv	s5,a0
    80004d4a:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004d4c:	00c52d03          	lw	s10,12(a0)
    80004d50:	001d1d1b          	slliw	s10,s10,0x1
    80004d54:	1d02                	slli	s10,s10,0x20
    80004d56:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80004d5a:	00014517          	auipc	a0,0x14
    80004d5e:	15e50513          	addi	a0,a0,350 # 80018eb8 <disk+0x128>
    80004d62:	4d1000ef          	jal	ra,80005a32 <acquire>
  for(int i = 0; i < 3; i++){
    80004d66:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004d68:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004d6a:	00014b97          	auipc	s7,0x14
    80004d6e:	026b8b93          	addi	s7,s7,38 # 80018d90 <disk>
  for(int i = 0; i < 3; i++){
    80004d72:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004d74:	00014c97          	auipc	s9,0x14
    80004d78:	144c8c93          	addi	s9,s9,324 # 80018eb8 <disk+0x128>
    80004d7c:	a8a9                	j	80004dd6 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004d7e:	00fb8733          	add	a4,s7,a5
    80004d82:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80004d86:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004d88:	0207c563          	bltz	a5,80004db2 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80004d8c:	2905                	addiw	s2,s2,1
    80004d8e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004d90:	05690863          	beq	s2,s6,80004de0 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80004d94:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004d96:	00014717          	auipc	a4,0x14
    80004d9a:	ffa70713          	addi	a4,a4,-6 # 80018d90 <disk>
    80004d9e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004da0:	01874683          	lbu	a3,24(a4)
    80004da4:	fee9                	bnez	a3,80004d7e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80004da6:	2785                	addiw	a5,a5,1
    80004da8:	0705                	addi	a4,a4,1
    80004daa:	fe979be3          	bne	a5,s1,80004da0 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80004dae:	57fd                	li	a5,-1
    80004db0:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004db2:	01205b63          	blez	s2,80004dc8 <virtio_disk_rw+0x9e>
    80004db6:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80004db8:	000a2503          	lw	a0,0(s4)
    80004dbc:	d43ff0ef          	jal	ra,80004afe <free_desc>
      for(int j = 0; j < i; j++)
    80004dc0:	2d85                	addiw	s11,s11,1
    80004dc2:	0a11                	addi	s4,s4,4
    80004dc4:	ff2d9ae3          	bne	s11,s2,80004db8 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004dc8:	85e6                	mv	a1,s9
    80004dca:	00014517          	auipc	a0,0x14
    80004dce:	fde50513          	addi	a0,a0,-34 # 80018da8 <disk+0x18>
    80004dd2:	997fc0ef          	jal	ra,80001768 <sleep>
  for(int i = 0; i < 3; i++){
    80004dd6:	f8040a13          	addi	s4,s0,-128
{
    80004dda:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80004ddc:	894e                	mv	s2,s3
    80004dde:	bf5d                	j	80004d94 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004de0:	f8042503          	lw	a0,-128(s0)
    80004de4:	00a50713          	addi	a4,a0,10
    80004de8:	0712                	slli	a4,a4,0x4

  if(write)
    80004dea:	00014797          	auipc	a5,0x14
    80004dee:	fa678793          	addi	a5,a5,-90 # 80018d90 <disk>
    80004df2:	00e786b3          	add	a3,a5,a4
    80004df6:	01803633          	snez	a2,s8
    80004dfa:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004dfc:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80004e00:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004e04:	f6070613          	addi	a2,a4,-160
    80004e08:	6394                	ld	a3,0(a5)
    80004e0a:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004e0c:	00870593          	addi	a1,a4,8
    80004e10:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004e12:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004e14:	0007b803          	ld	a6,0(a5)
    80004e18:	9642                	add	a2,a2,a6
    80004e1a:	46c1                	li	a3,16
    80004e1c:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004e1e:	4585                	li	a1,1
    80004e20:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80004e24:	f8442683          	lw	a3,-124(s0)
    80004e28:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004e2c:	0692                	slli	a3,a3,0x4
    80004e2e:	9836                	add	a6,a6,a3
    80004e30:	058a8613          	addi	a2,s5,88
    80004e34:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80004e38:	0007b803          	ld	a6,0(a5)
    80004e3c:	96c2                	add	a3,a3,a6
    80004e3e:	40000613          	li	a2,1024
    80004e42:	c690                	sw	a2,8(a3)
  if(write)
    80004e44:	001c3613          	seqz	a2,s8
    80004e48:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004e4c:	00166613          	ori	a2,a2,1
    80004e50:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80004e54:	f8842603          	lw	a2,-120(s0)
    80004e58:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004e5c:	00250693          	addi	a3,a0,2
    80004e60:	0692                	slli	a3,a3,0x4
    80004e62:	96be                	add	a3,a3,a5
    80004e64:	58fd                	li	a7,-1
    80004e66:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004e6a:	0612                	slli	a2,a2,0x4
    80004e6c:	9832                	add	a6,a6,a2
    80004e6e:	f9070713          	addi	a4,a4,-112
    80004e72:	973e                	add	a4,a4,a5
    80004e74:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80004e78:	6398                	ld	a4,0(a5)
    80004e7a:	9732                	add	a4,a4,a2
    80004e7c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004e7e:	4609                	li	a2,2
    80004e80:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80004e84:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004e88:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80004e8c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004e90:	6794                	ld	a3,8(a5)
    80004e92:	0026d703          	lhu	a4,2(a3)
    80004e96:	8b1d                	andi	a4,a4,7
    80004e98:	0706                	slli	a4,a4,0x1
    80004e9a:	96ba                	add	a3,a3,a4
    80004e9c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004ea0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004ea4:	6798                	ld	a4,8(a5)
    80004ea6:	00275783          	lhu	a5,2(a4)
    80004eaa:	2785                	addiw	a5,a5,1
    80004eac:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004eb0:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004eb4:	100017b7          	lui	a5,0x10001
    80004eb8:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004ebc:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80004ec0:	00014917          	auipc	s2,0x14
    80004ec4:	ff890913          	addi	s2,s2,-8 # 80018eb8 <disk+0x128>
  while(b->disk == 1) {
    80004ec8:	4485                	li	s1,1
    80004eca:	00b79a63          	bne	a5,a1,80004ede <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80004ece:	85ca                	mv	a1,s2
    80004ed0:	8556                	mv	a0,s5
    80004ed2:	897fc0ef          	jal	ra,80001768 <sleep>
  while(b->disk == 1) {
    80004ed6:	004aa783          	lw	a5,4(s5)
    80004eda:	fe978ae3          	beq	a5,s1,80004ece <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80004ede:	f8042903          	lw	s2,-128(s0)
    80004ee2:	00290713          	addi	a4,s2,2
    80004ee6:	0712                	slli	a4,a4,0x4
    80004ee8:	00014797          	auipc	a5,0x14
    80004eec:	ea878793          	addi	a5,a5,-344 # 80018d90 <disk>
    80004ef0:	97ba                	add	a5,a5,a4
    80004ef2:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004ef6:	00014997          	auipc	s3,0x14
    80004efa:	e9a98993          	addi	s3,s3,-358 # 80018d90 <disk>
    80004efe:	00491713          	slli	a4,s2,0x4
    80004f02:	0009b783          	ld	a5,0(s3)
    80004f06:	97ba                	add	a5,a5,a4
    80004f08:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004f0c:	854a                	mv	a0,s2
    80004f0e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004f12:	bedff0ef          	jal	ra,80004afe <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004f16:	8885                	andi	s1,s1,1
    80004f18:	f0fd                	bnez	s1,80004efe <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004f1a:	00014517          	auipc	a0,0x14
    80004f1e:	f9e50513          	addi	a0,a0,-98 # 80018eb8 <disk+0x128>
    80004f22:	3a9000ef          	jal	ra,80005aca <release>
}
    80004f26:	70e6                	ld	ra,120(sp)
    80004f28:	7446                	ld	s0,112(sp)
    80004f2a:	74a6                	ld	s1,104(sp)
    80004f2c:	7906                	ld	s2,96(sp)
    80004f2e:	69e6                	ld	s3,88(sp)
    80004f30:	6a46                	ld	s4,80(sp)
    80004f32:	6aa6                	ld	s5,72(sp)
    80004f34:	6b06                	ld	s6,64(sp)
    80004f36:	7be2                	ld	s7,56(sp)
    80004f38:	7c42                	ld	s8,48(sp)
    80004f3a:	7ca2                	ld	s9,40(sp)
    80004f3c:	7d02                	ld	s10,32(sp)
    80004f3e:	6de2                	ld	s11,24(sp)
    80004f40:	6109                	addi	sp,sp,128
    80004f42:	8082                	ret

0000000080004f44 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004f44:	1101                	addi	sp,sp,-32
    80004f46:	ec06                	sd	ra,24(sp)
    80004f48:	e822                	sd	s0,16(sp)
    80004f4a:	e426                	sd	s1,8(sp)
    80004f4c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004f4e:	00014497          	auipc	s1,0x14
    80004f52:	e4248493          	addi	s1,s1,-446 # 80018d90 <disk>
    80004f56:	00014517          	auipc	a0,0x14
    80004f5a:	f6250513          	addi	a0,a0,-158 # 80018eb8 <disk+0x128>
    80004f5e:	2d5000ef          	jal	ra,80005a32 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004f62:	10001737          	lui	a4,0x10001
    80004f66:	533c                	lw	a5,96(a4)
    80004f68:	8b8d                	andi	a5,a5,3
    80004f6a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80004f6c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004f70:	689c                	ld	a5,16(s1)
    80004f72:	0204d703          	lhu	a4,32(s1)
    80004f76:	0027d783          	lhu	a5,2(a5)
    80004f7a:	04f70663          	beq	a4,a5,80004fc6 <virtio_disk_intr+0x82>
    __sync_synchronize();
    80004f7e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004f82:	6898                	ld	a4,16(s1)
    80004f84:	0204d783          	lhu	a5,32(s1)
    80004f88:	8b9d                	andi	a5,a5,7
    80004f8a:	078e                	slli	a5,a5,0x3
    80004f8c:	97ba                	add	a5,a5,a4
    80004f8e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004f90:	00278713          	addi	a4,a5,2
    80004f94:	0712                	slli	a4,a4,0x4
    80004f96:	9726                	add	a4,a4,s1
    80004f98:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80004f9c:	e321                	bnez	a4,80004fdc <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004f9e:	0789                	addi	a5,a5,2
    80004fa0:	0792                	slli	a5,a5,0x4
    80004fa2:	97a6                	add	a5,a5,s1
    80004fa4:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004fa6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004faa:	80bfc0ef          	jal	ra,800017b4 <wakeup>

    disk.used_idx += 1;
    80004fae:	0204d783          	lhu	a5,32(s1)
    80004fb2:	2785                	addiw	a5,a5,1
    80004fb4:	17c2                	slli	a5,a5,0x30
    80004fb6:	93c1                	srli	a5,a5,0x30
    80004fb8:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004fbc:	6898                	ld	a4,16(s1)
    80004fbe:	00275703          	lhu	a4,2(a4)
    80004fc2:	faf71ee3          	bne	a4,a5,80004f7e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80004fc6:	00014517          	auipc	a0,0x14
    80004fca:	ef250513          	addi	a0,a0,-270 # 80018eb8 <disk+0x128>
    80004fce:	2fd000ef          	jal	ra,80005aca <release>
}
    80004fd2:	60e2                	ld	ra,24(sp)
    80004fd4:	6442                	ld	s0,16(sp)
    80004fd6:	64a2                	ld	s1,8(sp)
    80004fd8:	6105                	addi	sp,sp,32
    80004fda:	8082                	ret
      panic("virtio_disk_intr status");
    80004fdc:	00003517          	auipc	a0,0x3
    80004fe0:	99450513          	addi	a0,a0,-1644 # 80007970 <syscalls+0x440>
    80004fe4:	73e000ef          	jal	ra,80005722 <panic>

0000000080004fe8 <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004fe8:	1141                	addi	sp,sp,-16
    80004fea:	e422                	sd	s0,8(sp)
    80004fec:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004fee:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004ff2:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004ff6:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004ffa:	30a027f3          	csrr	a5,0x30a

  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63));
    80004ffe:	577d                	li	a4,-1
    80005000:	177e                	slli	a4,a4,0x3f
    80005002:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80005004:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80005008:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    8000500c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80005010:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80005014:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80005018:	000f4737          	lui	a4,0xf4
    8000501c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80005020:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80005022:	14d79073          	csrw	0x14d,a5
}
    80005026:	6422                	ld	s0,8(sp)
    80005028:	0141                	addi	sp,sp,16
    8000502a:	8082                	ret

000000008000502c <start>:
{
    8000502c:	1141                	addi	sp,sp,-16
    8000502e:	e406                	sd	ra,8(sp)
    80005030:	e022                	sd	s0,0(sp)
    80005032:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80005034:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80005038:	7779                	lui	a4,0xffffe
    8000503a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd82f>
    8000503e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80005040:	6705                	lui	a4,0x1
    80005042:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80005046:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005048:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    8000504c:	ffffb797          	auipc	a5,0xffffb
    80005050:	40878793          	addi	a5,a5,1032 # 80000454 <main>
    80005054:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80005058:	4781                	li	a5,0
    8000505a:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    8000505e:	67c1                	lui	a5,0x10
    80005060:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80005062:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80005066:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000506a:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    8000506e:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80005072:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80005076:	57fd                	li	a5,-1
    80005078:	83a9                	srli	a5,a5,0xa
    8000507a:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    8000507e:	47bd                	li	a5,15
    80005080:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80005084:	f65ff0ef          	jal	ra,80004fe8 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80005088:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    8000508c:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    8000508e:	823e                	mv	tp,a5
  asm volatile("mret");
    80005090:	30200073          	mret
}
    80005094:	60a2                	ld	ra,8(sp)
    80005096:	6402                	ld	s0,0(sp)
    80005098:	0141                	addi	sp,sp,16
    8000509a:	8082                	ret

000000008000509c <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    8000509c:	715d                	addi	sp,sp,-80
    8000509e:	e486                	sd	ra,72(sp)
    800050a0:	e0a2                	sd	s0,64(sp)
    800050a2:	fc26                	sd	s1,56(sp)
    800050a4:	f84a                	sd	s2,48(sp)
    800050a6:	f44e                	sd	s3,40(sp)
    800050a8:	f052                	sd	s4,32(sp)
    800050aa:	ec56                	sd	s5,24(sp)
    800050ac:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800050ae:	04c05363          	blez	a2,800050f4 <consolewrite+0x58>
    800050b2:	8a2a                	mv	s4,a0
    800050b4:	84ae                	mv	s1,a1
    800050b6:	89b2                	mv	s3,a2
    800050b8:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800050ba:	5afd                	li	s5,-1
    800050bc:	4685                	li	a3,1
    800050be:	8626                	mv	a2,s1
    800050c0:	85d2                	mv	a1,s4
    800050c2:	fbf40513          	addi	a0,s0,-65
    800050c6:	a49fc0ef          	jal	ra,80001b0e <either_copyin>
    800050ca:	01550b63          	beq	a0,s5,800050e0 <consolewrite+0x44>
      break;
    uartputc(c);
    800050ce:	fbf44503          	lbu	a0,-65(s0)
    800050d2:	7da000ef          	jal	ra,800058ac <uartputc>
  for(i = 0; i < n; i++){
    800050d6:	2905                	addiw	s2,s2,1
    800050d8:	0485                	addi	s1,s1,1
    800050da:	ff2991e3          	bne	s3,s2,800050bc <consolewrite+0x20>
    800050de:	894e                	mv	s2,s3
  }

  return i;
}
    800050e0:	854a                	mv	a0,s2
    800050e2:	60a6                	ld	ra,72(sp)
    800050e4:	6406                	ld	s0,64(sp)
    800050e6:	74e2                	ld	s1,56(sp)
    800050e8:	7942                	ld	s2,48(sp)
    800050ea:	79a2                	ld	s3,40(sp)
    800050ec:	7a02                	ld	s4,32(sp)
    800050ee:	6ae2                	ld	s5,24(sp)
    800050f0:	6161                	addi	sp,sp,80
    800050f2:	8082                	ret
  for(i = 0; i < n; i++){
    800050f4:	4901                	li	s2,0
    800050f6:	b7ed                	j	800050e0 <consolewrite+0x44>

00000000800050f8 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    800050f8:	7159                	addi	sp,sp,-112
    800050fa:	f486                	sd	ra,104(sp)
    800050fc:	f0a2                	sd	s0,96(sp)
    800050fe:	eca6                	sd	s1,88(sp)
    80005100:	e8ca                	sd	s2,80(sp)
    80005102:	e4ce                	sd	s3,72(sp)
    80005104:	e0d2                	sd	s4,64(sp)
    80005106:	fc56                	sd	s5,56(sp)
    80005108:	f85a                	sd	s6,48(sp)
    8000510a:	f45e                	sd	s7,40(sp)
    8000510c:	f062                	sd	s8,32(sp)
    8000510e:	ec66                	sd	s9,24(sp)
    80005110:	e86a                	sd	s10,16(sp)
    80005112:	1880                	addi	s0,sp,112
    80005114:	8aaa                	mv	s5,a0
    80005116:	8a2e                	mv	s4,a1
    80005118:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000511a:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000511e:	0001c517          	auipc	a0,0x1c
    80005122:	db250513          	addi	a0,a0,-590 # 80020ed0 <cons>
    80005126:	10d000ef          	jal	ra,80005a32 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000512a:	0001c497          	auipc	s1,0x1c
    8000512e:	da648493          	addi	s1,s1,-602 # 80020ed0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80005132:	0001c917          	auipc	s2,0x1c
    80005136:	e3690913          	addi	s2,s2,-458 # 80020f68 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    8000513a:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000513c:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000513e:	4ca9                	li	s9,10
  while(n > 0){
    80005140:	07305363          	blez	s3,800051a6 <consoleread+0xae>
    while(cons.r == cons.w){
    80005144:	0984a783          	lw	a5,152(s1)
    80005148:	09c4a703          	lw	a4,156(s1)
    8000514c:	02f71163          	bne	a4,a5,8000516e <consoleread+0x76>
      if(killed(myproc())){
    80005150:	84cfc0ef          	jal	ra,8000119c <myproc>
    80005154:	84dfc0ef          	jal	ra,800019a0 <killed>
    80005158:	e125                	bnez	a0,800051b8 <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    8000515a:	85a6                	mv	a1,s1
    8000515c:	854a                	mv	a0,s2
    8000515e:	e0afc0ef          	jal	ra,80001768 <sleep>
    while(cons.r == cons.w){
    80005162:	0984a783          	lw	a5,152(s1)
    80005166:	09c4a703          	lw	a4,156(s1)
    8000516a:	fef703e3          	beq	a4,a5,80005150 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    8000516e:	0017871b          	addiw	a4,a5,1
    80005172:	08e4ac23          	sw	a4,152(s1)
    80005176:	07f7f713          	andi	a4,a5,127
    8000517a:	9726                	add	a4,a4,s1
    8000517c:	01874703          	lbu	a4,24(a4)
    80005180:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80005184:	057d0f63          	beq	s10,s7,800051e2 <consoleread+0xea>
    cbuf = c;
    80005188:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000518c:	4685                	li	a3,1
    8000518e:	f9f40613          	addi	a2,s0,-97
    80005192:	85d2                	mv	a1,s4
    80005194:	8556                	mv	a0,s5
    80005196:	92ffc0ef          	jal	ra,80001ac4 <either_copyout>
    8000519a:	01850663          	beq	a0,s8,800051a6 <consoleread+0xae>
    dst++;
    8000519e:	0a05                	addi	s4,s4,1
    --n;
    800051a0:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800051a2:	f99d1fe3          	bne	s10,s9,80005140 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800051a6:	0001c517          	auipc	a0,0x1c
    800051aa:	d2a50513          	addi	a0,a0,-726 # 80020ed0 <cons>
    800051ae:	11d000ef          	jal	ra,80005aca <release>

  return target - n;
    800051b2:	413b053b          	subw	a0,s6,s3
    800051b6:	a801                	j	800051c6 <consoleread+0xce>
        release(&cons.lock);
    800051b8:	0001c517          	auipc	a0,0x1c
    800051bc:	d1850513          	addi	a0,a0,-744 # 80020ed0 <cons>
    800051c0:	10b000ef          	jal	ra,80005aca <release>
        return -1;
    800051c4:	557d                	li	a0,-1
}
    800051c6:	70a6                	ld	ra,104(sp)
    800051c8:	7406                	ld	s0,96(sp)
    800051ca:	64e6                	ld	s1,88(sp)
    800051cc:	6946                	ld	s2,80(sp)
    800051ce:	69a6                	ld	s3,72(sp)
    800051d0:	6a06                	ld	s4,64(sp)
    800051d2:	7ae2                	ld	s5,56(sp)
    800051d4:	7b42                	ld	s6,48(sp)
    800051d6:	7ba2                	ld	s7,40(sp)
    800051d8:	7c02                	ld	s8,32(sp)
    800051da:	6ce2                	ld	s9,24(sp)
    800051dc:	6d42                	ld	s10,16(sp)
    800051de:	6165                	addi	sp,sp,112
    800051e0:	8082                	ret
      if(n < target){
    800051e2:	0009871b          	sext.w	a4,s3
    800051e6:	fd6770e3          	bgeu	a4,s6,800051a6 <consoleread+0xae>
        cons.r--;
    800051ea:	0001c717          	auipc	a4,0x1c
    800051ee:	d6f72f23          	sw	a5,-642(a4) # 80020f68 <cons+0x98>
    800051f2:	bf55                	j	800051a6 <consoleread+0xae>

00000000800051f4 <consputc>:
{
    800051f4:	1141                	addi	sp,sp,-16
    800051f6:	e406                	sd	ra,8(sp)
    800051f8:	e022                	sd	s0,0(sp)
    800051fa:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800051fc:	10000793          	li	a5,256
    80005200:	00f50863          	beq	a0,a5,80005210 <consputc+0x1c>
    uartputc_sync(c);
    80005204:	5d2000ef          	jal	ra,800057d6 <uartputc_sync>
}
    80005208:	60a2                	ld	ra,8(sp)
    8000520a:	6402                	ld	s0,0(sp)
    8000520c:	0141                	addi	sp,sp,16
    8000520e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005210:	4521                	li	a0,8
    80005212:	5c4000ef          	jal	ra,800057d6 <uartputc_sync>
    80005216:	02000513          	li	a0,32
    8000521a:	5bc000ef          	jal	ra,800057d6 <uartputc_sync>
    8000521e:	4521                	li	a0,8
    80005220:	5b6000ef          	jal	ra,800057d6 <uartputc_sync>
    80005224:	b7d5                	j	80005208 <consputc+0x14>

0000000080005226 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005226:	1101                	addi	sp,sp,-32
    80005228:	ec06                	sd	ra,24(sp)
    8000522a:	e822                	sd	s0,16(sp)
    8000522c:	e426                	sd	s1,8(sp)
    8000522e:	e04a                	sd	s2,0(sp)
    80005230:	1000                	addi	s0,sp,32
    80005232:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005234:	0001c517          	auipc	a0,0x1c
    80005238:	c9c50513          	addi	a0,a0,-868 # 80020ed0 <cons>
    8000523c:	7f6000ef          	jal	ra,80005a32 <acquire>

  switch(c){
    80005240:	47d5                	li	a5,21
    80005242:	0af48063          	beq	s1,a5,800052e2 <consoleintr+0xbc>
    80005246:	0297c663          	blt	a5,s1,80005272 <consoleintr+0x4c>
    8000524a:	47a1                	li	a5,8
    8000524c:	0cf48f63          	beq	s1,a5,8000532a <consoleintr+0x104>
    80005250:	47c1                	li	a5,16
    80005252:	10f49063          	bne	s1,a5,80005352 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    80005256:	903fc0ef          	jal	ra,80001b58 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    8000525a:	0001c517          	auipc	a0,0x1c
    8000525e:	c7650513          	addi	a0,a0,-906 # 80020ed0 <cons>
    80005262:	069000ef          	jal	ra,80005aca <release>
}
    80005266:	60e2                	ld	ra,24(sp)
    80005268:	6442                	ld	s0,16(sp)
    8000526a:	64a2                	ld	s1,8(sp)
    8000526c:	6902                	ld	s2,0(sp)
    8000526e:	6105                	addi	sp,sp,32
    80005270:	8082                	ret
  switch(c){
    80005272:	07f00793          	li	a5,127
    80005276:	0af48a63          	beq	s1,a5,8000532a <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000527a:	0001c717          	auipc	a4,0x1c
    8000527e:	c5670713          	addi	a4,a4,-938 # 80020ed0 <cons>
    80005282:	0a072783          	lw	a5,160(a4)
    80005286:	09872703          	lw	a4,152(a4)
    8000528a:	9f99                	subw	a5,a5,a4
    8000528c:	07f00713          	li	a4,127
    80005290:	fcf765e3          	bltu	a4,a5,8000525a <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    80005294:	47b5                	li	a5,13
    80005296:	0cf48163          	beq	s1,a5,80005358 <consoleintr+0x132>
      consputc(c);
    8000529a:	8526                	mv	a0,s1
    8000529c:	f59ff0ef          	jal	ra,800051f4 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800052a0:	0001c797          	auipc	a5,0x1c
    800052a4:	c3078793          	addi	a5,a5,-976 # 80020ed0 <cons>
    800052a8:	0a07a683          	lw	a3,160(a5)
    800052ac:	0016871b          	addiw	a4,a3,1
    800052b0:	0007061b          	sext.w	a2,a4
    800052b4:	0ae7a023          	sw	a4,160(a5)
    800052b8:	07f6f693          	andi	a3,a3,127
    800052bc:	97b6                	add	a5,a5,a3
    800052be:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    800052c2:	47a9                	li	a5,10
    800052c4:	0af48f63          	beq	s1,a5,80005382 <consoleintr+0x15c>
    800052c8:	4791                	li	a5,4
    800052ca:	0af48c63          	beq	s1,a5,80005382 <consoleintr+0x15c>
    800052ce:	0001c797          	auipc	a5,0x1c
    800052d2:	c9a7a783          	lw	a5,-870(a5) # 80020f68 <cons+0x98>
    800052d6:	9f1d                	subw	a4,a4,a5
    800052d8:	08000793          	li	a5,128
    800052dc:	f6f71fe3          	bne	a4,a5,8000525a <consoleintr+0x34>
    800052e0:	a04d                	j	80005382 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    800052e2:	0001c717          	auipc	a4,0x1c
    800052e6:	bee70713          	addi	a4,a4,-1042 # 80020ed0 <cons>
    800052ea:	0a072783          	lw	a5,160(a4)
    800052ee:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800052f2:	0001c497          	auipc	s1,0x1c
    800052f6:	bde48493          	addi	s1,s1,-1058 # 80020ed0 <cons>
    while(cons.e != cons.w &&
    800052fa:	4929                	li	s2,10
    800052fc:	f4f70fe3          	beq	a4,a5,8000525a <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005300:	37fd                	addiw	a5,a5,-1
    80005302:	07f7f713          	andi	a4,a5,127
    80005306:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005308:	01874703          	lbu	a4,24(a4)
    8000530c:	f52707e3          	beq	a4,s2,8000525a <consoleintr+0x34>
      cons.e--;
    80005310:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005314:	10000513          	li	a0,256
    80005318:	eddff0ef          	jal	ra,800051f4 <consputc>
    while(cons.e != cons.w &&
    8000531c:	0a04a783          	lw	a5,160(s1)
    80005320:	09c4a703          	lw	a4,156(s1)
    80005324:	fcf71ee3          	bne	a4,a5,80005300 <consoleintr+0xda>
    80005328:	bf0d                	j	8000525a <consoleintr+0x34>
    if(cons.e != cons.w){
    8000532a:	0001c717          	auipc	a4,0x1c
    8000532e:	ba670713          	addi	a4,a4,-1114 # 80020ed0 <cons>
    80005332:	0a072783          	lw	a5,160(a4)
    80005336:	09c72703          	lw	a4,156(a4)
    8000533a:	f2f700e3          	beq	a4,a5,8000525a <consoleintr+0x34>
      cons.e--;
    8000533e:	37fd                	addiw	a5,a5,-1
    80005340:	0001c717          	auipc	a4,0x1c
    80005344:	c2f72823          	sw	a5,-976(a4) # 80020f70 <cons+0xa0>
      consputc(BACKSPACE);
    80005348:	10000513          	li	a0,256
    8000534c:	ea9ff0ef          	jal	ra,800051f4 <consputc>
    80005350:	b729                	j	8000525a <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005352:	f00484e3          	beqz	s1,8000525a <consoleintr+0x34>
    80005356:	b715                	j	8000527a <consoleintr+0x54>
      consputc(c);
    80005358:	4529                	li	a0,10
    8000535a:	e9bff0ef          	jal	ra,800051f4 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000535e:	0001c797          	auipc	a5,0x1c
    80005362:	b7278793          	addi	a5,a5,-1166 # 80020ed0 <cons>
    80005366:	0a07a703          	lw	a4,160(a5)
    8000536a:	0017069b          	addiw	a3,a4,1
    8000536e:	0006861b          	sext.w	a2,a3
    80005372:	0ad7a023          	sw	a3,160(a5)
    80005376:	07f77713          	andi	a4,a4,127
    8000537a:	97ba                	add	a5,a5,a4
    8000537c:	4729                	li	a4,10
    8000537e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005382:	0001c797          	auipc	a5,0x1c
    80005386:	bec7a523          	sw	a2,-1046(a5) # 80020f6c <cons+0x9c>
        wakeup(&cons.r);
    8000538a:	0001c517          	auipc	a0,0x1c
    8000538e:	bde50513          	addi	a0,a0,-1058 # 80020f68 <cons+0x98>
    80005392:	c22fc0ef          	jal	ra,800017b4 <wakeup>
    80005396:	b5d1                	j	8000525a <consoleintr+0x34>

0000000080005398 <consoleinit>:

void
consoleinit(void)
{
    80005398:	1141                	addi	sp,sp,-16
    8000539a:	e406                	sd	ra,8(sp)
    8000539c:	e022                	sd	s0,0(sp)
    8000539e:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800053a0:	00002597          	auipc	a1,0x2
    800053a4:	5e858593          	addi	a1,a1,1512 # 80007988 <syscalls+0x458>
    800053a8:	0001c517          	auipc	a0,0x1c
    800053ac:	b2850513          	addi	a0,a0,-1240 # 80020ed0 <cons>
    800053b0:	602000ef          	jal	ra,800059b2 <initlock>

  uartinit();
    800053b4:	3d6000ef          	jal	ra,8000578a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800053b8:	00013797          	auipc	a5,0x13
    800053bc:	98078793          	addi	a5,a5,-1664 # 80017d38 <devsw>
    800053c0:	00000717          	auipc	a4,0x0
    800053c4:	d3870713          	addi	a4,a4,-712 # 800050f8 <consoleread>
    800053c8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800053ca:	00000717          	auipc	a4,0x0
    800053ce:	cd270713          	addi	a4,a4,-814 # 8000509c <consolewrite>
    800053d2:	ef98                	sd	a4,24(a5)
}
    800053d4:	60a2                	ld	ra,8(sp)
    800053d6:	6402                	ld	s0,0(sp)
    800053d8:	0141                	addi	sp,sp,16
    800053da:	8082                	ret

00000000800053dc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    800053dc:	7179                	addi	sp,sp,-48
    800053de:	f406                	sd	ra,40(sp)
    800053e0:	f022                	sd	s0,32(sp)
    800053e2:	ec26                	sd	s1,24(sp)
    800053e4:	e84a                	sd	s2,16(sp)
    800053e6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    800053e8:	c219                	beqz	a2,800053ee <printint+0x12>
    800053ea:	06054e63          	bltz	a0,80005466 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    800053ee:	4881                	li	a7,0
    800053f0:	fd040693          	addi	a3,s0,-48

  i = 0;
    800053f4:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    800053f6:	00002617          	auipc	a2,0x2
    800053fa:	5ba60613          	addi	a2,a2,1466 # 800079b0 <digits>
    800053fe:	883e                	mv	a6,a5
    80005400:	2785                	addiw	a5,a5,1
    80005402:	02b57733          	remu	a4,a0,a1
    80005406:	9732                	add	a4,a4,a2
    80005408:	00074703          	lbu	a4,0(a4)
    8000540c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80005410:	872a                	mv	a4,a0
    80005412:	02b55533          	divu	a0,a0,a1
    80005416:	0685                	addi	a3,a3,1
    80005418:	feb773e3          	bgeu	a4,a1,800053fe <printint+0x22>

  if(sign)
    8000541c:	00088a63          	beqz	a7,80005430 <printint+0x54>
    buf[i++] = '-';
    80005420:	1781                	addi	a5,a5,-32
    80005422:	97a2                	add	a5,a5,s0
    80005424:	02d00713          	li	a4,45
    80005428:	fee78823          	sb	a4,-16(a5)
    8000542c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80005430:	02f05563          	blez	a5,8000545a <printint+0x7e>
    80005434:	fd040713          	addi	a4,s0,-48
    80005438:	00f704b3          	add	s1,a4,a5
    8000543c:	fff70913          	addi	s2,a4,-1
    80005440:	993e                	add	s2,s2,a5
    80005442:	37fd                	addiw	a5,a5,-1
    80005444:	1782                	slli	a5,a5,0x20
    80005446:	9381                	srli	a5,a5,0x20
    80005448:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    8000544c:	fff4c503          	lbu	a0,-1(s1)
    80005450:	da5ff0ef          	jal	ra,800051f4 <consputc>
  while(--i >= 0)
    80005454:	14fd                	addi	s1,s1,-1
    80005456:	ff249be3          	bne	s1,s2,8000544c <printint+0x70>
}
    8000545a:	70a2                	ld	ra,40(sp)
    8000545c:	7402                	ld	s0,32(sp)
    8000545e:	64e2                	ld	s1,24(sp)
    80005460:	6942                	ld	s2,16(sp)
    80005462:	6145                	addi	sp,sp,48
    80005464:	8082                	ret
    x = -xx;
    80005466:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    8000546a:	4885                	li	a7,1
    x = -xx;
    8000546c:	b751                	j	800053f0 <printint+0x14>

000000008000546e <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    8000546e:	7155                	addi	sp,sp,-208
    80005470:	e506                	sd	ra,136(sp)
    80005472:	e122                	sd	s0,128(sp)
    80005474:	fca6                	sd	s1,120(sp)
    80005476:	f8ca                	sd	s2,112(sp)
    80005478:	f4ce                	sd	s3,104(sp)
    8000547a:	f0d2                	sd	s4,96(sp)
    8000547c:	ecd6                	sd	s5,88(sp)
    8000547e:	e8da                	sd	s6,80(sp)
    80005480:	e4de                	sd	s7,72(sp)
    80005482:	e0e2                	sd	s8,64(sp)
    80005484:	fc66                	sd	s9,56(sp)
    80005486:	f86a                	sd	s10,48(sp)
    80005488:	f46e                	sd	s11,40(sp)
    8000548a:	0900                	addi	s0,sp,144
    8000548c:	8a2a                	mv	s4,a0
    8000548e:	e40c                	sd	a1,8(s0)
    80005490:	e810                	sd	a2,16(s0)
    80005492:	ec14                	sd	a3,24(s0)
    80005494:	f018                	sd	a4,32(s0)
    80005496:	f41c                	sd	a5,40(s0)
    80005498:	03043823          	sd	a6,48(s0)
    8000549c:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800054a0:	0001c797          	auipc	a5,0x1c
    800054a4:	af07a783          	lw	a5,-1296(a5) # 80020f90 <pr+0x18>
    800054a8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800054ac:	eb9d                	bnez	a5,800054e2 <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800054ae:	00840793          	addi	a5,s0,8
    800054b2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800054b6:	00054503          	lbu	a0,0(a0)
    800054ba:	24050463          	beqz	a0,80005702 <printf+0x294>
    800054be:	4981                	li	s3,0
    if(cx != '%'){
    800054c0:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    800054c4:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    800054c8:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    800054cc:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    800054d0:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    800054d4:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800054d8:	00002b97          	auipc	s7,0x2
    800054dc:	4d8b8b93          	addi	s7,s7,1240 # 800079b0 <digits>
    800054e0:	a081                	j	80005520 <printf+0xb2>
    acquire(&pr.lock);
    800054e2:	0001c517          	auipc	a0,0x1c
    800054e6:	a9650513          	addi	a0,a0,-1386 # 80020f78 <pr>
    800054ea:	548000ef          	jal	ra,80005a32 <acquire>
  va_start(ap, fmt);
    800054ee:	00840793          	addi	a5,s0,8
    800054f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800054f6:	000a4503          	lbu	a0,0(s4)
    800054fa:	f171                	bnez	a0,800054be <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    800054fc:	0001c517          	auipc	a0,0x1c
    80005500:	a7c50513          	addi	a0,a0,-1412 # 80020f78 <pr>
    80005504:	5c6000ef          	jal	ra,80005aca <release>
    80005508:	aaed                	j	80005702 <printf+0x294>
      consputc(cx);
    8000550a:	cebff0ef          	jal	ra,800051f4 <consputc>
      continue;
    8000550e:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005510:	0014899b          	addiw	s3,s1,1
    80005514:	013a07b3          	add	a5,s4,s3
    80005518:	0007c503          	lbu	a0,0(a5)
    8000551c:	1c050f63          	beqz	a0,800056fa <printf+0x28c>
    if(cx != '%'){
    80005520:	ff5515e3          	bne	a0,s5,8000550a <printf+0x9c>
    i++;
    80005524:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80005528:	009a07b3          	add	a5,s4,s1
    8000552c:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80005530:	1c090563          	beqz	s2,800056fa <printf+0x28c>
    80005534:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80005538:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000553a:	c789                	beqz	a5,80005544 <printf+0xd6>
    8000553c:	009a0733          	add	a4,s4,s1
    80005540:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005544:	03690463          	beq	s2,s6,8000556c <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    80005548:	03890e63          	beq	s2,s8,80005584 <printf+0x116>
    } else if(c0 == 'u'){
    8000554c:	0b990d63          	beq	s2,s9,80005606 <printf+0x198>
    } else if(c0 == 'x'){
    80005550:	11a90363          	beq	s2,s10,80005656 <printf+0x1e8>
    } else if(c0 == 'p'){
    80005554:	13b90b63          	beq	s2,s11,8000568a <printf+0x21c>
    } else if(c0 == 's'){
    80005558:	07300793          	li	a5,115
    8000555c:	16f90363          	beq	s2,a5,800056c2 <printf+0x254>
    } else if(c0 == '%'){
    80005560:	03591c63          	bne	s2,s5,80005598 <printf+0x12a>
      consputc('%');
    80005564:	8556                	mv	a0,s5
    80005566:	c8fff0ef          	jal	ra,800051f4 <consputc>
    8000556a:	b75d                	j	80005510 <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    8000556c:	f8843783          	ld	a5,-120(s0)
    80005570:	00878713          	addi	a4,a5,8
    80005574:	f8e43423          	sd	a4,-120(s0)
    80005578:	4605                	li	a2,1
    8000557a:	45a9                	li	a1,10
    8000557c:	4388                	lw	a0,0(a5)
    8000557e:	e5fff0ef          	jal	ra,800053dc <printint>
    80005582:	b779                	j	80005510 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    80005584:	03678163          	beq	a5,s6,800055a6 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80005588:	03878d63          	beq	a5,s8,800055c2 <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    8000558c:	09978963          	beq	a5,s9,8000561e <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005590:	03878b63          	beq	a5,s8,800055c6 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    80005594:	0da78d63          	beq	a5,s10,8000566e <printf+0x200>
      consputc('%');
    80005598:	8556                	mv	a0,s5
    8000559a:	c5bff0ef          	jal	ra,800051f4 <consputc>
      consputc(c0);
    8000559e:	854a                	mv	a0,s2
    800055a0:	c55ff0ef          	jal	ra,800051f4 <consputc>
    800055a4:	b7b5                	j	80005510 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800055a6:	f8843783          	ld	a5,-120(s0)
    800055aa:	00878713          	addi	a4,a5,8
    800055ae:	f8e43423          	sd	a4,-120(s0)
    800055b2:	4605                	li	a2,1
    800055b4:	45a9                	li	a1,10
    800055b6:	6388                	ld	a0,0(a5)
    800055b8:	e25ff0ef          	jal	ra,800053dc <printint>
      i += 1;
    800055bc:	0029849b          	addiw	s1,s3,2
    800055c0:	bf81                	j	80005510 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800055c2:	03668463          	beq	a3,s6,800055ea <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800055c6:	07968a63          	beq	a3,s9,8000563a <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800055ca:	fda697e3          	bne	a3,s10,80005598 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    800055ce:	f8843783          	ld	a5,-120(s0)
    800055d2:	00878713          	addi	a4,a5,8
    800055d6:	f8e43423          	sd	a4,-120(s0)
    800055da:	4601                	li	a2,0
    800055dc:	45c1                	li	a1,16
    800055de:	6388                	ld	a0,0(a5)
    800055e0:	dfdff0ef          	jal	ra,800053dc <printint>
      i += 2;
    800055e4:	0039849b          	addiw	s1,s3,3
    800055e8:	b725                	j	80005510 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800055ea:	f8843783          	ld	a5,-120(s0)
    800055ee:	00878713          	addi	a4,a5,8
    800055f2:	f8e43423          	sd	a4,-120(s0)
    800055f6:	4605                	li	a2,1
    800055f8:	45a9                	li	a1,10
    800055fa:	6388                	ld	a0,0(a5)
    800055fc:	de1ff0ef          	jal	ra,800053dc <printint>
      i += 2;
    80005600:	0039849b          	addiw	s1,s3,3
    80005604:	b731                	j	80005510 <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    80005606:	f8843783          	ld	a5,-120(s0)
    8000560a:	00878713          	addi	a4,a5,8
    8000560e:	f8e43423          	sd	a4,-120(s0)
    80005612:	4601                	li	a2,0
    80005614:	45a9                	li	a1,10
    80005616:	4388                	lw	a0,0(a5)
    80005618:	dc5ff0ef          	jal	ra,800053dc <printint>
    8000561c:	bdd5                	j	80005510 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000561e:	f8843783          	ld	a5,-120(s0)
    80005622:	00878713          	addi	a4,a5,8
    80005626:	f8e43423          	sd	a4,-120(s0)
    8000562a:	4601                	li	a2,0
    8000562c:	45a9                	li	a1,10
    8000562e:	6388                	ld	a0,0(a5)
    80005630:	dadff0ef          	jal	ra,800053dc <printint>
      i += 1;
    80005634:	0029849b          	addiw	s1,s3,2
    80005638:	bde1                	j	80005510 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000563a:	f8843783          	ld	a5,-120(s0)
    8000563e:	00878713          	addi	a4,a5,8
    80005642:	f8e43423          	sd	a4,-120(s0)
    80005646:	4601                	li	a2,0
    80005648:	45a9                	li	a1,10
    8000564a:	6388                	ld	a0,0(a5)
    8000564c:	d91ff0ef          	jal	ra,800053dc <printint>
      i += 2;
    80005650:	0039849b          	addiw	s1,s3,3
    80005654:	bd75                	j	80005510 <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    80005656:	f8843783          	ld	a5,-120(s0)
    8000565a:	00878713          	addi	a4,a5,8
    8000565e:	f8e43423          	sd	a4,-120(s0)
    80005662:	4601                	li	a2,0
    80005664:	45c1                	li	a1,16
    80005666:	4388                	lw	a0,0(a5)
    80005668:	d75ff0ef          	jal	ra,800053dc <printint>
    8000566c:	b555                	j	80005510 <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    8000566e:	f8843783          	ld	a5,-120(s0)
    80005672:	00878713          	addi	a4,a5,8
    80005676:	f8e43423          	sd	a4,-120(s0)
    8000567a:	4601                	li	a2,0
    8000567c:	45c1                	li	a1,16
    8000567e:	6388                	ld	a0,0(a5)
    80005680:	d5dff0ef          	jal	ra,800053dc <printint>
      i += 1;
    80005684:	0029849b          	addiw	s1,s3,2
    80005688:	b561                	j	80005510 <printf+0xa2>
      printptr(va_arg(ap, uint64));
    8000568a:	f8843783          	ld	a5,-120(s0)
    8000568e:	00878713          	addi	a4,a5,8
    80005692:	f8e43423          	sd	a4,-120(s0)
    80005696:	0007b983          	ld	s3,0(a5)
  consputc('0');
    8000569a:	03000513          	li	a0,48
    8000569e:	b57ff0ef          	jal	ra,800051f4 <consputc>
  consputc('x');
    800056a2:	856a                	mv	a0,s10
    800056a4:	b51ff0ef          	jal	ra,800051f4 <consputc>
    800056a8:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800056aa:	03c9d793          	srli	a5,s3,0x3c
    800056ae:	97de                	add	a5,a5,s7
    800056b0:	0007c503          	lbu	a0,0(a5)
    800056b4:	b41ff0ef          	jal	ra,800051f4 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800056b8:	0992                	slli	s3,s3,0x4
    800056ba:	397d                	addiw	s2,s2,-1
    800056bc:	fe0917e3          	bnez	s2,800056aa <printf+0x23c>
    800056c0:	bd81                	j	80005510 <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    800056c2:	f8843783          	ld	a5,-120(s0)
    800056c6:	00878713          	addi	a4,a5,8
    800056ca:	f8e43423          	sd	a4,-120(s0)
    800056ce:	0007b903          	ld	s2,0(a5)
    800056d2:	00090d63          	beqz	s2,800056ec <printf+0x27e>
      for(; *s; s++)
    800056d6:	00094503          	lbu	a0,0(s2)
    800056da:	e2050be3          	beqz	a0,80005510 <printf+0xa2>
        consputc(*s);
    800056de:	b17ff0ef          	jal	ra,800051f4 <consputc>
      for(; *s; s++)
    800056e2:	0905                	addi	s2,s2,1
    800056e4:	00094503          	lbu	a0,0(s2)
    800056e8:	f97d                	bnez	a0,800056de <printf+0x270>
    800056ea:	b51d                	j	80005510 <printf+0xa2>
        s = "(null)";
    800056ec:	00002917          	auipc	s2,0x2
    800056f0:	2a490913          	addi	s2,s2,676 # 80007990 <syscalls+0x460>
      for(; *s; s++)
    800056f4:	02800513          	li	a0,40
    800056f8:	b7dd                	j	800056de <printf+0x270>
  if(locking)
    800056fa:	f7843783          	ld	a5,-136(s0)
    800056fe:	de079fe3          	bnez	a5,800054fc <printf+0x8e>

  return 0;
}
    80005702:	4501                	li	a0,0
    80005704:	60aa                	ld	ra,136(sp)
    80005706:	640a                	ld	s0,128(sp)
    80005708:	74e6                	ld	s1,120(sp)
    8000570a:	7946                	ld	s2,112(sp)
    8000570c:	79a6                	ld	s3,104(sp)
    8000570e:	7a06                	ld	s4,96(sp)
    80005710:	6ae6                	ld	s5,88(sp)
    80005712:	6b46                	ld	s6,80(sp)
    80005714:	6ba6                	ld	s7,72(sp)
    80005716:	6c06                	ld	s8,64(sp)
    80005718:	7ce2                	ld	s9,56(sp)
    8000571a:	7d42                	ld	s10,48(sp)
    8000571c:	7da2                	ld	s11,40(sp)
    8000571e:	6169                	addi	sp,sp,208
    80005720:	8082                	ret

0000000080005722 <panic>:

void
panic(char *s)
{
    80005722:	1101                	addi	sp,sp,-32
    80005724:	ec06                	sd	ra,24(sp)
    80005726:	e822                	sd	s0,16(sp)
    80005728:	e426                	sd	s1,8(sp)
    8000572a:	1000                	addi	s0,sp,32
    8000572c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000572e:	0001c797          	auipc	a5,0x1c
    80005732:	8607a123          	sw	zero,-1950(a5) # 80020f90 <pr+0x18>
  printf("panic: ");
    80005736:	00002517          	auipc	a0,0x2
    8000573a:	26250513          	addi	a0,a0,610 # 80007998 <syscalls+0x468>
    8000573e:	d31ff0ef          	jal	ra,8000546e <printf>
  printf("%s\n", s);
    80005742:	85a6                	mv	a1,s1
    80005744:	00002517          	auipc	a0,0x2
    80005748:	25c50513          	addi	a0,a0,604 # 800079a0 <syscalls+0x470>
    8000574c:	d23ff0ef          	jal	ra,8000546e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005750:	4785                	li	a5,1
    80005752:	00002717          	auipc	a4,0x2
    80005756:	32f72d23          	sw	a5,826(a4) # 80007a8c <panicked>
  for(;;)
    8000575a:	a001                	j	8000575a <panic+0x38>

000000008000575c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000575c:	1101                	addi	sp,sp,-32
    8000575e:	ec06                	sd	ra,24(sp)
    80005760:	e822                	sd	s0,16(sp)
    80005762:	e426                	sd	s1,8(sp)
    80005764:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005766:	0001c497          	auipc	s1,0x1c
    8000576a:	81248493          	addi	s1,s1,-2030 # 80020f78 <pr>
    8000576e:	00002597          	auipc	a1,0x2
    80005772:	23a58593          	addi	a1,a1,570 # 800079a8 <syscalls+0x478>
    80005776:	8526                	mv	a0,s1
    80005778:	23a000ef          	jal	ra,800059b2 <initlock>
  pr.locking = 1;
    8000577c:	4785                	li	a5,1
    8000577e:	cc9c                	sw	a5,24(s1)
}
    80005780:	60e2                	ld	ra,24(sp)
    80005782:	6442                	ld	s0,16(sp)
    80005784:	64a2                	ld	s1,8(sp)
    80005786:	6105                	addi	sp,sp,32
    80005788:	8082                	ret

000000008000578a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000578a:	1141                	addi	sp,sp,-16
    8000578c:	e406                	sd	ra,8(sp)
    8000578e:	e022                	sd	s0,0(sp)
    80005790:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005792:	100007b7          	lui	a5,0x10000
    80005796:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000579a:	f8000713          	li	a4,-128
    8000579e:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800057a2:	470d                	li	a4,3
    800057a4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800057a8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800057ac:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800057b0:	469d                	li	a3,7
    800057b2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800057b6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800057ba:	00002597          	auipc	a1,0x2
    800057be:	20e58593          	addi	a1,a1,526 # 800079c8 <digits+0x18>
    800057c2:	0001b517          	auipc	a0,0x1b
    800057c6:	7d650513          	addi	a0,a0,2006 # 80020f98 <uart_tx_lock>
    800057ca:	1e8000ef          	jal	ra,800059b2 <initlock>
}
    800057ce:	60a2                	ld	ra,8(sp)
    800057d0:	6402                	ld	s0,0(sp)
    800057d2:	0141                	addi	sp,sp,16
    800057d4:	8082                	ret

00000000800057d6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800057d6:	1101                	addi	sp,sp,-32
    800057d8:	ec06                	sd	ra,24(sp)
    800057da:	e822                	sd	s0,16(sp)
    800057dc:	e426                	sd	s1,8(sp)
    800057de:	1000                	addi	s0,sp,32
    800057e0:	84aa                	mv	s1,a0
  push_off();
    800057e2:	210000ef          	jal	ra,800059f2 <push_off>

  if(panicked){
    800057e6:	00002797          	auipc	a5,0x2
    800057ea:	2a67a783          	lw	a5,678(a5) # 80007a8c <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800057ee:	10000737          	lui	a4,0x10000
  if(panicked){
    800057f2:	c391                	beqz	a5,800057f6 <uartputc_sync+0x20>
    for(;;)
    800057f4:	a001                	j	800057f4 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800057f6:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800057fa:	0207f793          	andi	a5,a5,32
    800057fe:	dfe5                	beqz	a5,800057f6 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80005800:	0ff4f513          	zext.b	a0,s1
    80005804:	100007b7          	lui	a5,0x10000
    80005808:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000580c:	26a000ef          	jal	ra,80005a76 <pop_off>
}
    80005810:	60e2                	ld	ra,24(sp)
    80005812:	6442                	ld	s0,16(sp)
    80005814:	64a2                	ld	s1,8(sp)
    80005816:	6105                	addi	sp,sp,32
    80005818:	8082                	ret

000000008000581a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000581a:	00002797          	auipc	a5,0x2
    8000581e:	2767b783          	ld	a5,630(a5) # 80007a90 <uart_tx_r>
    80005822:	00002717          	auipc	a4,0x2
    80005826:	27673703          	ld	a4,630(a4) # 80007a98 <uart_tx_w>
    8000582a:	06f70c63          	beq	a4,a5,800058a2 <uartstart+0x88>
{
    8000582e:	7139                	addi	sp,sp,-64
    80005830:	fc06                	sd	ra,56(sp)
    80005832:	f822                	sd	s0,48(sp)
    80005834:	f426                	sd	s1,40(sp)
    80005836:	f04a                	sd	s2,32(sp)
    80005838:	ec4e                	sd	s3,24(sp)
    8000583a:	e852                	sd	s4,16(sp)
    8000583c:	e456                	sd	s5,8(sp)
    8000583e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }

    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005840:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }

    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005844:	0001ba17          	auipc	s4,0x1b
    80005848:	754a0a13          	addi	s4,s4,1876 # 80020f98 <uart_tx_lock>
    uart_tx_r += 1;
    8000584c:	00002497          	auipc	s1,0x2
    80005850:	24448493          	addi	s1,s1,580 # 80007a90 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80005854:	00002997          	auipc	s3,0x2
    80005858:	24498993          	addi	s3,s3,580 # 80007a98 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000585c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80005860:	02077713          	andi	a4,a4,32
    80005864:	c715                	beqz	a4,80005890 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005866:	01f7f713          	andi	a4,a5,31
    8000586a:	9752                	add	a4,a4,s4
    8000586c:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80005870:	0785                	addi	a5,a5,1
    80005872:	e09c                	sd	a5,0(s1)

    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80005874:	8526                	mv	a0,s1
    80005876:	f3ffb0ef          	jal	ra,800017b4 <wakeup>

    WriteReg(THR, c);
    8000587a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000587e:	609c                	ld	a5,0(s1)
    80005880:	0009b703          	ld	a4,0(s3)
    80005884:	fcf71ce3          	bne	a4,a5,8000585c <uartstart+0x42>
      ReadReg(ISR);
    80005888:	100007b7          	lui	a5,0x10000
    8000588c:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    80005890:	70e2                	ld	ra,56(sp)
    80005892:	7442                	ld	s0,48(sp)
    80005894:	74a2                	ld	s1,40(sp)
    80005896:	7902                	ld	s2,32(sp)
    80005898:	69e2                	ld	s3,24(sp)
    8000589a:	6a42                	ld	s4,16(sp)
    8000589c:	6aa2                	ld	s5,8(sp)
    8000589e:	6121                	addi	sp,sp,64
    800058a0:	8082                	ret
      ReadReg(ISR);
    800058a2:	100007b7          	lui	a5,0x10000
    800058a6:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    800058aa:	8082                	ret

00000000800058ac <uartputc>:
{
    800058ac:	7179                	addi	sp,sp,-48
    800058ae:	f406                	sd	ra,40(sp)
    800058b0:	f022                	sd	s0,32(sp)
    800058b2:	ec26                	sd	s1,24(sp)
    800058b4:	e84a                	sd	s2,16(sp)
    800058b6:	e44e                	sd	s3,8(sp)
    800058b8:	e052                	sd	s4,0(sp)
    800058ba:	1800                	addi	s0,sp,48
    800058bc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800058be:	0001b517          	auipc	a0,0x1b
    800058c2:	6da50513          	addi	a0,a0,1754 # 80020f98 <uart_tx_lock>
    800058c6:	16c000ef          	jal	ra,80005a32 <acquire>
  if(panicked){
    800058ca:	00002797          	auipc	a5,0x2
    800058ce:	1c27a783          	lw	a5,450(a5) # 80007a8c <panicked>
    800058d2:	efbd                	bnez	a5,80005950 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800058d4:	00002717          	auipc	a4,0x2
    800058d8:	1c473703          	ld	a4,452(a4) # 80007a98 <uart_tx_w>
    800058dc:	00002797          	auipc	a5,0x2
    800058e0:	1b47b783          	ld	a5,436(a5) # 80007a90 <uart_tx_r>
    800058e4:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800058e8:	0001b997          	auipc	s3,0x1b
    800058ec:	6b098993          	addi	s3,s3,1712 # 80020f98 <uart_tx_lock>
    800058f0:	00002497          	auipc	s1,0x2
    800058f4:	1a048493          	addi	s1,s1,416 # 80007a90 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800058f8:	00002917          	auipc	s2,0x2
    800058fc:	1a090913          	addi	s2,s2,416 # 80007a98 <uart_tx_w>
    80005900:	00e79d63          	bne	a5,a4,8000591a <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80005904:	85ce                	mv	a1,s3
    80005906:	8526                	mv	a0,s1
    80005908:	e61fb0ef          	jal	ra,80001768 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000590c:	00093703          	ld	a4,0(s2)
    80005910:	609c                	ld	a5,0(s1)
    80005912:	02078793          	addi	a5,a5,32
    80005916:	fee787e3          	beq	a5,a4,80005904 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000591a:	0001b497          	auipc	s1,0x1b
    8000591e:	67e48493          	addi	s1,s1,1662 # 80020f98 <uart_tx_lock>
    80005922:	01f77793          	andi	a5,a4,31
    80005926:	97a6                	add	a5,a5,s1
    80005928:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    8000592c:	0705                	addi	a4,a4,1
    8000592e:	00002797          	auipc	a5,0x2
    80005932:	16e7b523          	sd	a4,362(a5) # 80007a98 <uart_tx_w>
  uartstart();
    80005936:	ee5ff0ef          	jal	ra,8000581a <uartstart>
  release(&uart_tx_lock);
    8000593a:	8526                	mv	a0,s1
    8000593c:	18e000ef          	jal	ra,80005aca <release>
}
    80005940:	70a2                	ld	ra,40(sp)
    80005942:	7402                	ld	s0,32(sp)
    80005944:	64e2                	ld	s1,24(sp)
    80005946:	6942                	ld	s2,16(sp)
    80005948:	69a2                	ld	s3,8(sp)
    8000594a:	6a02                	ld	s4,0(sp)
    8000594c:	6145                	addi	sp,sp,48
    8000594e:	8082                	ret
    for(;;)
    80005950:	a001                	j	80005950 <uartputc+0xa4>

0000000080005952 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80005952:	1141                	addi	sp,sp,-16
    80005954:	e422                	sd	s0,8(sp)
    80005956:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80005958:	100007b7          	lui	a5,0x10000
    8000595c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80005960:	8b85                	andi	a5,a5,1
    80005962:	cb81                	beqz	a5,80005972 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80005964:	100007b7          	lui	a5,0x10000
    80005968:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000596c:	6422                	ld	s0,8(sp)
    8000596e:	0141                	addi	sp,sp,16
    80005970:	8082                	ret
    return -1;
    80005972:	557d                	li	a0,-1
    80005974:	bfe5                	j	8000596c <uartgetc+0x1a>

0000000080005976 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80005976:	1101                	addi	sp,sp,-32
    80005978:	ec06                	sd	ra,24(sp)
    8000597a:	e822                	sd	s0,16(sp)
    8000597c:	e426                	sd	s1,8(sp)
    8000597e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80005980:	54fd                	li	s1,-1
    80005982:	a019                	j	80005988 <uartintr+0x12>
      break;
    consoleintr(c);
    80005984:	8a3ff0ef          	jal	ra,80005226 <consoleintr>
    int c = uartgetc();
    80005988:	fcbff0ef          	jal	ra,80005952 <uartgetc>
    if(c == -1)
    8000598c:	fe951ce3          	bne	a0,s1,80005984 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80005990:	0001b497          	auipc	s1,0x1b
    80005994:	60848493          	addi	s1,s1,1544 # 80020f98 <uart_tx_lock>
    80005998:	8526                	mv	a0,s1
    8000599a:	098000ef          	jal	ra,80005a32 <acquire>
  uartstart();
    8000599e:	e7dff0ef          	jal	ra,8000581a <uartstart>
  release(&uart_tx_lock);
    800059a2:	8526                	mv	a0,s1
    800059a4:	126000ef          	jal	ra,80005aca <release>
}
    800059a8:	60e2                	ld	ra,24(sp)
    800059aa:	6442                	ld	s0,16(sp)
    800059ac:	64a2                	ld	s1,8(sp)
    800059ae:	6105                	addi	sp,sp,32
    800059b0:	8082                	ret

00000000800059b2 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    800059b2:	1141                	addi	sp,sp,-16
    800059b4:	e422                	sd	s0,8(sp)
    800059b6:	0800                	addi	s0,sp,16
  lk->name = name;
    800059b8:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800059ba:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800059be:	00053823          	sd	zero,16(a0)
}
    800059c2:	6422                	ld	s0,8(sp)
    800059c4:	0141                	addi	sp,sp,16
    800059c6:	8082                	ret

00000000800059c8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    800059c8:	411c                	lw	a5,0(a0)
    800059ca:	e399                	bnez	a5,800059d0 <holding+0x8>
    800059cc:	4501                	li	a0,0
  return r;
}
    800059ce:	8082                	ret
{
    800059d0:	1101                	addi	sp,sp,-32
    800059d2:	ec06                	sd	ra,24(sp)
    800059d4:	e822                	sd	s0,16(sp)
    800059d6:	e426                	sd	s1,8(sp)
    800059d8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    800059da:	6904                	ld	s1,16(a0)
    800059dc:	fa4fb0ef          	jal	ra,80001180 <mycpu>
    800059e0:	40a48533          	sub	a0,s1,a0
    800059e4:	00153513          	seqz	a0,a0
}
    800059e8:	60e2                	ld	ra,24(sp)
    800059ea:	6442                	ld	s0,16(sp)
    800059ec:	64a2                	ld	s1,8(sp)
    800059ee:	6105                	addi	sp,sp,32
    800059f0:	8082                	ret

00000000800059f2 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800059f2:	1101                	addi	sp,sp,-32
    800059f4:	ec06                	sd	ra,24(sp)
    800059f6:	e822                	sd	s0,16(sp)
    800059f8:	e426                	sd	s1,8(sp)
    800059fa:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800059fc:	100024f3          	csrr	s1,sstatus
    80005a00:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80005a04:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005a06:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80005a0a:	f76fb0ef          	jal	ra,80001180 <mycpu>
    80005a0e:	5d3c                	lw	a5,120(a0)
    80005a10:	cb99                	beqz	a5,80005a26 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80005a12:	f6efb0ef          	jal	ra,80001180 <mycpu>
    80005a16:	5d3c                	lw	a5,120(a0)
    80005a18:	2785                	addiw	a5,a5,1
    80005a1a:	dd3c                	sw	a5,120(a0)
}
    80005a1c:	60e2                	ld	ra,24(sp)
    80005a1e:	6442                	ld	s0,16(sp)
    80005a20:	64a2                	ld	s1,8(sp)
    80005a22:	6105                	addi	sp,sp,32
    80005a24:	8082                	ret
    mycpu()->intena = old;
    80005a26:	f5afb0ef          	jal	ra,80001180 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80005a2a:	8085                	srli	s1,s1,0x1
    80005a2c:	8885                	andi	s1,s1,1
    80005a2e:	dd64                	sw	s1,124(a0)
    80005a30:	b7cd                	j	80005a12 <push_off+0x20>

0000000080005a32 <acquire>:
{
    80005a32:	1101                	addi	sp,sp,-32
    80005a34:	ec06                	sd	ra,24(sp)
    80005a36:	e822                	sd	s0,16(sp)
    80005a38:	e426                	sd	s1,8(sp)
    80005a3a:	1000                	addi	s0,sp,32
    80005a3c:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80005a3e:	fb5ff0ef          	jal	ra,800059f2 <push_off>
  if(holding(lk))
    80005a42:	8526                	mv	a0,s1
    80005a44:	f85ff0ef          	jal	ra,800059c8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005a48:	4705                	li	a4,1
  if(holding(lk))
    80005a4a:	e105                	bnez	a0,80005a6a <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005a4c:	87ba                	mv	a5,a4
    80005a4e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80005a52:	2781                	sext.w	a5,a5
    80005a54:	ffe5                	bnez	a5,80005a4c <acquire+0x1a>
  __sync_synchronize();
    80005a56:	0ff0000f          	fence
  lk->cpu = mycpu();
    80005a5a:	f26fb0ef          	jal	ra,80001180 <mycpu>
    80005a5e:	e888                	sd	a0,16(s1)
}
    80005a60:	60e2                	ld	ra,24(sp)
    80005a62:	6442                	ld	s0,16(sp)
    80005a64:	64a2                	ld	s1,8(sp)
    80005a66:	6105                	addi	sp,sp,32
    80005a68:	8082                	ret
    panic("acquire");
    80005a6a:	00002517          	auipc	a0,0x2
    80005a6e:	f6650513          	addi	a0,a0,-154 # 800079d0 <digits+0x20>
    80005a72:	cb1ff0ef          	jal	ra,80005722 <panic>

0000000080005a76 <pop_off>:

void
pop_off(void)
{
    80005a76:	1141                	addi	sp,sp,-16
    80005a78:	e406                	sd	ra,8(sp)
    80005a7a:	e022                	sd	s0,0(sp)
    80005a7c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80005a7e:	f02fb0ef          	jal	ra,80001180 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005a82:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005a86:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005a88:	e78d                	bnez	a5,80005ab2 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80005a8a:	5d3c                	lw	a5,120(a0)
    80005a8c:	02f05963          	blez	a5,80005abe <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80005a90:	37fd                	addiw	a5,a5,-1
    80005a92:	0007871b          	sext.w	a4,a5
    80005a96:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005a98:	eb09                	bnez	a4,80005aaa <pop_off+0x34>
    80005a9a:	5d7c                	lw	a5,124(a0)
    80005a9c:	c799                	beqz	a5,80005aaa <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005a9e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005aa2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005aa6:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005aaa:	60a2                	ld	ra,8(sp)
    80005aac:	6402                	ld	s0,0(sp)
    80005aae:	0141                	addi	sp,sp,16
    80005ab0:	8082                	ret
    panic("pop_off - interruptible");
    80005ab2:	00002517          	auipc	a0,0x2
    80005ab6:	f2650513          	addi	a0,a0,-218 # 800079d8 <digits+0x28>
    80005aba:	c69ff0ef          	jal	ra,80005722 <panic>
    panic("pop_off");
    80005abe:	00002517          	auipc	a0,0x2
    80005ac2:	f3250513          	addi	a0,a0,-206 # 800079f0 <digits+0x40>
    80005ac6:	c5dff0ef          	jal	ra,80005722 <panic>

0000000080005aca <release>:
{
    80005aca:	1101                	addi	sp,sp,-32
    80005acc:	ec06                	sd	ra,24(sp)
    80005ace:	e822                	sd	s0,16(sp)
    80005ad0:	e426                	sd	s1,8(sp)
    80005ad2:	1000                	addi	s0,sp,32
    80005ad4:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005ad6:	ef3ff0ef          	jal	ra,800059c8 <holding>
    80005ada:	c105                	beqz	a0,80005afa <release+0x30>
  lk->cpu = 0;
    80005adc:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005ae0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80005ae4:	0f50000f          	fence	iorw,ow
    80005ae8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80005aec:	f8bff0ef          	jal	ra,80005a76 <pop_off>
}
    80005af0:	60e2                	ld	ra,24(sp)
    80005af2:	6442                	ld	s0,16(sp)
    80005af4:	64a2                	ld	s1,8(sp)
    80005af6:	6105                	addi	sp,sp,32
    80005af8:	8082                	ret
    panic("release");
    80005afa:	00002517          	auipc	a0,0x2
    80005afe:	efe50513          	addi	a0,a0,-258 # 800079f8 <digits+0x48>
    80005b02:	c21ff0ef          	jal	ra,80005722 <panic>
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
