
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	98013103          	ld	sp,-1664(sp) # 80007980 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	4b7040ef          	jal	ra,80004ccc <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	e7a9                	bnez	a5,80000076 <kfree+0x5a>
    8000002e:	84aa                	mv	s1,a0
    80000030:	00021797          	auipc	a5,0x21
    80000034:	cd078793          	addi	a5,a5,-816 # 80020d00 <end>
    80000038:	02f56f63          	bltu	a0,a5,80000076 <kfree+0x5a>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57b63          	bgeu	a0,a5,80000076 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	106000ef          	jal	ra,8000014e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    8000004c:	00008917          	auipc	s2,0x8
    80000050:	98490913          	addi	s2,s2,-1660 # 800079d0 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	67c050ef          	jal	ra,800056d2 <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	704050ef          	jal	ra,8000576a <release>
}
    8000006a:	60e2                	ld	ra,24(sp)
    8000006c:	6442                	ld	s0,16(sp)
    8000006e:	64a2                	ld	s1,8(sp)
    80000070:	6902                	ld	s2,0(sp)
    80000072:	6105                	addi	sp,sp,32
    80000074:	8082                	ret
    panic("kfree");
    80000076:	00007517          	auipc	a0,0x7
    8000007a:	f9a50513          	addi	a0,a0,-102 # 80007010 <etext+0x10>
    8000007e:	344050ef          	jal	ra,800053c2 <panic>

0000000080000082 <freerange>:
{
    80000082:	7179                	addi	sp,sp,-48
    80000084:	f406                	sd	ra,40(sp)
    80000086:	f022                	sd	s0,32(sp)
    80000088:	ec26                	sd	s1,24(sp)
    8000008a:	e84a                	sd	s2,16(sp)
    8000008c:	e44e                	sd	s3,8(sp)
    8000008e:	e052                	sd	s4,0(sp)
    80000090:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000092:	6785                	lui	a5,0x1
    80000094:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000098:	00e504b3          	add	s1,a0,a4
    8000009c:	777d                	lui	a4,0xfffff
    8000009e:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800000a0:	94be                	add	s1,s1,a5
    800000a2:	0095ec63          	bltu	a1,s1,800000ba <freerange+0x38>
    800000a6:	892e                	mv	s2,a1
    kfree(p);
    800000a8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800000aa:	6985                	lui	s3,0x1
    kfree(p);
    800000ac:	01448533          	add	a0,s1,s4
    800000b0:	f6dff0ef          	jal	ra,8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800000b4:	94ce                	add	s1,s1,s3
    800000b6:	fe997be3          	bgeu	s2,s1,800000ac <freerange+0x2a>
}
    800000ba:	70a2                	ld	ra,40(sp)
    800000bc:	7402                	ld	s0,32(sp)
    800000be:	64e2                	ld	s1,24(sp)
    800000c0:	6942                	ld	s2,16(sp)
    800000c2:	69a2                	ld	s3,8(sp)
    800000c4:	6a02                	ld	s4,0(sp)
    800000c6:	6145                	addi	sp,sp,48
    800000c8:	8082                	ret

00000000800000ca <kinit>:
{
    800000ca:	1141                	addi	sp,sp,-16
    800000cc:	e406                	sd	ra,8(sp)
    800000ce:	e022                	sd	s0,0(sp)
    800000d0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000d2:	00007597          	auipc	a1,0x7
    800000d6:	f4658593          	addi	a1,a1,-186 # 80007018 <etext+0x18>
    800000da:	00008517          	auipc	a0,0x8
    800000de:	8f650513          	addi	a0,a0,-1802 # 800079d0 <kmem>
    800000e2:	570050ef          	jal	ra,80005652 <initlock>
  freerange(end, (void*)PHYSTOP);
    800000e6:	45c5                	li	a1,17
    800000e8:	05ee                	slli	a1,a1,0x1b
    800000ea:	00021517          	auipc	a0,0x21
    800000ee:	c1650513          	addi	a0,a0,-1002 # 80020d00 <end>
    800000f2:	f91ff0ef          	jal	ra,80000082 <freerange>
}
    800000f6:	60a2                	ld	ra,8(sp)
    800000f8:	6402                	ld	s0,0(sp)
    800000fa:	0141                	addi	sp,sp,16
    800000fc:	8082                	ret

00000000800000fe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    800000fe:	1101                	addi	sp,sp,-32
    80000100:	ec06                	sd	ra,24(sp)
    80000102:	e822                	sd	s0,16(sp)
    80000104:	e426                	sd	s1,8(sp)
    80000106:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000108:	00008497          	auipc	s1,0x8
    8000010c:	8c848493          	addi	s1,s1,-1848 # 800079d0 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	5c0050ef          	jal	ra,800056d2 <acquire>
  r = kmem.freelist;
    80000116:	6c84                	ld	s1,24(s1)
  if (r) {
    80000118:	c485                	beqz	s1,80000140 <kalloc+0x42>
    kmem.freelist = r->next;
    8000011a:	609c                	ld	a5,0(s1)
    8000011c:	00008517          	auipc	a0,0x8
    80000120:	8b450513          	addi	a0,a0,-1868 # 800079d0 <kmem>
    80000124:	ed1c                	sd	a5,24(a0)
  }
  release(&kmem.lock);
    80000126:	644050ef          	jal	ra,8000576a <release>

  if (r) {
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000012a:	6605                	lui	a2,0x1
    8000012c:	4595                	li	a1,5
    8000012e:	8526                	mv	a0,s1
    80000130:	01e000ef          	jal	ra,8000014e <memset>
  }
  return (void*)r;
}
    80000134:	8526                	mv	a0,s1
    80000136:	60e2                	ld	ra,24(sp)
    80000138:	6442                	ld	s0,16(sp)
    8000013a:	64a2                	ld	s1,8(sp)
    8000013c:	6105                	addi	sp,sp,32
    8000013e:	8082                	ret
  release(&kmem.lock);
    80000140:	00008517          	auipc	a0,0x8
    80000144:	89050513          	addi	a0,a0,-1904 # 800079d0 <kmem>
    80000148:	622050ef          	jal	ra,8000576a <release>
  if (r) {
    8000014c:	b7e5                	j	80000134 <kalloc+0x36>

000000008000014e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    8000014e:	1141                	addi	sp,sp,-16
    80000150:	e422                	sd	s0,8(sp)
    80000152:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000154:	ca19                	beqz	a2,8000016a <memset+0x1c>
    80000156:	87aa                	mv	a5,a0
    80000158:	1602                	slli	a2,a2,0x20
    8000015a:	9201                	srli	a2,a2,0x20
    8000015c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000160:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000164:	0785                	addi	a5,a5,1
    80000166:	fee79de3          	bne	a5,a4,80000160 <memset+0x12>
  }
  return dst;
}
    8000016a:	6422                	ld	s0,8(sp)
    8000016c:	0141                	addi	sp,sp,16
    8000016e:	8082                	ret

0000000080000170 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000170:	1141                	addi	sp,sp,-16
    80000172:	e422                	sd	s0,8(sp)
    80000174:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000176:	ca05                	beqz	a2,800001a6 <memcmp+0x36>
    80000178:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    8000017c:	1682                	slli	a3,a3,0x20
    8000017e:	9281                	srli	a3,a3,0x20
    80000180:	0685                	addi	a3,a3,1
    80000182:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000184:	00054783          	lbu	a5,0(a0)
    80000188:	0005c703          	lbu	a4,0(a1)
    8000018c:	00e79863          	bne	a5,a4,8000019c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000190:	0505                	addi	a0,a0,1
    80000192:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000194:	fed518e3          	bne	a0,a3,80000184 <memcmp+0x14>
  }

  return 0;
    80000198:	4501                	li	a0,0
    8000019a:	a019                	j	800001a0 <memcmp+0x30>
      return *s1 - *s2;
    8000019c:	40e7853b          	subw	a0,a5,a4
}
    800001a0:	6422                	ld	s0,8(sp)
    800001a2:	0141                	addi	sp,sp,16
    800001a4:	8082                	ret
  return 0;
    800001a6:	4501                	li	a0,0
    800001a8:	bfe5                	j	800001a0 <memcmp+0x30>

00000000800001aa <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800001aa:	1141                	addi	sp,sp,-16
    800001ac:	e422                	sd	s0,8(sp)
    800001ae:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800001b0:	c205                	beqz	a2,800001d0 <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    800001b2:	02a5e263          	bltu	a1,a0,800001d6 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800001b6:	1602                	slli	a2,a2,0x20
    800001b8:	9201                	srli	a2,a2,0x20
    800001ba:	00c587b3          	add	a5,a1,a2
{
    800001be:	872a                	mv	a4,a0
      *d++ = *s++;
    800001c0:	0585                	addi	a1,a1,1
    800001c2:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde301>
    800001c4:	fff5c683          	lbu	a3,-1(a1)
    800001c8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800001cc:	fef59ae3          	bne	a1,a5,800001c0 <memmove+0x16>

  return dst;
}
    800001d0:	6422                	ld	s0,8(sp)
    800001d2:	0141                	addi	sp,sp,16
    800001d4:	8082                	ret
  if(s < d && s + n > d){
    800001d6:	02061693          	slli	a3,a2,0x20
    800001da:	9281                	srli	a3,a3,0x20
    800001dc:	00d58733          	add	a4,a1,a3
    800001e0:	fce57be3          	bgeu	a0,a4,800001b6 <memmove+0xc>
    d += n;
    800001e4:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    800001e6:	fff6079b          	addiw	a5,a2,-1
    800001ea:	1782                	slli	a5,a5,0x20
    800001ec:	9381                	srli	a5,a5,0x20
    800001ee:	fff7c793          	not	a5,a5
    800001f2:	97ba                	add	a5,a5,a4
      *--d = *--s;
    800001f4:	177d                	addi	a4,a4,-1
    800001f6:	16fd                	addi	a3,a3,-1
    800001f8:	00074603          	lbu	a2,0(a4)
    800001fc:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000200:	fee79ae3          	bne	a5,a4,800001f4 <memmove+0x4a>
    80000204:	b7f1                	j	800001d0 <memmove+0x26>

0000000080000206 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000206:	1141                	addi	sp,sp,-16
    80000208:	e406                	sd	ra,8(sp)
    8000020a:	e022                	sd	s0,0(sp)
    8000020c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000020e:	f9dff0ef          	jal	ra,800001aa <memmove>
}
    80000212:	60a2                	ld	ra,8(sp)
    80000214:	6402                	ld	s0,0(sp)
    80000216:	0141                	addi	sp,sp,16
    80000218:	8082                	ret

000000008000021a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000021a:	1141                	addi	sp,sp,-16
    8000021c:	e422                	sd	s0,8(sp)
    8000021e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000220:	ce11                	beqz	a2,8000023c <strncmp+0x22>
    80000222:	00054783          	lbu	a5,0(a0)
    80000226:	cf89                	beqz	a5,80000240 <strncmp+0x26>
    80000228:	0005c703          	lbu	a4,0(a1)
    8000022c:	00f71a63          	bne	a4,a5,80000240 <strncmp+0x26>
    n--, p++, q++;
    80000230:	367d                	addiw	a2,a2,-1
    80000232:	0505                	addi	a0,a0,1
    80000234:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000236:	f675                	bnez	a2,80000222 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000238:	4501                	li	a0,0
    8000023a:	a809                	j	8000024c <strncmp+0x32>
    8000023c:	4501                	li	a0,0
    8000023e:	a039                	j	8000024c <strncmp+0x32>
  if(n == 0)
    80000240:	ca09                	beqz	a2,80000252 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000242:	00054503          	lbu	a0,0(a0)
    80000246:	0005c783          	lbu	a5,0(a1)
    8000024a:	9d1d                	subw	a0,a0,a5
}
    8000024c:	6422                	ld	s0,8(sp)
    8000024e:	0141                	addi	sp,sp,16
    80000250:	8082                	ret
    return 0;
    80000252:	4501                	li	a0,0
    80000254:	bfe5                	j	8000024c <strncmp+0x32>

0000000080000256 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000256:	1141                	addi	sp,sp,-16
    80000258:	e422                	sd	s0,8(sp)
    8000025a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    8000025c:	872a                	mv	a4,a0
    8000025e:	8832                	mv	a6,a2
    80000260:	367d                	addiw	a2,a2,-1
    80000262:	01005963          	blez	a6,80000274 <strncpy+0x1e>
    80000266:	0705                	addi	a4,a4,1
    80000268:	0005c783          	lbu	a5,0(a1)
    8000026c:	fef70fa3          	sb	a5,-1(a4)
    80000270:	0585                	addi	a1,a1,1
    80000272:	f7f5                	bnez	a5,8000025e <strncpy+0x8>
    ;
  while(n-- > 0)
    80000274:	86ba                	mv	a3,a4
    80000276:	00c05c63          	blez	a2,8000028e <strncpy+0x38>
    *s++ = 0;
    8000027a:	0685                	addi	a3,a3,1
    8000027c:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000280:	40d707bb          	subw	a5,a4,a3
    80000284:	37fd                	addiw	a5,a5,-1
    80000286:	010787bb          	addw	a5,a5,a6
    8000028a:	fef048e3          	bgtz	a5,8000027a <strncpy+0x24>
  return os;
}
    8000028e:	6422                	ld	s0,8(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret

0000000080000294 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000294:	1141                	addi	sp,sp,-16
    80000296:	e422                	sd	s0,8(sp)
    80000298:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    8000029a:	02c05363          	blez	a2,800002c0 <safestrcpy+0x2c>
    8000029e:	fff6069b          	addiw	a3,a2,-1
    800002a2:	1682                	slli	a3,a3,0x20
    800002a4:	9281                	srli	a3,a3,0x20
    800002a6:	96ae                	add	a3,a3,a1
    800002a8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800002aa:	00d58963          	beq	a1,a3,800002bc <safestrcpy+0x28>
    800002ae:	0585                	addi	a1,a1,1
    800002b0:	0785                	addi	a5,a5,1
    800002b2:	fff5c703          	lbu	a4,-1(a1)
    800002b6:	fee78fa3          	sb	a4,-1(a5)
    800002ba:	fb65                	bnez	a4,800002aa <safestrcpy+0x16>
    ;
  *s = 0;
    800002bc:	00078023          	sb	zero,0(a5)
  return os;
}
    800002c0:	6422                	ld	s0,8(sp)
    800002c2:	0141                	addi	sp,sp,16
    800002c4:	8082                	ret

00000000800002c6 <strlen>:

int
strlen(const char *s)
{
    800002c6:	1141                	addi	sp,sp,-16
    800002c8:	e422                	sd	s0,8(sp)
    800002ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800002cc:	00054783          	lbu	a5,0(a0)
    800002d0:	cf91                	beqz	a5,800002ec <strlen+0x26>
    800002d2:	0505                	addi	a0,a0,1
    800002d4:	87aa                	mv	a5,a0
    800002d6:	4685                	li	a3,1
    800002d8:	9e89                	subw	a3,a3,a0
    800002da:	00f6853b          	addw	a0,a3,a5
    800002de:	0785                	addi	a5,a5,1
    800002e0:	fff7c703          	lbu	a4,-1(a5)
    800002e4:	fb7d                	bnez	a4,800002da <strlen+0x14>
    ;
  return n;
}
    800002e6:	6422                	ld	s0,8(sp)
    800002e8:	0141                	addi	sp,sp,16
    800002ea:	8082                	ret
  for(n = 0; s[n]; n++)
    800002ec:	4501                	li	a0,0
    800002ee:	bfe5                	j	800002e6 <strlen+0x20>

00000000800002f0 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800002f0:	1141                	addi	sp,sp,-16
    800002f2:	e406                	sd	ra,8(sp)
    800002f4:	e022                	sd	s0,0(sp)
    800002f6:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800002f8:	317000ef          	jal	ra,80000e0e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800002fc:	00007717          	auipc	a4,0x7
    80000300:	6a470713          	addi	a4,a4,1700 # 800079a0 <started>
  if(cpuid() == 0){
    80000304:	c51d                	beqz	a0,80000332 <main+0x42>
    while(started == 0)
    80000306:	431c                	lw	a5,0(a4)
    80000308:	2781                	sext.w	a5,a5
    8000030a:	dff5                	beqz	a5,80000306 <main+0x16>
      ;
    __sync_synchronize();
    8000030c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000310:	2ff000ef          	jal	ra,80000e0e <cpuid>
    80000314:	85aa                	mv	a1,a0
    80000316:	00007517          	auipc	a0,0x7
    8000031a:	d2250513          	addi	a0,a0,-734 # 80007038 <etext+0x38>
    8000031e:	5f1040ef          	jal	ra,8000510e <printf>
    kvminithart();    // turn on paging
    80000322:	080000ef          	jal	ra,800003a2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000326:	602010ef          	jal	ra,80001928 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000032a:	3fa040ef          	jal	ra,80004724 <plicinithart>
  }

  scheduler();
    8000032e:	73f000ef          	jal	ra,8000126c <scheduler>
    consoleinit();
    80000332:	507040ef          	jal	ra,80005038 <consoleinit>
    printfinit();
    80000336:	0c6050ef          	jal	ra,800053fc <printfinit>
    printf("\n");
    8000033a:	00007517          	auipc	a0,0x7
    8000033e:	d0e50513          	addi	a0,a0,-754 # 80007048 <etext+0x48>
    80000342:	5cd040ef          	jal	ra,8000510e <printf>
    printf("xv6 kernel is booting\n");
    80000346:	00007517          	auipc	a0,0x7
    8000034a:	cda50513          	addi	a0,a0,-806 # 80007020 <etext+0x20>
    8000034e:	5c1040ef          	jal	ra,8000510e <printf>
    printf("\n");
    80000352:	00007517          	auipc	a0,0x7
    80000356:	cf650513          	addi	a0,a0,-778 # 80007048 <etext+0x48>
    8000035a:	5b5040ef          	jal	ra,8000510e <printf>
    kinit();         // physical page allocator
    8000035e:	d6dff0ef          	jal	ra,800000ca <kinit>
    kvminit();       // create kernel page table
    80000362:	2d4000ef          	jal	ra,80000636 <kvminit>
    kvminithart();   // turn on paging
    80000366:	03c000ef          	jal	ra,800003a2 <kvminithart>
    procinit();      // process table
    8000036a:	1fd000ef          	jal	ra,80000d66 <procinit>
    trapinit();      // trap vectors
    8000036e:	596010ef          	jal	ra,80001904 <trapinit>
    trapinithart();  // install kernel trap vector
    80000372:	5b6010ef          	jal	ra,80001928 <trapinithart>
    plicinit();      // set up interrupt controller
    80000376:	398040ef          	jal	ra,8000470e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000037a:	3aa040ef          	jal	ra,80004724 <plicinithart>
    binit();         // buffer cache
    8000037e:	429010ef          	jal	ra,80001fa6 <binit>
    iinit();         // inode table
    80000382:	204020ef          	jal	ra,80002586 <iinit>
    fileinit();      // file table
    80000386:	7a7020ef          	jal	ra,8000332c <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000038a:	48a040ef          	jal	ra,80004814 <virtio_disk_init>
    userinit();      // first user process
    8000038e:	515000ef          	jal	ra,800010a2 <userinit>
    __sync_synchronize();
    80000392:	0ff0000f          	fence
    started = 1;
    80000396:	4785                	li	a5,1
    80000398:	00007717          	auipc	a4,0x7
    8000039c:	60f72423          	sw	a5,1544(a4) # 800079a0 <started>
    800003a0:	b779                	j	8000032e <main+0x3e>

00000000800003a2 <kvminithart>:
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void kvminithart()
{
    800003a2:	1141                	addi	sp,sp,-16
    800003a4:	e422                	sd	s0,8(sp)
    800003a6:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800003a8:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800003ac:	00007797          	auipc	a5,0x7
    800003b0:	5fc7b783          	ld	a5,1532(a5) # 800079a8 <kernel_pagetable>
    800003b4:	83b1                	srli	a5,a5,0xc
    800003b6:	577d                	li	a4,-1
    800003b8:	177e                	slli	a4,a4,0x3f
    800003ba:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800003bc:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800003c0:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800003c4:	6422                	ld	s0,8(sp)
    800003c6:	0141                	addi	sp,sp,16
    800003c8:	8082                	ret

00000000800003ca <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800003ca:	7139                	addi	sp,sp,-64
    800003cc:	fc06                	sd	ra,56(sp)
    800003ce:	f822                	sd	s0,48(sp)
    800003d0:	f426                	sd	s1,40(sp)
    800003d2:	f04a                	sd	s2,32(sp)
    800003d4:	ec4e                	sd	s3,24(sp)
    800003d6:	e852                	sd	s4,16(sp)
    800003d8:	e456                	sd	s5,8(sp)
    800003da:	e05a                	sd	s6,0(sp)
    800003dc:	0080                	addi	s0,sp,64
    800003de:	892a                	mv	s2,a0
    800003e0:	89ae                	mv	s3,a1
    800003e2:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    800003e4:	57fd                	li	a5,-1
    800003e6:	83e9                	srli	a5,a5,0x1a
    800003e8:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--)
    800003ea:	4b31                	li	s6,12
  if (va >= MAXVA)
    800003ec:	02b7fb63          	bgeu	a5,a1,80000422 <walk+0x58>
    panic("walk");
    800003f0:	00007517          	auipc	a0,0x7
    800003f4:	c6050513          	addi	a0,a0,-928 # 80007050 <etext+0x50>
    800003f8:	7cb040ef          	jal	ra,800053c2 <panic>
      }
#endif
    }
    else
    {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    800003fc:	060a8563          	beqz	s5,80000466 <walk+0x9c>
    80000400:	cffff0ef          	jal	ra,800000fe <kalloc>
    80000404:	892a                	mv	s2,a0
    80000406:	c135                	beqz	a0,8000046a <walk+0xa0>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000408:	6605                	lui	a2,0x1
    8000040a:	4581                	li	a1,0
    8000040c:	d43ff0ef          	jal	ra,8000014e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000410:	00c95793          	srli	a5,s2,0xc
    80000414:	07aa                	slli	a5,a5,0xa
    80000416:	0017e793          	ori	a5,a5,1
    8000041a:	e09c                	sd	a5,0(s1)
  for (int level = 2; level > 0; level--)
    8000041c:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde2f7>
    8000041e:	036a0263          	beq	s4,s6,80000442 <walk+0x78>
    pte_t *pte = &pagetable[PX(level, va)];
    80000422:	0149d4b3          	srl	s1,s3,s4
    80000426:	1ff4f493          	andi	s1,s1,511
    8000042a:	048e                	slli	s1,s1,0x3
    8000042c:	94ca                	add	s1,s1,s2
    if (*pte & PTE_V)
    8000042e:	609c                	ld	a5,0(s1)
    80000430:	0017f713          	andi	a4,a5,1
    80000434:	d761                	beqz	a4,800003fc <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000436:	00a7d913          	srli	s2,a5,0xa
    8000043a:	0932                	slli	s2,s2,0xc
      if (PTE_LEAF(*pte))
    8000043c:	8bb9                	andi	a5,a5,14
    8000043e:	dff9                	beqz	a5,8000041c <walk+0x52>
    80000440:	a801                	j	80000450 <walk+0x86>
    }
  }
  return &pagetable[PX(0, va)];
    80000442:	00c9d993          	srli	s3,s3,0xc
    80000446:	1ff9f993          	andi	s3,s3,511
    8000044a:	098e                	slli	s3,s3,0x3
    8000044c:	013904b3          	add	s1,s2,s3
}
    80000450:	8526                	mv	a0,s1
    80000452:	70e2                	ld	ra,56(sp)
    80000454:	7442                	ld	s0,48(sp)
    80000456:	74a2                	ld	s1,40(sp)
    80000458:	7902                	ld	s2,32(sp)
    8000045a:	69e2                	ld	s3,24(sp)
    8000045c:	6a42                	ld	s4,16(sp)
    8000045e:	6aa2                	ld	s5,8(sp)
    80000460:	6b02                	ld	s6,0(sp)
    80000462:	6121                	addi	sp,sp,64
    80000464:	8082                	ret
        return 0;
    80000466:	4481                	li	s1,0
    80000468:	b7e5                	j	80000450 <walk+0x86>
    8000046a:	84aa                	mv	s1,a0
    8000046c:	b7d5                	j	80000450 <walk+0x86>

000000008000046e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    8000046e:	57fd                	li	a5,-1
    80000470:	83e9                	srli	a5,a5,0x1a
    80000472:	00b7f463          	bgeu	a5,a1,8000047a <walkaddr+0xc>
    return 0;
    80000476:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000478:	8082                	ret
{
    8000047a:	1141                	addi	sp,sp,-16
    8000047c:	e406                	sd	ra,8(sp)
    8000047e:	e022                	sd	s0,0(sp)
    80000480:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000482:	4601                	li	a2,0
    80000484:	f47ff0ef          	jal	ra,800003ca <walk>
  if (pte == 0)
    80000488:	c105                	beqz	a0,800004a8 <walkaddr+0x3a>
  if ((*pte & PTE_V) == 0)
    8000048a:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    8000048c:	0117f693          	andi	a3,a5,17
    80000490:	4745                	li	a4,17
    return 0;
    80000492:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80000494:	00e68663          	beq	a3,a4,800004a0 <walkaddr+0x32>
}
    80000498:	60a2                	ld	ra,8(sp)
    8000049a:	6402                	ld	s0,0(sp)
    8000049c:	0141                	addi	sp,sp,16
    8000049e:	8082                	ret
  pa = PTE2PA(*pte);
    800004a0:	83a9                	srli	a5,a5,0xa
    800004a2:	00c79513          	slli	a0,a5,0xc
  return pa;
    800004a6:	bfcd                	j	80000498 <walkaddr+0x2a>
    return 0;
    800004a8:	4501                	li	a0,0
    800004aa:	b7fd                	j	80000498 <walkaddr+0x2a>

00000000800004ac <mappages>:
// physical addresses starting at pa.
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800004ac:	715d                	addi	sp,sp,-80
    800004ae:	e486                	sd	ra,72(sp)
    800004b0:	e0a2                	sd	s0,64(sp)
    800004b2:	fc26                	sd	s1,56(sp)
    800004b4:	f84a                	sd	s2,48(sp)
    800004b6:	f44e                	sd	s3,40(sp)
    800004b8:	f052                	sd	s4,32(sp)
    800004ba:	ec56                	sd	s5,24(sp)
    800004bc:	e85a                	sd	s6,16(sp)
    800004be:	e45e                	sd	s7,8(sp)
    800004c0:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    800004c2:	03459793          	slli	a5,a1,0x34
    800004c6:	e7a9                	bnez	a5,80000510 <mappages+0x64>
    800004c8:	8aaa                	mv	s5,a0
    800004ca:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    800004cc:	03461793          	slli	a5,a2,0x34
    800004d0:	e7b1                	bnez	a5,8000051c <mappages+0x70>
    panic("mappages: size not aligned");

  if (size == 0)
    800004d2:	ca39                	beqz	a2,80000528 <mappages+0x7c>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    800004d4:	77fd                	lui	a5,0xfffff
    800004d6:	963e                	add	a2,a2,a5
    800004d8:	00b609b3          	add	s3,a2,a1
  a = va;
    800004dc:	892e                	mv	s2,a1
    800004de:	40b68a33          	sub	s4,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    800004e2:	6b85                	lui	s7,0x1
    800004e4:	012a04b3          	add	s1,s4,s2
    if ((pte = walk(pagetable, a, 1)) == 0)
    800004e8:	4605                	li	a2,1
    800004ea:	85ca                	mv	a1,s2
    800004ec:	8556                	mv	a0,s5
    800004ee:	eddff0ef          	jal	ra,800003ca <walk>
    800004f2:	c539                	beqz	a0,80000540 <mappages+0x94>
    if (*pte & PTE_V)
    800004f4:	611c                	ld	a5,0(a0)
    800004f6:	8b85                	andi	a5,a5,1
    800004f8:	ef95                	bnez	a5,80000534 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800004fa:	80b1                	srli	s1,s1,0xc
    800004fc:	04aa                	slli	s1,s1,0xa
    800004fe:	0164e4b3          	or	s1,s1,s6
    80000502:	0014e493          	ori	s1,s1,1
    80000506:	e104                	sd	s1,0(a0)
    if (a == last)
    80000508:	05390863          	beq	s2,s3,80000558 <mappages+0xac>
    a += PGSIZE;
    8000050c:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    8000050e:	bfd9                	j	800004e4 <mappages+0x38>
    panic("mappages: va not aligned");
    80000510:	00007517          	auipc	a0,0x7
    80000514:	b4850513          	addi	a0,a0,-1208 # 80007058 <etext+0x58>
    80000518:	6ab040ef          	jal	ra,800053c2 <panic>
    panic("mappages: size not aligned");
    8000051c:	00007517          	auipc	a0,0x7
    80000520:	b5c50513          	addi	a0,a0,-1188 # 80007078 <etext+0x78>
    80000524:	69f040ef          	jal	ra,800053c2 <panic>
    panic("mappages: size");
    80000528:	00007517          	auipc	a0,0x7
    8000052c:	b7050513          	addi	a0,a0,-1168 # 80007098 <etext+0x98>
    80000530:	693040ef          	jal	ra,800053c2 <panic>
      panic("mappages: remap");
    80000534:	00007517          	auipc	a0,0x7
    80000538:	b7450513          	addi	a0,a0,-1164 # 800070a8 <etext+0xa8>
    8000053c:	687040ef          	jal	ra,800053c2 <panic>
      return -1;
    80000540:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80000542:	60a6                	ld	ra,72(sp)
    80000544:	6406                	ld	s0,64(sp)
    80000546:	74e2                	ld	s1,56(sp)
    80000548:	7942                	ld	s2,48(sp)
    8000054a:	79a2                	ld	s3,40(sp)
    8000054c:	7a02                	ld	s4,32(sp)
    8000054e:	6ae2                	ld	s5,24(sp)
    80000550:	6b42                	ld	s6,16(sp)
    80000552:	6ba2                	ld	s7,8(sp)
    80000554:	6161                	addi	sp,sp,80
    80000556:	8082                	ret
  return 0;
    80000558:	4501                	li	a0,0
    8000055a:	b7e5                	j	80000542 <mappages+0x96>

000000008000055c <kvmmap>:
{
    8000055c:	1141                	addi	sp,sp,-16
    8000055e:	e406                	sd	ra,8(sp)
    80000560:	e022                	sd	s0,0(sp)
    80000562:	0800                	addi	s0,sp,16
    80000564:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000566:	86b2                	mv	a3,a2
    80000568:	863e                	mv	a2,a5
    8000056a:	f43ff0ef          	jal	ra,800004ac <mappages>
    8000056e:	e509                	bnez	a0,80000578 <kvmmap+0x1c>
}
    80000570:	60a2                	ld	ra,8(sp)
    80000572:	6402                	ld	s0,0(sp)
    80000574:	0141                	addi	sp,sp,16
    80000576:	8082                	ret
    panic("kvmmap");
    80000578:	00007517          	auipc	a0,0x7
    8000057c:	b4050513          	addi	a0,a0,-1216 # 800070b8 <etext+0xb8>
    80000580:	643040ef          	jal	ra,800053c2 <panic>

0000000080000584 <kvmmake>:
{
    80000584:	1101                	addi	sp,sp,-32
    80000586:	ec06                	sd	ra,24(sp)
    80000588:	e822                	sd	s0,16(sp)
    8000058a:	e426                	sd	s1,8(sp)
    8000058c:	e04a                	sd	s2,0(sp)
    8000058e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    80000590:	b6fff0ef          	jal	ra,800000fe <kalloc>
    80000594:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000596:	6605                	lui	a2,0x1
    80000598:	4581                	li	a1,0
    8000059a:	bb5ff0ef          	jal	ra,8000014e <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000059e:	4719                	li	a4,6
    800005a0:	6685                	lui	a3,0x1
    800005a2:	10000637          	lui	a2,0x10000
    800005a6:	100005b7          	lui	a1,0x10000
    800005aa:	8526                	mv	a0,s1
    800005ac:	fb1ff0ef          	jal	ra,8000055c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800005b0:	4719                	li	a4,6
    800005b2:	6685                	lui	a3,0x1
    800005b4:	10001637          	lui	a2,0x10001
    800005b8:	100015b7          	lui	a1,0x10001
    800005bc:	8526                	mv	a0,s1
    800005be:	f9fff0ef          	jal	ra,8000055c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800005c2:	4719                	li	a4,6
    800005c4:	040006b7          	lui	a3,0x4000
    800005c8:	0c000637          	lui	a2,0xc000
    800005cc:	0c0005b7          	lui	a1,0xc000
    800005d0:	8526                	mv	a0,s1
    800005d2:	f8bff0ef          	jal	ra,8000055c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800005d6:	00007917          	auipc	s2,0x7
    800005da:	a2a90913          	addi	s2,s2,-1494 # 80007000 <etext>
    800005de:	4729                	li	a4,10
    800005e0:	80007697          	auipc	a3,0x80007
    800005e4:	a2068693          	addi	a3,a3,-1504 # 7000 <_entry-0x7fff9000>
    800005e8:	4605                	li	a2,1
    800005ea:	067e                	slli	a2,a2,0x1f
    800005ec:	85b2                	mv	a1,a2
    800005ee:	8526                	mv	a0,s1
    800005f0:	f6dff0ef          	jal	ra,8000055c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    800005f4:	4719                	li	a4,6
    800005f6:	46c5                	li	a3,17
    800005f8:	06ee                	slli	a3,a3,0x1b
    800005fa:	412686b3          	sub	a3,a3,s2
    800005fe:	864a                	mv	a2,s2
    80000600:	85ca                	mv	a1,s2
    80000602:	8526                	mv	a0,s1
    80000604:	f59ff0ef          	jal	ra,8000055c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80000608:	4729                	li	a4,10
    8000060a:	6685                	lui	a3,0x1
    8000060c:	00006617          	auipc	a2,0x6
    80000610:	9f460613          	addi	a2,a2,-1548 # 80006000 <_trampoline>
    80000614:	040005b7          	lui	a1,0x4000
    80000618:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000061a:	05b2                	slli	a1,a1,0xc
    8000061c:	8526                	mv	a0,s1
    8000061e:	f3fff0ef          	jal	ra,8000055c <kvmmap>
  proc_mapstacks(kpgtbl);
    80000622:	8526                	mv	a0,s1
    80000624:	6b8000ef          	jal	ra,80000cdc <proc_mapstacks>
}
    80000628:	8526                	mv	a0,s1
    8000062a:	60e2                	ld	ra,24(sp)
    8000062c:	6442                	ld	s0,16(sp)
    8000062e:	64a2                	ld	s1,8(sp)
    80000630:	6902                	ld	s2,0(sp)
    80000632:	6105                	addi	sp,sp,32
    80000634:	8082                	ret

0000000080000636 <kvminit>:
{
    80000636:	1141                	addi	sp,sp,-16
    80000638:	e406                	sd	ra,8(sp)
    8000063a:	e022                	sd	s0,0(sp)
    8000063c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000063e:	f47ff0ef          	jal	ra,80000584 <kvmmake>
    80000642:	00007797          	auipc	a5,0x7
    80000646:	36a7b323          	sd	a0,870(a5) # 800079a8 <kernel_pagetable>
}
    8000064a:	60a2                	ld	ra,8(sp)
    8000064c:	6402                	ld	s0,0(sp)
    8000064e:	0141                	addi	sp,sp,16
    80000650:	8082                	ret

0000000080000652 <uvmunmap>:

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000652:	715d                	addi	sp,sp,-80
    80000654:	e486                	sd	ra,72(sp)
    80000656:	e0a2                	sd	s0,64(sp)
    80000658:	fc26                	sd	s1,56(sp)
    8000065a:	f84a                	sd	s2,48(sp)
    8000065c:	f44e                	sd	s3,40(sp)
    8000065e:	f052                	sd	s4,32(sp)
    80000660:	ec56                	sd	s5,24(sp)
    80000662:	e85a                	sd	s6,16(sp)
    80000664:	e45e                	sd	s7,8(sp)
    80000666:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;
  int sz;

  if ((va % PGSIZE) != 0)
    80000668:	03459793          	slli	a5,a1,0x34
    8000066c:	e795                	bnez	a5,80000698 <uvmunmap+0x46>
    8000066e:	8a2a                	mv	s4,a0
    80000670:	892e                	mv	s2,a1
    80000672:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += sz)
    80000674:	0632                	slli	a2,a2,0xc
    80000676:	00b609b3          	add	s3,a2,a1
    if ((*pte & PTE_V) == 0)
    {
      printf("va=%ld pte=%ld\n", a, *pte);
      panic("uvmunmap: not mapped");
    }
    if (PTE_FLAGS(*pte) == PTE_V)
    8000067a:	4b85                	li	s7,1
  for (a = va; a < va + npages * PGSIZE; a += sz)
    8000067c:	6b05                	lui	s6,0x1
    8000067e:	0735e163          	bltu	a1,s3,800006e0 <uvmunmap+0x8e>
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
  }
}
    80000682:	60a6                	ld	ra,72(sp)
    80000684:	6406                	ld	s0,64(sp)
    80000686:	74e2                	ld	s1,56(sp)
    80000688:	7942                	ld	s2,48(sp)
    8000068a:	79a2                	ld	s3,40(sp)
    8000068c:	7a02                	ld	s4,32(sp)
    8000068e:	6ae2                	ld	s5,24(sp)
    80000690:	6b42                	ld	s6,16(sp)
    80000692:	6ba2                	ld	s7,8(sp)
    80000694:	6161                	addi	sp,sp,80
    80000696:	8082                	ret
    panic("uvmunmap: not aligned");
    80000698:	00007517          	auipc	a0,0x7
    8000069c:	a2850513          	addi	a0,a0,-1496 # 800070c0 <etext+0xc0>
    800006a0:	523040ef          	jal	ra,800053c2 <panic>
      panic("uvmunmap: walk");
    800006a4:	00007517          	auipc	a0,0x7
    800006a8:	a3450513          	addi	a0,a0,-1484 # 800070d8 <etext+0xd8>
    800006ac:	517040ef          	jal	ra,800053c2 <panic>
      printf("va=%ld pte=%ld\n", a, *pte);
    800006b0:	85ca                	mv	a1,s2
    800006b2:	00007517          	auipc	a0,0x7
    800006b6:	a3650513          	addi	a0,a0,-1482 # 800070e8 <etext+0xe8>
    800006ba:	255040ef          	jal	ra,8000510e <printf>
      panic("uvmunmap: not mapped");
    800006be:	00007517          	auipc	a0,0x7
    800006c2:	a3a50513          	addi	a0,a0,-1478 # 800070f8 <etext+0xf8>
    800006c6:	4fd040ef          	jal	ra,800053c2 <panic>
      panic("uvmunmap: not a leaf");
    800006ca:	00007517          	auipc	a0,0x7
    800006ce:	a4650513          	addi	a0,a0,-1466 # 80007110 <etext+0x110>
    800006d2:	4f1040ef          	jal	ra,800053c2 <panic>
    *pte = 0;
    800006d6:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += sz)
    800006da:	995a                	add	s2,s2,s6
    800006dc:	fb3973e3          	bgeu	s2,s3,80000682 <uvmunmap+0x30>
    if ((pte = walk(pagetable, a, 0)) == 0)
    800006e0:	4601                	li	a2,0
    800006e2:	85ca                	mv	a1,s2
    800006e4:	8552                	mv	a0,s4
    800006e6:	ce5ff0ef          	jal	ra,800003ca <walk>
    800006ea:	84aa                	mv	s1,a0
    800006ec:	dd45                	beqz	a0,800006a4 <uvmunmap+0x52>
    if ((*pte & PTE_V) == 0)
    800006ee:	6110                	ld	a2,0(a0)
    800006f0:	00167793          	andi	a5,a2,1
    800006f4:	dfd5                	beqz	a5,800006b0 <uvmunmap+0x5e>
    if (PTE_FLAGS(*pte) == PTE_V)
    800006f6:	3ff67793          	andi	a5,a2,1023
    800006fa:	fd7788e3          	beq	a5,s7,800006ca <uvmunmap+0x78>
    if (do_free)
    800006fe:	fc0a8ce3          	beqz	s5,800006d6 <uvmunmap+0x84>
      uint64 pa = PTE2PA(*pte);
    80000702:	8229                	srli	a2,a2,0xa
      kfree((void *)pa);
    80000704:	00c61513          	slli	a0,a2,0xc
    80000708:	915ff0ef          	jal	ra,8000001c <kfree>
    8000070c:	b7e9                	j	800006d6 <uvmunmap+0x84>

000000008000070e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000070e:	1101                	addi	sp,sp,-32
    80000710:	ec06                	sd	ra,24(sp)
    80000712:	e822                	sd	s0,16(sp)
    80000714:	e426                	sd	s1,8(sp)
    80000716:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80000718:	9e7ff0ef          	jal	ra,800000fe <kalloc>
    8000071c:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000071e:	c509                	beqz	a0,80000728 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80000720:	6605                	lui	a2,0x1
    80000722:	4581                	li	a1,0
    80000724:	a2bff0ef          	jal	ra,8000014e <memset>
  return pagetable;
}
    80000728:	8526                	mv	a0,s1
    8000072a:	60e2                	ld	ra,24(sp)
    8000072c:	6442                	ld	s0,16(sp)
    8000072e:	64a2                	ld	s1,8(sp)
    80000730:	6105                	addi	sp,sp,32
    80000732:	8082                	ret

0000000080000734 <uvmfirst>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80000734:	7179                	addi	sp,sp,-48
    80000736:	f406                	sd	ra,40(sp)
    80000738:	f022                	sd	s0,32(sp)
    8000073a:	ec26                	sd	s1,24(sp)
    8000073c:	e84a                	sd	s2,16(sp)
    8000073e:	e44e                	sd	s3,8(sp)
    80000740:	e052                	sd	s4,0(sp)
    80000742:	1800                	addi	s0,sp,48
  char *mem;

  if (sz >= PGSIZE)
    80000744:	6785                	lui	a5,0x1
    80000746:	04f67063          	bgeu	a2,a5,80000786 <uvmfirst+0x52>
    8000074a:	8a2a                	mv	s4,a0
    8000074c:	89ae                	mv	s3,a1
    8000074e:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80000750:	9afff0ef          	jal	ra,800000fe <kalloc>
    80000754:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000756:	6605                	lui	a2,0x1
    80000758:	4581                	li	a1,0
    8000075a:	9f5ff0ef          	jal	ra,8000014e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    8000075e:	4779                	li	a4,30
    80000760:	86ca                	mv	a3,s2
    80000762:	6605                	lui	a2,0x1
    80000764:	4581                	li	a1,0
    80000766:	8552                	mv	a0,s4
    80000768:	d45ff0ef          	jal	ra,800004ac <mappages>
  memmove(mem, src, sz);
    8000076c:	8626                	mv	a2,s1
    8000076e:	85ce                	mv	a1,s3
    80000770:	854a                	mv	a0,s2
    80000772:	a39ff0ef          	jal	ra,800001aa <memmove>
}
    80000776:	70a2                	ld	ra,40(sp)
    80000778:	7402                	ld	s0,32(sp)
    8000077a:	64e2                	ld	s1,24(sp)
    8000077c:	6942                	ld	s2,16(sp)
    8000077e:	69a2                	ld	s3,8(sp)
    80000780:	6a02                	ld	s4,0(sp)
    80000782:	6145                	addi	sp,sp,48
    80000784:	8082                	ret
    panic("uvmfirst: more than a page");
    80000786:	00007517          	auipc	a0,0x7
    8000078a:	9a250513          	addi	a0,a0,-1630 # 80007128 <etext+0x128>
    8000078e:	435040ef          	jal	ra,800053c2 <panic>

0000000080000792 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80000792:	1101                	addi	sp,sp,-32
    80000794:	ec06                	sd	ra,24(sp)
    80000796:	e822                	sd	s0,16(sp)
    80000798:	e426                	sd	s1,8(sp)
    8000079a:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    8000079c:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    8000079e:	00b67d63          	bgeu	a2,a1,800007b8 <uvmdealloc+0x26>
    800007a2:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    800007a4:	6785                	lui	a5,0x1
    800007a6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800007a8:	00f60733          	add	a4,a2,a5
    800007ac:	76fd                	lui	a3,0xfffff
    800007ae:	8f75                	and	a4,a4,a3
    800007b0:	97ae                	add	a5,a5,a1
    800007b2:	8ff5                	and	a5,a5,a3
    800007b4:	00f76863          	bltu	a4,a5,800007c4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800007b8:	8526                	mv	a0,s1
    800007ba:	60e2                	ld	ra,24(sp)
    800007bc:	6442                	ld	s0,16(sp)
    800007be:	64a2                	ld	s1,8(sp)
    800007c0:	6105                	addi	sp,sp,32
    800007c2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800007c4:	8f99                	sub	a5,a5,a4
    800007c6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800007c8:	4685                	li	a3,1
    800007ca:	0007861b          	sext.w	a2,a5
    800007ce:	85ba                	mv	a1,a4
    800007d0:	e83ff0ef          	jal	ra,80000652 <uvmunmap>
    800007d4:	b7d5                	j	800007b8 <uvmdealloc+0x26>

00000000800007d6 <uvmalloc>:
  if (newsz < oldsz)
    800007d6:	08b66963          	bltu	a2,a1,80000868 <uvmalloc+0x92>
{
    800007da:	7139                	addi	sp,sp,-64
    800007dc:	fc06                	sd	ra,56(sp)
    800007de:	f822                	sd	s0,48(sp)
    800007e0:	f426                	sd	s1,40(sp)
    800007e2:	f04a                	sd	s2,32(sp)
    800007e4:	ec4e                	sd	s3,24(sp)
    800007e6:	e852                	sd	s4,16(sp)
    800007e8:	e456                	sd	s5,8(sp)
    800007ea:	e05a                	sd	s6,0(sp)
    800007ec:	0080                	addi	s0,sp,64
    800007ee:	8aaa                	mv	s5,a0
    800007f0:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800007f2:	6785                	lui	a5,0x1
    800007f4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800007f6:	95be                	add	a1,a1,a5
    800007f8:	77fd                	lui	a5,0xfffff
    800007fa:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += sz)
    800007fe:	06c9f763          	bgeu	s3,a2,8000086c <uvmalloc+0x96>
    80000802:	894e                	mv	s2,s3
    if (mappages(pagetable, a, sz, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80000804:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80000808:	8f7ff0ef          	jal	ra,800000fe <kalloc>
    8000080c:	84aa                	mv	s1,a0
    if (mem == 0)
    8000080e:	c11d                	beqz	a0,80000834 <uvmalloc+0x5e>
    memset(mem, 0, sz);
    80000810:	6605                	lui	a2,0x1
    80000812:	4581                	li	a1,0
    80000814:	93bff0ef          	jal	ra,8000014e <memset>
    if (mappages(pagetable, a, sz, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80000818:	875a                	mv	a4,s6
    8000081a:	86a6                	mv	a3,s1
    8000081c:	6605                	lui	a2,0x1
    8000081e:	85ca                	mv	a1,s2
    80000820:	8556                	mv	a0,s5
    80000822:	c8bff0ef          	jal	ra,800004ac <mappages>
    80000826:	e51d                	bnez	a0,80000854 <uvmalloc+0x7e>
  for (a = oldsz; a < newsz; a += sz)
    80000828:	6785                	lui	a5,0x1
    8000082a:	993e                	add	s2,s2,a5
    8000082c:	fd496ee3          	bltu	s2,s4,80000808 <uvmalloc+0x32>
  return newsz;
    80000830:	8552                	mv	a0,s4
    80000832:	a039                	j	80000840 <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    80000834:	864e                	mv	a2,s3
    80000836:	85ca                	mv	a1,s2
    80000838:	8556                	mv	a0,s5
    8000083a:	f59ff0ef          	jal	ra,80000792 <uvmdealloc>
      return 0;
    8000083e:	4501                	li	a0,0
}
    80000840:	70e2                	ld	ra,56(sp)
    80000842:	7442                	ld	s0,48(sp)
    80000844:	74a2                	ld	s1,40(sp)
    80000846:	7902                	ld	s2,32(sp)
    80000848:	69e2                	ld	s3,24(sp)
    8000084a:	6a42                	ld	s4,16(sp)
    8000084c:	6aa2                	ld	s5,8(sp)
    8000084e:	6b02                	ld	s6,0(sp)
    80000850:	6121                	addi	sp,sp,64
    80000852:	8082                	ret
      kfree(mem);
    80000854:	8526                	mv	a0,s1
    80000856:	fc6ff0ef          	jal	ra,8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000085a:	864e                	mv	a2,s3
    8000085c:	85ca                	mv	a1,s2
    8000085e:	8556                	mv	a0,s5
    80000860:	f33ff0ef          	jal	ra,80000792 <uvmdealloc>
      return 0;
    80000864:	4501                	li	a0,0
    80000866:	bfe9                	j	80000840 <uvmalloc+0x6a>
    return oldsz;
    80000868:	852e                	mv	a0,a1
}
    8000086a:	8082                	ret
  return newsz;
    8000086c:	8532                	mv	a0,a2
    8000086e:	bfc9                	j	80000840 <uvmalloc+0x6a>

0000000080000870 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    80000870:	7179                	addi	sp,sp,-48
    80000872:	f406                	sd	ra,40(sp)
    80000874:	f022                	sd	s0,32(sp)
    80000876:	ec26                	sd	s1,24(sp)
    80000878:	e84a                	sd	s2,16(sp)
    8000087a:	e44e                	sd	s3,8(sp)
    8000087c:	e052                	sd	s4,0(sp)
    8000087e:	1800                	addi	s0,sp,48
    80000880:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++)
    80000882:	84aa                	mv	s1,a0
    80000884:	6905                	lui	s2,0x1
    80000886:	992a                	add	s2,s2,a0
  {
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000888:	4985                	li	s3,1
    8000088a:	a819                	j	800008a0 <freewalk+0x30>
    {
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000088c:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000088e:	00c79513          	slli	a0,a5,0xc
    80000892:	fdfff0ef          	jal	ra,80000870 <freewalk>
      pagetable[i] = 0;
    80000896:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++)
    8000089a:	04a1                	addi	s1,s1,8
    8000089c:	01248f63          	beq	s1,s2,800008ba <freewalk+0x4a>
    pte_t pte = pagetable[i];
    800008a0:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    800008a2:	00f7f713          	andi	a4,a5,15
    800008a6:	ff3703e3          	beq	a4,s3,8000088c <freewalk+0x1c>
    }
    else if (pte & PTE_V)
    800008aa:	8b85                	andi	a5,a5,1
    800008ac:	d7fd                	beqz	a5,8000089a <freewalk+0x2a>
    {
      panic("freewalk: leaf");
    800008ae:	00007517          	auipc	a0,0x7
    800008b2:	89a50513          	addi	a0,a0,-1894 # 80007148 <etext+0x148>
    800008b6:	30d040ef          	jal	ra,800053c2 <panic>
    }
  }
  kfree((void *)pagetable);
    800008ba:	8552                	mv	a0,s4
    800008bc:	f60ff0ef          	jal	ra,8000001c <kfree>
}
    800008c0:	70a2                	ld	ra,40(sp)
    800008c2:	7402                	ld	s0,32(sp)
    800008c4:	64e2                	ld	s1,24(sp)
    800008c6:	6942                	ld	s2,16(sp)
    800008c8:	69a2                	ld	s3,8(sp)
    800008ca:	6a02                	ld	s4,0(sp)
    800008cc:	6145                	addi	sp,sp,48
    800008ce:	8082                	ret

00000000800008d0 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void uvmfree(pagetable_t pagetable, uint64 sz)
{
    800008d0:	1101                	addi	sp,sp,-32
    800008d2:	ec06                	sd	ra,24(sp)
    800008d4:	e822                	sd	s0,16(sp)
    800008d6:	e426                	sd	s1,8(sp)
    800008d8:	1000                	addi	s0,sp,32
    800008da:	84aa                	mv	s1,a0
  if (sz > 0)
    800008dc:	e989                	bnez	a1,800008ee <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    800008de:	8526                	mv	a0,s1
    800008e0:	f91ff0ef          	jal	ra,80000870 <freewalk>
}
    800008e4:	60e2                	ld	ra,24(sp)
    800008e6:	6442                	ld	s0,16(sp)
    800008e8:	64a2                	ld	s1,8(sp)
    800008ea:	6105                	addi	sp,sp,32
    800008ec:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    800008ee:	6785                	lui	a5,0x1
    800008f0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800008f2:	95be                	add	a1,a1,a5
    800008f4:	4685                	li	a3,1
    800008f6:	00c5d613          	srli	a2,a1,0xc
    800008fa:	4581                	li	a1,0
    800008fc:	d57ff0ef          	jal	ra,80000652 <uvmunmap>
    80000900:	bff9                	j	800008de <uvmfree+0xe>

0000000080000902 <uvmcopy>:
  uint64 pa, i;
  uint flags;
  char *mem;
  int szinc;

  for (i = 0; i < sz; i += szinc)
    80000902:	c65d                	beqz	a2,800009b0 <uvmcopy+0xae>
{
    80000904:	715d                	addi	sp,sp,-80
    80000906:	e486                	sd	ra,72(sp)
    80000908:	e0a2                	sd	s0,64(sp)
    8000090a:	fc26                	sd	s1,56(sp)
    8000090c:	f84a                	sd	s2,48(sp)
    8000090e:	f44e                	sd	s3,40(sp)
    80000910:	f052                	sd	s4,32(sp)
    80000912:	ec56                	sd	s5,24(sp)
    80000914:	e85a                	sd	s6,16(sp)
    80000916:	e45e                	sd	s7,8(sp)
    80000918:	0880                	addi	s0,sp,80
    8000091a:	8b2a                	mv	s6,a0
    8000091c:	8aae                	mv	s5,a1
    8000091e:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += szinc)
    80000920:	4981                	li	s3,0
  {
    szinc = PGSIZE;
    if ((pte = walk(old, i, 0)) == 0)
    80000922:	4601                	li	a2,0
    80000924:	85ce                	mv	a1,s3
    80000926:	855a                	mv	a0,s6
    80000928:	aa3ff0ef          	jal	ra,800003ca <walk>
    8000092c:	c121                	beqz	a0,8000096c <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if ((*pte & PTE_V) == 0)
    8000092e:	6118                	ld	a4,0(a0)
    80000930:	00177793          	andi	a5,a4,1
    80000934:	c3b1                	beqz	a5,80000978 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000936:	00a75593          	srli	a1,a4,0xa
    8000093a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000093e:	3ff77493          	andi	s1,a4,1023
    if ((mem = kalloc()) == 0)
    80000942:	fbcff0ef          	jal	ra,800000fe <kalloc>
    80000946:	892a                	mv	s2,a0
    80000948:	c129                	beqz	a0,8000098a <uvmcopy+0x88>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    8000094a:	6605                	lui	a2,0x1
    8000094c:	85de                	mv	a1,s7
    8000094e:	85dff0ef          	jal	ra,800001aa <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80000952:	8726                	mv	a4,s1
    80000954:	86ca                	mv	a3,s2
    80000956:	6605                	lui	a2,0x1
    80000958:	85ce                	mv	a1,s3
    8000095a:	8556                	mv	a0,s5
    8000095c:	b51ff0ef          	jal	ra,800004ac <mappages>
    80000960:	e115                	bnez	a0,80000984 <uvmcopy+0x82>
  for (i = 0; i < sz; i += szinc)
    80000962:	6785                	lui	a5,0x1
    80000964:	99be                	add	s3,s3,a5
    80000966:	fb49eee3          	bltu	s3,s4,80000922 <uvmcopy+0x20>
    8000096a:	a805                	j	8000099a <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    8000096c:	00006517          	auipc	a0,0x6
    80000970:	7ec50513          	addi	a0,a0,2028 # 80007158 <etext+0x158>
    80000974:	24f040ef          	jal	ra,800053c2 <panic>
      panic("uvmcopy: page not present");
    80000978:	00007517          	auipc	a0,0x7
    8000097c:	80050513          	addi	a0,a0,-2048 # 80007178 <etext+0x178>
    80000980:	243040ef          	jal	ra,800053c2 <panic>
    {
      kfree(mem);
    80000984:	854a                	mv	a0,s2
    80000986:	e96ff0ef          	jal	ra,8000001c <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000098a:	4685                	li	a3,1
    8000098c:	00c9d613          	srli	a2,s3,0xc
    80000990:	4581                	li	a1,0
    80000992:	8556                	mv	a0,s5
    80000994:	cbfff0ef          	jal	ra,80000652 <uvmunmap>
  return -1;
    80000998:	557d                	li	a0,-1
}
    8000099a:	60a6                	ld	ra,72(sp)
    8000099c:	6406                	ld	s0,64(sp)
    8000099e:	74e2                	ld	s1,56(sp)
    800009a0:	7942                	ld	s2,48(sp)
    800009a2:	79a2                	ld	s3,40(sp)
    800009a4:	7a02                	ld	s4,32(sp)
    800009a6:	6ae2                	ld	s5,24(sp)
    800009a8:	6b42                	ld	s6,16(sp)
    800009aa:	6ba2                	ld	s7,8(sp)
    800009ac:	6161                	addi	sp,sp,80
    800009ae:	8082                	ret
  return 0;
    800009b0:	4501                	li	a0,0
}
    800009b2:	8082                	ret

00000000800009b4 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    800009b4:	1141                	addi	sp,sp,-16
    800009b6:	e406                	sd	ra,8(sp)
    800009b8:	e022                	sd	s0,0(sp)
    800009ba:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    800009bc:	4601                	li	a2,0
    800009be:	a0dff0ef          	jal	ra,800003ca <walk>
  if (pte == 0)
    800009c2:	c901                	beqz	a0,800009d2 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800009c4:	611c                	ld	a5,0(a0)
    800009c6:	9bbd                	andi	a5,a5,-17
    800009c8:	e11c                	sd	a5,0(a0)
}
    800009ca:	60a2                	ld	ra,8(sp)
    800009cc:	6402                	ld	s0,0(sp)
    800009ce:	0141                	addi	sp,sp,16
    800009d0:	8082                	ret
    panic("uvmclear");
    800009d2:	00006517          	auipc	a0,0x6
    800009d6:	7c650513          	addi	a0,a0,1990 # 80007198 <etext+0x198>
    800009da:	1e9040ef          	jal	ra,800053c2 <panic>

00000000800009de <copyout>:
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while (len > 0)
    800009de:	c6c1                	beqz	a3,80000a66 <copyout+0x88>
{
    800009e0:	711d                	addi	sp,sp,-96
    800009e2:	ec86                	sd	ra,88(sp)
    800009e4:	e8a2                	sd	s0,80(sp)
    800009e6:	e4a6                	sd	s1,72(sp)
    800009e8:	e0ca                	sd	s2,64(sp)
    800009ea:	fc4e                	sd	s3,56(sp)
    800009ec:	f852                	sd	s4,48(sp)
    800009ee:	f456                	sd	s5,40(sp)
    800009f0:	f05a                	sd	s6,32(sp)
    800009f2:	ec5e                	sd	s7,24(sp)
    800009f4:	e862                	sd	s8,16(sp)
    800009f6:	e466                	sd	s9,8(sp)
    800009f8:	1080                	addi	s0,sp,96
    800009fa:	8b2a                	mv	s6,a0
    800009fc:	8a2e                	mv	s4,a1
    800009fe:	8ab2                	mv	s5,a2
    80000a00:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(dstva);
    80000a02:	74fd                	lui	s1,0xfffff
    80000a04:	8ced                	and	s1,s1,a1
    if (va0 >= MAXVA)
    80000a06:	57fd                	li	a5,-1
    80000a08:	83e9                	srli	a5,a5,0x1a
    80000a0a:	0697e063          	bltu	a5,s1,80000a6a <copyout+0x8c>
    80000a0e:	6c05                	lui	s8,0x1
    80000a10:	8bbe                	mv	s7,a5
    80000a12:	a015                	j	80000a36 <copyout+0x58>
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000a14:	409a04b3          	sub	s1,s4,s1
    80000a18:	0009061b          	sext.w	a2,s2
    80000a1c:	85d6                	mv	a1,s5
    80000a1e:	9526                	add	a0,a0,s1
    80000a20:	f8aff0ef          	jal	ra,800001aa <memmove>

    len -= n;
    80000a24:	412989b3          	sub	s3,s3,s2
    src += n;
    80000a28:	9aca                	add	s5,s5,s2
  while (len > 0)
    80000a2a:	02098c63          	beqz	s3,80000a62 <copyout+0x84>
    if (va0 >= MAXVA)
    80000a2e:	059be063          	bltu	s7,s9,80000a6e <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    80000a32:	84e6                	mv	s1,s9
    dstva = va0 + PGSIZE;
    80000a34:	8a66                	mv	s4,s9
    if ((pte = walk(pagetable, va0, 0)) == 0)
    80000a36:	4601                	li	a2,0
    80000a38:	85a6                	mv	a1,s1
    80000a3a:	855a                	mv	a0,s6
    80000a3c:	98fff0ef          	jal	ra,800003ca <walk>
    80000a40:	c90d                	beqz	a0,80000a72 <copyout+0x94>
    if ((*pte & PTE_W) == 0)
    80000a42:	611c                	ld	a5,0(a0)
    80000a44:	8b91                	andi	a5,a5,4
    80000a46:	c7a1                	beqz	a5,80000a8e <copyout+0xb0>
    pa0 = walkaddr(pagetable, va0);
    80000a48:	85a6                	mv	a1,s1
    80000a4a:	855a                	mv	a0,s6
    80000a4c:	a23ff0ef          	jal	ra,8000046e <walkaddr>
    if (pa0 == 0)
    80000a50:	c129                	beqz	a0,80000a92 <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    80000a52:	01848cb3          	add	s9,s1,s8
    80000a56:	414c8933          	sub	s2,s9,s4
    80000a5a:	fb29fde3          	bgeu	s3,s2,80000a14 <copyout+0x36>
    80000a5e:	894e                	mv	s2,s3
    80000a60:	bf55                	j	80000a14 <copyout+0x36>
  }
  return 0;
    80000a62:	4501                	li	a0,0
    80000a64:	a801                	j	80000a74 <copyout+0x96>
    80000a66:	4501                	li	a0,0
}
    80000a68:	8082                	ret
      return -1;
    80000a6a:	557d                	li	a0,-1
    80000a6c:	a021                	j	80000a74 <copyout+0x96>
    80000a6e:	557d                	li	a0,-1
    80000a70:	a011                	j	80000a74 <copyout+0x96>
      return -1;
    80000a72:	557d                	li	a0,-1
}
    80000a74:	60e6                	ld	ra,88(sp)
    80000a76:	6446                	ld	s0,80(sp)
    80000a78:	64a6                	ld	s1,72(sp)
    80000a7a:	6906                	ld	s2,64(sp)
    80000a7c:	79e2                	ld	s3,56(sp)
    80000a7e:	7a42                	ld	s4,48(sp)
    80000a80:	7aa2                	ld	s5,40(sp)
    80000a82:	7b02                	ld	s6,32(sp)
    80000a84:	6be2                	ld	s7,24(sp)
    80000a86:	6c42                	ld	s8,16(sp)
    80000a88:	6ca2                	ld	s9,8(sp)
    80000a8a:	6125                	addi	sp,sp,96
    80000a8c:	8082                	ret
      return -1;
    80000a8e:	557d                	li	a0,-1
    80000a90:	b7d5                	j	80000a74 <copyout+0x96>
      return -1;
    80000a92:	557d                	li	a0,-1
    80000a94:	b7c5                	j	80000a74 <copyout+0x96>

0000000080000a96 <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    80000a96:	c6a5                	beqz	a3,80000afe <copyin+0x68>
{
    80000a98:	715d                	addi	sp,sp,-80
    80000a9a:	e486                	sd	ra,72(sp)
    80000a9c:	e0a2                	sd	s0,64(sp)
    80000a9e:	fc26                	sd	s1,56(sp)
    80000aa0:	f84a                	sd	s2,48(sp)
    80000aa2:	f44e                	sd	s3,40(sp)
    80000aa4:	f052                	sd	s4,32(sp)
    80000aa6:	ec56                	sd	s5,24(sp)
    80000aa8:	e85a                	sd	s6,16(sp)
    80000aaa:	e45e                	sd	s7,8(sp)
    80000aac:	e062                	sd	s8,0(sp)
    80000aae:	0880                	addi	s0,sp,80
    80000ab0:	8b2a                	mv	s6,a0
    80000ab2:	8a2e                	mv	s4,a1
    80000ab4:	8c32                	mv	s8,a2
    80000ab6:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80000ab8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000aba:	6a85                	lui	s5,0x1
    80000abc:	a00d                	j	80000ade <copyin+0x48>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000abe:	018505b3          	add	a1,a0,s8
    80000ac2:	0004861b          	sext.w	a2,s1
    80000ac6:	412585b3          	sub	a1,a1,s2
    80000aca:	8552                	mv	a0,s4
    80000acc:	edeff0ef          	jal	ra,800001aa <memmove>

    len -= n;
    80000ad0:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000ad4:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000ad6:	01590c33          	add	s8,s2,s5
  while (len > 0)
    80000ada:	02098063          	beqz	s3,80000afa <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80000ade:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000ae2:	85ca                	mv	a1,s2
    80000ae4:	855a                	mv	a0,s6
    80000ae6:	989ff0ef          	jal	ra,8000046e <walkaddr>
    if (pa0 == 0)
    80000aea:	cd01                	beqz	a0,80000b02 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80000aec:	418904b3          	sub	s1,s2,s8
    80000af0:	94d6                	add	s1,s1,s5
    80000af2:	fc99f6e3          	bgeu	s3,s1,80000abe <copyin+0x28>
    80000af6:	84ce                	mv	s1,s3
    80000af8:	b7d9                	j	80000abe <copyin+0x28>
  }
  return 0;
    80000afa:	4501                	li	a0,0
    80000afc:	a021                	j	80000b04 <copyin+0x6e>
    80000afe:	4501                	li	a0,0
}
    80000b00:	8082                	ret
      return -1;
    80000b02:	557d                	li	a0,-1
}
    80000b04:	60a6                	ld	ra,72(sp)
    80000b06:	6406                	ld	s0,64(sp)
    80000b08:	74e2                	ld	s1,56(sp)
    80000b0a:	7942                	ld	s2,48(sp)
    80000b0c:	79a2                	ld	s3,40(sp)
    80000b0e:	7a02                	ld	s4,32(sp)
    80000b10:	6ae2                	ld	s5,24(sp)
    80000b12:	6b42                	ld	s6,16(sp)
    80000b14:	6ba2                	ld	s7,8(sp)
    80000b16:	6c02                	ld	s8,0(sp)
    80000b18:	6161                	addi	sp,sp,80
    80000b1a:	8082                	ret

0000000080000b1c <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    80000b1c:	c2cd                	beqz	a3,80000bbe <copyinstr+0xa2>
{
    80000b1e:	715d                	addi	sp,sp,-80
    80000b20:	e486                	sd	ra,72(sp)
    80000b22:	e0a2                	sd	s0,64(sp)
    80000b24:	fc26                	sd	s1,56(sp)
    80000b26:	f84a                	sd	s2,48(sp)
    80000b28:	f44e                	sd	s3,40(sp)
    80000b2a:	f052                	sd	s4,32(sp)
    80000b2c:	ec56                	sd	s5,24(sp)
    80000b2e:	e85a                	sd	s6,16(sp)
    80000b30:	e45e                	sd	s7,8(sp)
    80000b32:	0880                	addi	s0,sp,80
    80000b34:	8a2a                	mv	s4,a0
    80000b36:	8b2e                	mv	s6,a1
    80000b38:	8bb2                	mv	s7,a2
    80000b3a:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    80000b3c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000b3e:	6985                	lui	s3,0x1
    80000b40:	a02d                	j	80000b6a <copyinstr+0x4e>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    80000b42:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000b46:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    80000b48:	37fd                	addiw	a5,a5,-1
    80000b4a:	0007851b          	sext.w	a0,a5
  }
  else
  {
    return -1;
  }
}
    80000b4e:	60a6                	ld	ra,72(sp)
    80000b50:	6406                	ld	s0,64(sp)
    80000b52:	74e2                	ld	s1,56(sp)
    80000b54:	7942                	ld	s2,48(sp)
    80000b56:	79a2                	ld	s3,40(sp)
    80000b58:	7a02                	ld	s4,32(sp)
    80000b5a:	6ae2                	ld	s5,24(sp)
    80000b5c:	6b42                	ld	s6,16(sp)
    80000b5e:	6ba2                	ld	s7,8(sp)
    80000b60:	6161                	addi	sp,sp,80
    80000b62:	8082                	ret
    srcva = va0 + PGSIZE;
    80000b64:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    80000b68:	c4b9                	beqz	s1,80000bb6 <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    80000b6a:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000b6e:	85ca                	mv	a1,s2
    80000b70:	8552                	mv	a0,s4
    80000b72:	8fdff0ef          	jal	ra,8000046e <walkaddr>
    if (pa0 == 0)
    80000b76:	c131                	beqz	a0,80000bba <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    80000b78:	417906b3          	sub	a3,s2,s7
    80000b7c:	96ce                	add	a3,a3,s3
    80000b7e:	00d4f363          	bgeu	s1,a3,80000b84 <copyinstr+0x68>
    80000b82:	86a6                	mv	a3,s1
    char *p = (char *)(pa0 + (srcva - va0));
    80000b84:	955e                	add	a0,a0,s7
    80000b86:	41250533          	sub	a0,a0,s2
    while (n > 0)
    80000b8a:	dee9                	beqz	a3,80000b64 <copyinstr+0x48>
    80000b8c:	87da                	mv	a5,s6
      if (*p == '\0')
    80000b8e:	41650633          	sub	a2,a0,s6
    80000b92:	fff48593          	addi	a1,s1,-1 # ffffffffffffefff <end+0xffffffff7ffde2ff>
    80000b96:	95da                	add	a1,a1,s6
    while (n > 0)
    80000b98:	96da                	add	a3,a3,s6
      if (*p == '\0')
    80000b9a:	00f60733          	add	a4,a2,a5
    80000b9e:	00074703          	lbu	a4,0(a4)
    80000ba2:	d345                	beqz	a4,80000b42 <copyinstr+0x26>
        *dst = *p;
    80000ba4:	00e78023          	sb	a4,0(a5)
      --max;
    80000ba8:	40f584b3          	sub	s1,a1,a5
      dst++;
    80000bac:	0785                	addi	a5,a5,1
    while (n > 0)
    80000bae:	fed796e3          	bne	a5,a3,80000b9a <copyinstr+0x7e>
      dst++;
    80000bb2:	8b3e                	mv	s6,a5
    80000bb4:	bf45                	j	80000b64 <copyinstr+0x48>
    80000bb6:	4781                	li	a5,0
    80000bb8:	bf41                	j	80000b48 <copyinstr+0x2c>
      return -1;
    80000bba:	557d                	li	a0,-1
    80000bbc:	bf49                	j	80000b4e <copyinstr+0x32>
  int got_null = 0;
    80000bbe:	4781                	li	a5,0
  if (got_null)
    80000bc0:	37fd                	addiw	a5,a5,-1
    80000bc2:	0007851b          	sext.w	a0,a5
}
    80000bc6:	8082                	ret

0000000080000bc8 <vmprint_recurse>:
  vmprint_recurse(pagetable, 0, 0); // start the recursion with depth 0
}
#endif

void vmprint_recurse(pagetable_t pagetable, int depth, uint64 va_prefix)
{ // seperate function so we can keep track of depth using a parameter
    80000bc8:	7119                	addi	sp,sp,-128
    80000bca:	fc86                	sd	ra,120(sp)
    80000bcc:	f8a2                	sd	s0,112(sp)
    80000bce:	f4a6                	sd	s1,104(sp)
    80000bd0:	f0ca                	sd	s2,96(sp)
    80000bd2:	ecce                	sd	s3,88(sp)
    80000bd4:	e8d2                	sd	s4,80(sp)
    80000bd6:	e4d6                	sd	s5,72(sp)
    80000bd8:	e0da                	sd	s6,64(sp)
    80000bda:	fc5e                	sd	s7,56(sp)
    80000bdc:	f862                	sd	s8,48(sp)
    80000bde:	f466                	sd	s9,40(sp)
    80000be0:	f06a                	sd	s10,32(sp)
    80000be2:	ec6e                	sd	s11,24(sp)
    80000be4:	0100                	addi	s0,sp,128
    80000be6:	8aae                	mv	s5,a1
    80000be8:	8d32                	mv	s10,a2
    { // skip the pte if it's not valid per lab spec
      continue;
    }

    // reconstruct va using i and PX_SHIFT
    uint64 va = va_prefix | ((uint64)i << PXSHIFT(2 - depth));
    80000bea:	4789                	li	a5,2
    80000bec:	9f8d                	subw	a5,a5,a1
    80000bee:	00379c9b          	slliw	s9,a5,0x3
    80000bf2:	00fc8cbb          	addw	s9,s9,a5
    80000bf6:	2cb1                	addiw	s9,s9,12
    80000bf8:	8a2a                	mv	s4,a0
    80000bfa:	4981                	li	s3,0
      printf(".. ");
    }
    printf("..%p: pte %p pa %p\n", (void *)va, (void *)pte, (void *)PTE2PA(pte));

    // recursive block
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000bfc:	4d85                	li	s11,1
    {
      uint64 child_pa = PTE2PA(pte); // get child pa to convert to a pagetable
      vmprint_recurse((pagetable_t)child_pa, depth + 1, va);
    80000bfe:	0015879b          	addiw	a5,a1,1
    80000c02:	f8f43423          	sd	a5,-120(s0)
      printf(".. ");
    80000c06:	00006b17          	auipc	s6,0x6
    80000c0a:	5aab0b13          	addi	s6,s6,1450 # 800071b0 <etext+0x1b0>
  for (int i = 0; i < 512; i++)
    80000c0e:	20000c13          	li	s8,512
    80000c12:	a029                	j	80000c1c <vmprint_recurse+0x54>
    80000c14:	0985                	addi	s3,s3,1 # 1001 <_entry-0x7fffefff>
    80000c16:	0a21                	addi	s4,s4,8
    80000c18:	07898163          	beq	s3,s8,80000c7a <vmprint_recurse+0xb2>
    pte_t pte = pagetable[i]; // store pte from page table
    80000c1c:	000a3903          	ld	s2,0(s4)
    if (!(pte & PTE_V))
    80000c20:	00197793          	andi	a5,s2,1
    80000c24:	dbe5                	beqz	a5,80000c14 <vmprint_recurse+0x4c>
    uint64 va = va_prefix | ((uint64)i << PXSHIFT(2 - depth));
    80000c26:	01999bb3          	sll	s7,s3,s9
    80000c2a:	01abebb3          	or	s7,s7,s10
    printf(" ");
    80000c2e:	00006517          	auipc	a0,0x6
    80000c32:	57a50513          	addi	a0,a0,1402 # 800071a8 <etext+0x1a8>
    80000c36:	4d8040ef          	jal	ra,8000510e <printf>
    for (int j = 0; j < depth; j++)
    80000c3a:	01505963          	blez	s5,80000c4c <vmprint_recurse+0x84>
    80000c3e:	4481                	li	s1,0
      printf(".. ");
    80000c40:	855a                	mv	a0,s6
    80000c42:	4cc040ef          	jal	ra,8000510e <printf>
    for (int j = 0; j < depth; j++)
    80000c46:	2485                	addiw	s1,s1,1
    80000c48:	fe9a9ce3          	bne	s5,s1,80000c40 <vmprint_recurse+0x78>
    printf("..%p: pte %p pa %p\n", (void *)va, (void *)pte, (void *)PTE2PA(pte));
    80000c4c:	00a95493          	srli	s1,s2,0xa
    80000c50:	04b2                	slli	s1,s1,0xc
    80000c52:	86a6                	mv	a3,s1
    80000c54:	864a                	mv	a2,s2
    80000c56:	85de                	mv	a1,s7
    80000c58:	00006517          	auipc	a0,0x6
    80000c5c:	56050513          	addi	a0,a0,1376 # 800071b8 <etext+0x1b8>
    80000c60:	4ae040ef          	jal	ra,8000510e <printf>
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    80000c64:	00f97913          	andi	s2,s2,15
    80000c68:	fbb916e3          	bne	s2,s11,80000c14 <vmprint_recurse+0x4c>
      vmprint_recurse((pagetable_t)child_pa, depth + 1, va);
    80000c6c:	865e                	mv	a2,s7
    80000c6e:	f8843583          	ld	a1,-120(s0)
    80000c72:	8526                	mv	a0,s1
    80000c74:	f55ff0ef          	jal	ra,80000bc8 <vmprint_recurse>
    80000c78:	bf71                	j	80000c14 <vmprint_recurse+0x4c>
    }
  }
}
    80000c7a:	70e6                	ld	ra,120(sp)
    80000c7c:	7446                	ld	s0,112(sp)
    80000c7e:	74a6                	ld	s1,104(sp)
    80000c80:	7906                	ld	s2,96(sp)
    80000c82:	69e6                	ld	s3,88(sp)
    80000c84:	6a46                	ld	s4,80(sp)
    80000c86:	6aa6                	ld	s5,72(sp)
    80000c88:	6b06                	ld	s6,64(sp)
    80000c8a:	7be2                	ld	s7,56(sp)
    80000c8c:	7c42                	ld	s8,48(sp)
    80000c8e:	7ca2                	ld	s9,40(sp)
    80000c90:	7d02                	ld	s10,32(sp)
    80000c92:	6de2                	ld	s11,24(sp)
    80000c94:	6109                	addi	sp,sp,128
    80000c96:	8082                	ret

0000000080000c98 <vmprint>:
{
    80000c98:	1101                	addi	sp,sp,-32
    80000c9a:	ec06                	sd	ra,24(sp)
    80000c9c:	e822                	sd	s0,16(sp)
    80000c9e:	e426                	sd	s1,8(sp)
    80000ca0:	1000                	addi	s0,sp,32
    80000ca2:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    80000ca4:	85aa                	mv	a1,a0
    80000ca6:	00006517          	auipc	a0,0x6
    80000caa:	52a50513          	addi	a0,a0,1322 # 800071d0 <etext+0x1d0>
    80000cae:	460040ef          	jal	ra,8000510e <printf>
  vmprint_recurse(pagetable, 0, 0); // start the recursion with depth 0
    80000cb2:	4601                	li	a2,0
    80000cb4:	4581                	li	a1,0
    80000cb6:	8526                	mv	a0,s1
    80000cb8:	f11ff0ef          	jal	ra,80000bc8 <vmprint_recurse>
}
    80000cbc:	60e2                	ld	ra,24(sp)
    80000cbe:	6442                	ld	s0,16(sp)
    80000cc0:	64a2                	ld	s1,8(sp)
    80000cc2:	6105                	addi	sp,sp,32
    80000cc4:	8082                	ret

0000000080000cc6 <pgpte>:

#ifdef LAB_PGTBL
pte_t *
pgpte(pagetable_t pagetable, uint64 va)
{
    80000cc6:	1141                	addi	sp,sp,-16
    80000cc8:	e406                	sd	ra,8(sp)
    80000cca:	e022                	sd	s0,0(sp)
    80000ccc:	0800                	addi	s0,sp,16
  return walk(pagetable, va, 0);
    80000cce:	4601                	li	a2,0
    80000cd0:	efaff0ef          	jal	ra,800003ca <walk>
}
    80000cd4:	60a2                	ld	ra,8(sp)
    80000cd6:	6402                	ld	s0,0(sp)
    80000cd8:	0141                	addi	sp,sp,16
    80000cda:	8082                	ret

0000000080000cdc <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000cdc:	7139                	addi	sp,sp,-64
    80000cde:	fc06                	sd	ra,56(sp)
    80000ce0:	f822                	sd	s0,48(sp)
    80000ce2:	f426                	sd	s1,40(sp)
    80000ce4:	f04a                	sd	s2,32(sp)
    80000ce6:	ec4e                	sd	s3,24(sp)
    80000ce8:	e852                	sd	s4,16(sp)
    80000cea:	e456                	sd	s5,8(sp)
    80000cec:	e05a                	sd	s6,0(sp)
    80000cee:	0080                	addi	s0,sp,64
    80000cf0:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80000cf2:	00007497          	auipc	s1,0x7
    80000cf6:	12e48493          	addi	s1,s1,302 # 80007e20 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000cfa:	8b26                	mv	s6,s1
    80000cfc:	00006a97          	auipc	s5,0x6
    80000d00:	304a8a93          	addi	s5,s5,772 # 80007000 <etext>
    80000d04:	04000937          	lui	s2,0x4000
    80000d08:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000d0a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d0c:	0000da17          	auipc	s4,0xd
    80000d10:	b14a0a13          	addi	s4,s4,-1260 # 8000d820 <tickslock>
    char *pa = kalloc();
    80000d14:	beaff0ef          	jal	ra,800000fe <kalloc>
    80000d18:	862a                	mv	a2,a0
    if(pa == 0)
    80000d1a:	c121                	beqz	a0,80000d5a <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80000d1c:	416485b3          	sub	a1,s1,s6
    80000d20:	858d                	srai	a1,a1,0x3
    80000d22:	000ab783          	ld	a5,0(s5)
    80000d26:	02f585b3          	mul	a1,a1,a5
    80000d2a:	2585                	addiw	a1,a1,1
    80000d2c:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000d30:	4719                	li	a4,6
    80000d32:	6685                	lui	a3,0x1
    80000d34:	40b905b3          	sub	a1,s2,a1
    80000d38:	854e                	mv	a0,s3
    80000d3a:	823ff0ef          	jal	ra,8000055c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d3e:	16848493          	addi	s1,s1,360
    80000d42:	fd4499e3          	bne	s1,s4,80000d14 <proc_mapstacks+0x38>
  }
}
    80000d46:	70e2                	ld	ra,56(sp)
    80000d48:	7442                	ld	s0,48(sp)
    80000d4a:	74a2                	ld	s1,40(sp)
    80000d4c:	7902                	ld	s2,32(sp)
    80000d4e:	69e2                	ld	s3,24(sp)
    80000d50:	6a42                	ld	s4,16(sp)
    80000d52:	6aa2                	ld	s5,8(sp)
    80000d54:	6b02                	ld	s6,0(sp)
    80000d56:	6121                	addi	sp,sp,64
    80000d58:	8082                	ret
      panic("kalloc");
    80000d5a:	00006517          	auipc	a0,0x6
    80000d5e:	48650513          	addi	a0,a0,1158 # 800071e0 <etext+0x1e0>
    80000d62:	660040ef          	jal	ra,800053c2 <panic>

0000000080000d66 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000d66:	7139                	addi	sp,sp,-64
    80000d68:	fc06                	sd	ra,56(sp)
    80000d6a:	f822                	sd	s0,48(sp)
    80000d6c:	f426                	sd	s1,40(sp)
    80000d6e:	f04a                	sd	s2,32(sp)
    80000d70:	ec4e                	sd	s3,24(sp)
    80000d72:	e852                	sd	s4,16(sp)
    80000d74:	e456                	sd	s5,8(sp)
    80000d76:	e05a                	sd	s6,0(sp)
    80000d78:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80000d7a:	00006597          	auipc	a1,0x6
    80000d7e:	46e58593          	addi	a1,a1,1134 # 800071e8 <etext+0x1e8>
    80000d82:	00007517          	auipc	a0,0x7
    80000d86:	c6e50513          	addi	a0,a0,-914 # 800079f0 <pid_lock>
    80000d8a:	0c9040ef          	jal	ra,80005652 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000d8e:	00006597          	auipc	a1,0x6
    80000d92:	46258593          	addi	a1,a1,1122 # 800071f0 <etext+0x1f0>
    80000d96:	00007517          	auipc	a0,0x7
    80000d9a:	c7250513          	addi	a0,a0,-910 # 80007a08 <wait_lock>
    80000d9e:	0b5040ef          	jal	ra,80005652 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000da2:	00007497          	auipc	s1,0x7
    80000da6:	07e48493          	addi	s1,s1,126 # 80007e20 <proc>
      initlock(&p->lock, "proc");
    80000daa:	00006b17          	auipc	s6,0x6
    80000dae:	456b0b13          	addi	s6,s6,1110 # 80007200 <etext+0x200>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000db2:	8aa6                	mv	s5,s1
    80000db4:	00006a17          	auipc	s4,0x6
    80000db8:	24ca0a13          	addi	s4,s4,588 # 80007000 <etext>
    80000dbc:	04000937          	lui	s2,0x4000
    80000dc0:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000dc2:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000dc4:	0000d997          	auipc	s3,0xd
    80000dc8:	a5c98993          	addi	s3,s3,-1444 # 8000d820 <tickslock>
      initlock(&p->lock, "proc");
    80000dcc:	85da                	mv	a1,s6
    80000dce:	8526                	mv	a0,s1
    80000dd0:	083040ef          	jal	ra,80005652 <initlock>
      p->state = UNUSED;
    80000dd4:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000dd8:	415487b3          	sub	a5,s1,s5
    80000ddc:	878d                	srai	a5,a5,0x3
    80000dde:	000a3703          	ld	a4,0(s4)
    80000de2:	02e787b3          	mul	a5,a5,a4
    80000de6:	2785                	addiw	a5,a5,1
    80000de8:	00d7979b          	slliw	a5,a5,0xd
    80000dec:	40f907b3          	sub	a5,s2,a5
    80000df0:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000df2:	16848493          	addi	s1,s1,360
    80000df6:	fd349be3          	bne	s1,s3,80000dcc <procinit+0x66>
  }
}
    80000dfa:	70e2                	ld	ra,56(sp)
    80000dfc:	7442                	ld	s0,48(sp)
    80000dfe:	74a2                	ld	s1,40(sp)
    80000e00:	7902                	ld	s2,32(sp)
    80000e02:	69e2                	ld	s3,24(sp)
    80000e04:	6a42                	ld	s4,16(sp)
    80000e06:	6aa2                	ld	s5,8(sp)
    80000e08:	6b02                	ld	s6,0(sp)
    80000e0a:	6121                	addi	sp,sp,64
    80000e0c:	8082                	ret

0000000080000e0e <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000e0e:	1141                	addi	sp,sp,-16
    80000e10:	e422                	sd	s0,8(sp)
    80000e12:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000e14:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000e16:	2501                	sext.w	a0,a0
    80000e18:	6422                	ld	s0,8(sp)
    80000e1a:	0141                	addi	sp,sp,16
    80000e1c:	8082                	ret

0000000080000e1e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000e1e:	1141                	addi	sp,sp,-16
    80000e20:	e422                	sd	s0,8(sp)
    80000e22:	0800                	addi	s0,sp,16
    80000e24:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000e26:	2781                	sext.w	a5,a5
    80000e28:	079e                	slli	a5,a5,0x7
  return c;
}
    80000e2a:	00007517          	auipc	a0,0x7
    80000e2e:	bf650513          	addi	a0,a0,-1034 # 80007a20 <cpus>
    80000e32:	953e                	add	a0,a0,a5
    80000e34:	6422                	ld	s0,8(sp)
    80000e36:	0141                	addi	sp,sp,16
    80000e38:	8082                	ret

0000000080000e3a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000e3a:	1101                	addi	sp,sp,-32
    80000e3c:	ec06                	sd	ra,24(sp)
    80000e3e:	e822                	sd	s0,16(sp)
    80000e40:	e426                	sd	s1,8(sp)
    80000e42:	1000                	addi	s0,sp,32
  push_off();
    80000e44:	04f040ef          	jal	ra,80005692 <push_off>
    80000e48:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000e4a:	2781                	sext.w	a5,a5
    80000e4c:	079e                	slli	a5,a5,0x7
    80000e4e:	00007717          	auipc	a4,0x7
    80000e52:	ba270713          	addi	a4,a4,-1118 # 800079f0 <pid_lock>
    80000e56:	97ba                	add	a5,a5,a4
    80000e58:	7b84                	ld	s1,48(a5)
  pop_off();
    80000e5a:	0bd040ef          	jal	ra,80005716 <pop_off>
  return p;
}
    80000e5e:	8526                	mv	a0,s1
    80000e60:	60e2                	ld	ra,24(sp)
    80000e62:	6442                	ld	s0,16(sp)
    80000e64:	64a2                	ld	s1,8(sp)
    80000e66:	6105                	addi	sp,sp,32
    80000e68:	8082                	ret

0000000080000e6a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000e6a:	1141                	addi	sp,sp,-16
    80000e6c:	e406                	sd	ra,8(sp)
    80000e6e:	e022                	sd	s0,0(sp)
    80000e70:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000e72:	fc9ff0ef          	jal	ra,80000e3a <myproc>
    80000e76:	0f5040ef          	jal	ra,8000576a <release>

  if (first) {
    80000e7a:	00007797          	auipc	a5,0x7
    80000e7e:	ab67a783          	lw	a5,-1354(a5) # 80007930 <first.1>
    80000e82:	e799                	bnez	a5,80000e90 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80000e84:	2bd000ef          	jal	ra,80001940 <usertrapret>
}
    80000e88:	60a2                	ld	ra,8(sp)
    80000e8a:	6402                	ld	s0,0(sp)
    80000e8c:	0141                	addi	sp,sp,16
    80000e8e:	8082                	ret
    fsinit(ROOTDEV);
    80000e90:	4505                	li	a0,1
    80000e92:	688010ef          	jal	ra,8000251a <fsinit>
    first = 0;
    80000e96:	00007797          	auipc	a5,0x7
    80000e9a:	a807ad23          	sw	zero,-1382(a5) # 80007930 <first.1>
    __sync_synchronize();
    80000e9e:	0ff0000f          	fence
    80000ea2:	b7cd                	j	80000e84 <forkret+0x1a>

0000000080000ea4 <allocpid>:
{
    80000ea4:	1101                	addi	sp,sp,-32
    80000ea6:	ec06                	sd	ra,24(sp)
    80000ea8:	e822                	sd	s0,16(sp)
    80000eaa:	e426                	sd	s1,8(sp)
    80000eac:	e04a                	sd	s2,0(sp)
    80000eae:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000eb0:	00007917          	auipc	s2,0x7
    80000eb4:	b4090913          	addi	s2,s2,-1216 # 800079f0 <pid_lock>
    80000eb8:	854a                	mv	a0,s2
    80000eba:	019040ef          	jal	ra,800056d2 <acquire>
  pid = nextpid;
    80000ebe:	00007797          	auipc	a5,0x7
    80000ec2:	a7678793          	addi	a5,a5,-1418 # 80007934 <nextpid>
    80000ec6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000ec8:	0014871b          	addiw	a4,s1,1
    80000ecc:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000ece:	854a                	mv	a0,s2
    80000ed0:	09b040ef          	jal	ra,8000576a <release>
}
    80000ed4:	8526                	mv	a0,s1
    80000ed6:	60e2                	ld	ra,24(sp)
    80000ed8:	6442                	ld	s0,16(sp)
    80000eda:	64a2                	ld	s1,8(sp)
    80000edc:	6902                	ld	s2,0(sp)
    80000ede:	6105                	addi	sp,sp,32
    80000ee0:	8082                	ret

0000000080000ee2 <proc_pagetable>:
{
    80000ee2:	1101                	addi	sp,sp,-32
    80000ee4:	ec06                	sd	ra,24(sp)
    80000ee6:	e822                	sd	s0,16(sp)
    80000ee8:	e426                	sd	s1,8(sp)
    80000eea:	e04a                	sd	s2,0(sp)
    80000eec:	1000                	addi	s0,sp,32
    80000eee:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000ef0:	81fff0ef          	jal	ra,8000070e <uvmcreate>
    80000ef4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000ef6:	cd05                	beqz	a0,80000f2e <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000ef8:	4729                	li	a4,10
    80000efa:	00005697          	auipc	a3,0x5
    80000efe:	10668693          	addi	a3,a3,262 # 80006000 <_trampoline>
    80000f02:	6605                	lui	a2,0x1
    80000f04:	040005b7          	lui	a1,0x4000
    80000f08:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f0a:	05b2                	slli	a1,a1,0xc
    80000f0c:	da0ff0ef          	jal	ra,800004ac <mappages>
    80000f10:	02054663          	bltz	a0,80000f3c <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000f14:	4719                	li	a4,6
    80000f16:	05893683          	ld	a3,88(s2)
    80000f1a:	6605                	lui	a2,0x1
    80000f1c:	020005b7          	lui	a1,0x2000
    80000f20:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000f22:	05b6                	slli	a1,a1,0xd
    80000f24:	8526                	mv	a0,s1
    80000f26:	d86ff0ef          	jal	ra,800004ac <mappages>
    80000f2a:	00054f63          	bltz	a0,80000f48 <proc_pagetable+0x66>
}
    80000f2e:	8526                	mv	a0,s1
    80000f30:	60e2                	ld	ra,24(sp)
    80000f32:	6442                	ld	s0,16(sp)
    80000f34:	64a2                	ld	s1,8(sp)
    80000f36:	6902                	ld	s2,0(sp)
    80000f38:	6105                	addi	sp,sp,32
    80000f3a:	8082                	ret
    uvmfree(pagetable, 0);
    80000f3c:	4581                	li	a1,0
    80000f3e:	8526                	mv	a0,s1
    80000f40:	991ff0ef          	jal	ra,800008d0 <uvmfree>
    return 0;
    80000f44:	4481                	li	s1,0
    80000f46:	b7e5                	j	80000f2e <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000f48:	4681                	li	a3,0
    80000f4a:	4605                	li	a2,1
    80000f4c:	040005b7          	lui	a1,0x4000
    80000f50:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f52:	05b2                	slli	a1,a1,0xc
    80000f54:	8526                	mv	a0,s1
    80000f56:	efcff0ef          	jal	ra,80000652 <uvmunmap>
    uvmfree(pagetable, 0);
    80000f5a:	4581                	li	a1,0
    80000f5c:	8526                	mv	a0,s1
    80000f5e:	973ff0ef          	jal	ra,800008d0 <uvmfree>
    return 0;
    80000f62:	4481                	li	s1,0
    80000f64:	b7e9                	j	80000f2e <proc_pagetable+0x4c>

0000000080000f66 <proc_freepagetable>:
{
    80000f66:	1101                	addi	sp,sp,-32
    80000f68:	ec06                	sd	ra,24(sp)
    80000f6a:	e822                	sd	s0,16(sp)
    80000f6c:	e426                	sd	s1,8(sp)
    80000f6e:	e04a                	sd	s2,0(sp)
    80000f70:	1000                	addi	s0,sp,32
    80000f72:	84aa                	mv	s1,a0
    80000f74:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000f76:	4681                	li	a3,0
    80000f78:	4605                	li	a2,1
    80000f7a:	040005b7          	lui	a1,0x4000
    80000f7e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f80:	05b2                	slli	a1,a1,0xc
    80000f82:	ed0ff0ef          	jal	ra,80000652 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000f86:	4681                	li	a3,0
    80000f88:	4605                	li	a2,1
    80000f8a:	020005b7          	lui	a1,0x2000
    80000f8e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000f90:	05b6                	slli	a1,a1,0xd
    80000f92:	8526                	mv	a0,s1
    80000f94:	ebeff0ef          	jal	ra,80000652 <uvmunmap>
  uvmfree(pagetable, sz);
    80000f98:	85ca                	mv	a1,s2
    80000f9a:	8526                	mv	a0,s1
    80000f9c:	935ff0ef          	jal	ra,800008d0 <uvmfree>
}
    80000fa0:	60e2                	ld	ra,24(sp)
    80000fa2:	6442                	ld	s0,16(sp)
    80000fa4:	64a2                	ld	s1,8(sp)
    80000fa6:	6902                	ld	s2,0(sp)
    80000fa8:	6105                	addi	sp,sp,32
    80000faa:	8082                	ret

0000000080000fac <freeproc>:
{
    80000fac:	1101                	addi	sp,sp,-32
    80000fae:	ec06                	sd	ra,24(sp)
    80000fb0:	e822                	sd	s0,16(sp)
    80000fb2:	e426                	sd	s1,8(sp)
    80000fb4:	1000                	addi	s0,sp,32
    80000fb6:	84aa                	mv	s1,a0
  if(p->trapframe)
    80000fb8:	6d28                	ld	a0,88(a0)
    80000fba:	c119                	beqz	a0,80000fc0 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80000fbc:	860ff0ef          	jal	ra,8000001c <kfree>
  p->trapframe = 0;
    80000fc0:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80000fc4:	68a8                	ld	a0,80(s1)
    80000fc6:	c501                	beqz	a0,80000fce <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80000fc8:	64ac                	ld	a1,72(s1)
    80000fca:	f9dff0ef          	jal	ra,80000f66 <proc_freepagetable>
  p->pagetable = 0;
    80000fce:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80000fd2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80000fd6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80000fda:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80000fde:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80000fe2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80000fe6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80000fea:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80000fee:	0004ac23          	sw	zero,24(s1)
}
    80000ff2:	60e2                	ld	ra,24(sp)
    80000ff4:	6442                	ld	s0,16(sp)
    80000ff6:	64a2                	ld	s1,8(sp)
    80000ff8:	6105                	addi	sp,sp,32
    80000ffa:	8082                	ret

0000000080000ffc <allocproc>:
{
    80000ffc:	1101                	addi	sp,sp,-32
    80000ffe:	ec06                	sd	ra,24(sp)
    80001000:	e822                	sd	s0,16(sp)
    80001002:	e426                	sd	s1,8(sp)
    80001004:	e04a                	sd	s2,0(sp)
    80001006:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001008:	00007497          	auipc	s1,0x7
    8000100c:	e1848493          	addi	s1,s1,-488 # 80007e20 <proc>
    80001010:	0000d917          	auipc	s2,0xd
    80001014:	81090913          	addi	s2,s2,-2032 # 8000d820 <tickslock>
    acquire(&p->lock);
    80001018:	8526                	mv	a0,s1
    8000101a:	6b8040ef          	jal	ra,800056d2 <acquire>
    if(p->state == UNUSED) {
    8000101e:	4c9c                	lw	a5,24(s1)
    80001020:	cb91                	beqz	a5,80001034 <allocproc+0x38>
      release(&p->lock);
    80001022:	8526                	mv	a0,s1
    80001024:	746040ef          	jal	ra,8000576a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001028:	16848493          	addi	s1,s1,360
    8000102c:	ff2496e3          	bne	s1,s2,80001018 <allocproc+0x1c>
  return 0;
    80001030:	4481                	li	s1,0
    80001032:	a089                	j	80001074 <allocproc+0x78>
  p->pid = allocpid();
    80001034:	e71ff0ef          	jal	ra,80000ea4 <allocpid>
    80001038:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000103a:	4785                	li	a5,1
    8000103c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000103e:	8c0ff0ef          	jal	ra,800000fe <kalloc>
    80001042:	892a                	mv	s2,a0
    80001044:	eca8                	sd	a0,88(s1)
    80001046:	cd15                	beqz	a0,80001082 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001048:	8526                	mv	a0,s1
    8000104a:	e99ff0ef          	jal	ra,80000ee2 <proc_pagetable>
    8000104e:	892a                	mv	s2,a0
    80001050:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001052:	c121                	beqz	a0,80001092 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001054:	07000613          	li	a2,112
    80001058:	4581                	li	a1,0
    8000105a:	06048513          	addi	a0,s1,96
    8000105e:	8f0ff0ef          	jal	ra,8000014e <memset>
  p->context.ra = (uint64)forkret;
    80001062:	00000797          	auipc	a5,0x0
    80001066:	e0878793          	addi	a5,a5,-504 # 80000e6a <forkret>
    8000106a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    8000106c:	60bc                	ld	a5,64(s1)
    8000106e:	6705                	lui	a4,0x1
    80001070:	97ba                	add	a5,a5,a4
    80001072:	f4bc                	sd	a5,104(s1)
}
    80001074:	8526                	mv	a0,s1
    80001076:	60e2                	ld	ra,24(sp)
    80001078:	6442                	ld	s0,16(sp)
    8000107a:	64a2                	ld	s1,8(sp)
    8000107c:	6902                	ld	s2,0(sp)
    8000107e:	6105                	addi	sp,sp,32
    80001080:	8082                	ret
    freeproc(p);
    80001082:	8526                	mv	a0,s1
    80001084:	f29ff0ef          	jal	ra,80000fac <freeproc>
    release(&p->lock);
    80001088:	8526                	mv	a0,s1
    8000108a:	6e0040ef          	jal	ra,8000576a <release>
    return 0;
    8000108e:	84ca                	mv	s1,s2
    80001090:	b7d5                	j	80001074 <allocproc+0x78>
    freeproc(p);
    80001092:	8526                	mv	a0,s1
    80001094:	f19ff0ef          	jal	ra,80000fac <freeproc>
    release(&p->lock);
    80001098:	8526                	mv	a0,s1
    8000109a:	6d0040ef          	jal	ra,8000576a <release>
    return 0;
    8000109e:	84ca                	mv	s1,s2
    800010a0:	bfd1                	j	80001074 <allocproc+0x78>

00000000800010a2 <userinit>:
{
    800010a2:	1101                	addi	sp,sp,-32
    800010a4:	ec06                	sd	ra,24(sp)
    800010a6:	e822                	sd	s0,16(sp)
    800010a8:	e426                	sd	s1,8(sp)
    800010aa:	1000                	addi	s0,sp,32
  p = allocproc();
    800010ac:	f51ff0ef          	jal	ra,80000ffc <allocproc>
    800010b0:	84aa                	mv	s1,a0
  initproc = p;
    800010b2:	00007797          	auipc	a5,0x7
    800010b6:	8ea7bf23          	sd	a0,-1794(a5) # 800079b0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    800010ba:	03400613          	li	a2,52
    800010be:	00007597          	auipc	a1,0x7
    800010c2:	88258593          	addi	a1,a1,-1918 # 80007940 <initcode>
    800010c6:	6928                	ld	a0,80(a0)
    800010c8:	e6cff0ef          	jal	ra,80000734 <uvmfirst>
  p->sz = PGSIZE;
    800010cc:	6785                	lui	a5,0x1
    800010ce:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800010d0:	6cb8                	ld	a4,88(s1)
    800010d2:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800010d6:	6cb8                	ld	a4,88(s1)
    800010d8:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800010da:	4641                	li	a2,16
    800010dc:	00006597          	auipc	a1,0x6
    800010e0:	12c58593          	addi	a1,a1,300 # 80007208 <etext+0x208>
    800010e4:	15848513          	addi	a0,s1,344
    800010e8:	9acff0ef          	jal	ra,80000294 <safestrcpy>
  p->cwd = namei("/");
    800010ec:	00006517          	auipc	a0,0x6
    800010f0:	12c50513          	addi	a0,a0,300 # 80007218 <etext+0x218>
    800010f4:	50d010ef          	jal	ra,80002e00 <namei>
    800010f8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800010fc:	478d                	li	a5,3
    800010fe:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001100:	8526                	mv	a0,s1
    80001102:	668040ef          	jal	ra,8000576a <release>
}
    80001106:	60e2                	ld	ra,24(sp)
    80001108:	6442                	ld	s0,16(sp)
    8000110a:	64a2                	ld	s1,8(sp)
    8000110c:	6105                	addi	sp,sp,32
    8000110e:	8082                	ret

0000000080001110 <growproc>:
{
    80001110:	1101                	addi	sp,sp,-32
    80001112:	ec06                	sd	ra,24(sp)
    80001114:	e822                	sd	s0,16(sp)
    80001116:	e426                	sd	s1,8(sp)
    80001118:	e04a                	sd	s2,0(sp)
    8000111a:	1000                	addi	s0,sp,32
    8000111c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000111e:	d1dff0ef          	jal	ra,80000e3a <myproc>
    80001122:	84aa                	mv	s1,a0
  sz = p->sz;
    80001124:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001126:	01204c63          	bgtz	s2,8000113e <growproc+0x2e>
  } else if(n < 0){
    8000112a:	02094463          	bltz	s2,80001152 <growproc+0x42>
  p->sz = sz;
    8000112e:	e4ac                	sd	a1,72(s1)
  return 0;
    80001130:	4501                	li	a0,0
}
    80001132:	60e2                	ld	ra,24(sp)
    80001134:	6442                	ld	s0,16(sp)
    80001136:	64a2                	ld	s1,8(sp)
    80001138:	6902                	ld	s2,0(sp)
    8000113a:	6105                	addi	sp,sp,32
    8000113c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    8000113e:	4691                	li	a3,4
    80001140:	00b90633          	add	a2,s2,a1
    80001144:	6928                	ld	a0,80(a0)
    80001146:	e90ff0ef          	jal	ra,800007d6 <uvmalloc>
    8000114a:	85aa                	mv	a1,a0
    8000114c:	f16d                	bnez	a0,8000112e <growproc+0x1e>
      return -1;
    8000114e:	557d                	li	a0,-1
    80001150:	b7cd                	j	80001132 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001152:	00b90633          	add	a2,s2,a1
    80001156:	6928                	ld	a0,80(a0)
    80001158:	e3aff0ef          	jal	ra,80000792 <uvmdealloc>
    8000115c:	85aa                	mv	a1,a0
    8000115e:	bfc1                	j	8000112e <growproc+0x1e>

0000000080001160 <fork>:
{
    80001160:	7139                	addi	sp,sp,-64
    80001162:	fc06                	sd	ra,56(sp)
    80001164:	f822                	sd	s0,48(sp)
    80001166:	f426                	sd	s1,40(sp)
    80001168:	f04a                	sd	s2,32(sp)
    8000116a:	ec4e                	sd	s3,24(sp)
    8000116c:	e852                	sd	s4,16(sp)
    8000116e:	e456                	sd	s5,8(sp)
    80001170:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001172:	cc9ff0ef          	jal	ra,80000e3a <myproc>
    80001176:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001178:	e85ff0ef          	jal	ra,80000ffc <allocproc>
    8000117c:	0e050663          	beqz	a0,80001268 <fork+0x108>
    80001180:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001182:	048ab603          	ld	a2,72(s5)
    80001186:	692c                	ld	a1,80(a0)
    80001188:	050ab503          	ld	a0,80(s5)
    8000118c:	f76ff0ef          	jal	ra,80000902 <uvmcopy>
    80001190:	04054863          	bltz	a0,800011e0 <fork+0x80>
  np->sz = p->sz;
    80001194:	048ab783          	ld	a5,72(s5)
    80001198:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    8000119c:	058ab683          	ld	a3,88(s5)
    800011a0:	87b6                	mv	a5,a3
    800011a2:	058a3703          	ld	a4,88(s4)
    800011a6:	12068693          	addi	a3,a3,288
    800011aa:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800011ae:	6788                	ld	a0,8(a5)
    800011b0:	6b8c                	ld	a1,16(a5)
    800011b2:	6f90                	ld	a2,24(a5)
    800011b4:	01073023          	sd	a6,0(a4)
    800011b8:	e708                	sd	a0,8(a4)
    800011ba:	eb0c                	sd	a1,16(a4)
    800011bc:	ef10                	sd	a2,24(a4)
    800011be:	02078793          	addi	a5,a5,32
    800011c2:	02070713          	addi	a4,a4,32
    800011c6:	fed792e3          	bne	a5,a3,800011aa <fork+0x4a>
  np->trapframe->a0 = 0;
    800011ca:	058a3783          	ld	a5,88(s4)
    800011ce:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800011d2:	0d0a8493          	addi	s1,s5,208
    800011d6:	0d0a0913          	addi	s2,s4,208
    800011da:	150a8993          	addi	s3,s5,336
    800011de:	a829                	j	800011f8 <fork+0x98>
    freeproc(np);
    800011e0:	8552                	mv	a0,s4
    800011e2:	dcbff0ef          	jal	ra,80000fac <freeproc>
    release(&np->lock);
    800011e6:	8552                	mv	a0,s4
    800011e8:	582040ef          	jal	ra,8000576a <release>
    return -1;
    800011ec:	597d                	li	s2,-1
    800011ee:	a09d                	j	80001254 <fork+0xf4>
  for(i = 0; i < NOFILE; i++)
    800011f0:	04a1                	addi	s1,s1,8
    800011f2:	0921                	addi	s2,s2,8
    800011f4:	01348963          	beq	s1,s3,80001206 <fork+0xa6>
    if(p->ofile[i])
    800011f8:	6088                	ld	a0,0(s1)
    800011fa:	d97d                	beqz	a0,800011f0 <fork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    800011fc:	1b2020ef          	jal	ra,800033ae <filedup>
    80001200:	00a93023          	sd	a0,0(s2)
    80001204:	b7f5                	j	800011f0 <fork+0x90>
  np->cwd = idup(p->cwd);
    80001206:	150ab503          	ld	a0,336(s5)
    8000120a:	508010ef          	jal	ra,80002712 <idup>
    8000120e:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001212:	4641                	li	a2,16
    80001214:	158a8593          	addi	a1,s5,344
    80001218:	158a0513          	addi	a0,s4,344
    8000121c:	878ff0ef          	jal	ra,80000294 <safestrcpy>
  pid = np->pid;
    80001220:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001224:	8552                	mv	a0,s4
    80001226:	544040ef          	jal	ra,8000576a <release>
  acquire(&wait_lock);
    8000122a:	00006497          	auipc	s1,0x6
    8000122e:	7de48493          	addi	s1,s1,2014 # 80007a08 <wait_lock>
    80001232:	8526                	mv	a0,s1
    80001234:	49e040ef          	jal	ra,800056d2 <acquire>
  np->parent = p;
    80001238:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    8000123c:	8526                	mv	a0,s1
    8000123e:	52c040ef          	jal	ra,8000576a <release>
  acquire(&np->lock);
    80001242:	8552                	mv	a0,s4
    80001244:	48e040ef          	jal	ra,800056d2 <acquire>
  np->state = RUNNABLE;
    80001248:	478d                	li	a5,3
    8000124a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    8000124e:	8552                	mv	a0,s4
    80001250:	51a040ef          	jal	ra,8000576a <release>
}
    80001254:	854a                	mv	a0,s2
    80001256:	70e2                	ld	ra,56(sp)
    80001258:	7442                	ld	s0,48(sp)
    8000125a:	74a2                	ld	s1,40(sp)
    8000125c:	7902                	ld	s2,32(sp)
    8000125e:	69e2                	ld	s3,24(sp)
    80001260:	6a42                	ld	s4,16(sp)
    80001262:	6aa2                	ld	s5,8(sp)
    80001264:	6121                	addi	sp,sp,64
    80001266:	8082                	ret
    return -1;
    80001268:	597d                	li	s2,-1
    8000126a:	b7ed                	j	80001254 <fork+0xf4>

000000008000126c <scheduler>:
{
    8000126c:	715d                	addi	sp,sp,-80
    8000126e:	e486                	sd	ra,72(sp)
    80001270:	e0a2                	sd	s0,64(sp)
    80001272:	fc26                	sd	s1,56(sp)
    80001274:	f84a                	sd	s2,48(sp)
    80001276:	f44e                	sd	s3,40(sp)
    80001278:	f052                	sd	s4,32(sp)
    8000127a:	ec56                	sd	s5,24(sp)
    8000127c:	e85a                	sd	s6,16(sp)
    8000127e:	e45e                	sd	s7,8(sp)
    80001280:	e062                	sd	s8,0(sp)
    80001282:	0880                	addi	s0,sp,80
    80001284:	8792                	mv	a5,tp
  int id = r_tp();
    80001286:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001288:	00779b13          	slli	s6,a5,0x7
    8000128c:	00006717          	auipc	a4,0x6
    80001290:	76470713          	addi	a4,a4,1892 # 800079f0 <pid_lock>
    80001294:	975a                	add	a4,a4,s6
    80001296:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000129a:	00006717          	auipc	a4,0x6
    8000129e:	78e70713          	addi	a4,a4,1934 # 80007a28 <cpus+0x8>
    800012a2:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    800012a4:	4c11                	li	s8,4
        c->proc = p;
    800012a6:	079e                	slli	a5,a5,0x7
    800012a8:	00006a17          	auipc	s4,0x6
    800012ac:	748a0a13          	addi	s4,s4,1864 # 800079f0 <pid_lock>
    800012b0:	9a3e                	add	s4,s4,a5
        found = 1;
    800012b2:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    800012b4:	0000c997          	auipc	s3,0xc
    800012b8:	56c98993          	addi	s3,s3,1388 # 8000d820 <tickslock>
    800012bc:	a0a9                	j	80001306 <scheduler+0x9a>
      release(&p->lock);
    800012be:	8526                	mv	a0,s1
    800012c0:	4aa040ef          	jal	ra,8000576a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800012c4:	16848493          	addi	s1,s1,360
    800012c8:	03348563          	beq	s1,s3,800012f2 <scheduler+0x86>
      acquire(&p->lock);
    800012cc:	8526                	mv	a0,s1
    800012ce:	404040ef          	jal	ra,800056d2 <acquire>
      if(p->state == RUNNABLE) {
    800012d2:	4c9c                	lw	a5,24(s1)
    800012d4:	ff2795e3          	bne	a5,s2,800012be <scheduler+0x52>
        p->state = RUNNING;
    800012d8:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    800012dc:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800012e0:	06048593          	addi	a1,s1,96
    800012e4:	855a                	mv	a0,s6
    800012e6:	5b4000ef          	jal	ra,8000189a <swtch>
        c->proc = 0;
    800012ea:	020a3823          	sd	zero,48(s4)
        found = 1;
    800012ee:	8ade                	mv	s5,s7
    800012f0:	b7f9                	j	800012be <scheduler+0x52>
    if(found == 0) {
    800012f2:	000a9a63          	bnez	s5,80001306 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012f6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800012fa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800012fe:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001302:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001306:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000130a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000130e:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001312:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001314:	00007497          	auipc	s1,0x7
    80001318:	b0c48493          	addi	s1,s1,-1268 # 80007e20 <proc>
      if(p->state == RUNNABLE) {
    8000131c:	490d                	li	s2,3
    8000131e:	b77d                	j	800012cc <scheduler+0x60>

0000000080001320 <sched>:
{
    80001320:	7179                	addi	sp,sp,-48
    80001322:	f406                	sd	ra,40(sp)
    80001324:	f022                	sd	s0,32(sp)
    80001326:	ec26                	sd	s1,24(sp)
    80001328:	e84a                	sd	s2,16(sp)
    8000132a:	e44e                	sd	s3,8(sp)
    8000132c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000132e:	b0dff0ef          	jal	ra,80000e3a <myproc>
    80001332:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001334:	334040ef          	jal	ra,80005668 <holding>
    80001338:	c92d                	beqz	a0,800013aa <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000133a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000133c:	2781                	sext.w	a5,a5
    8000133e:	079e                	slli	a5,a5,0x7
    80001340:	00006717          	auipc	a4,0x6
    80001344:	6b070713          	addi	a4,a4,1712 # 800079f0 <pid_lock>
    80001348:	97ba                	add	a5,a5,a4
    8000134a:	0a87a703          	lw	a4,168(a5)
    8000134e:	4785                	li	a5,1
    80001350:	06f71363          	bne	a4,a5,800013b6 <sched+0x96>
  if(p->state == RUNNING)
    80001354:	4c98                	lw	a4,24(s1)
    80001356:	4791                	li	a5,4
    80001358:	06f70563          	beq	a4,a5,800013c2 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000135c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001360:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001362:	e7b5                	bnez	a5,800013ce <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001364:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001366:	00006917          	auipc	s2,0x6
    8000136a:	68a90913          	addi	s2,s2,1674 # 800079f0 <pid_lock>
    8000136e:	2781                	sext.w	a5,a5
    80001370:	079e                	slli	a5,a5,0x7
    80001372:	97ca                	add	a5,a5,s2
    80001374:	0ac7a983          	lw	s3,172(a5)
    80001378:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000137a:	2781                	sext.w	a5,a5
    8000137c:	079e                	slli	a5,a5,0x7
    8000137e:	00006597          	auipc	a1,0x6
    80001382:	6aa58593          	addi	a1,a1,1706 # 80007a28 <cpus+0x8>
    80001386:	95be                	add	a1,a1,a5
    80001388:	06048513          	addi	a0,s1,96
    8000138c:	50e000ef          	jal	ra,8000189a <swtch>
    80001390:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001392:	2781                	sext.w	a5,a5
    80001394:	079e                	slli	a5,a5,0x7
    80001396:	993e                	add	s2,s2,a5
    80001398:	0b392623          	sw	s3,172(s2)
}
    8000139c:	70a2                	ld	ra,40(sp)
    8000139e:	7402                	ld	s0,32(sp)
    800013a0:	64e2                	ld	s1,24(sp)
    800013a2:	6942                	ld	s2,16(sp)
    800013a4:	69a2                	ld	s3,8(sp)
    800013a6:	6145                	addi	sp,sp,48
    800013a8:	8082                	ret
    panic("sched p->lock");
    800013aa:	00006517          	auipc	a0,0x6
    800013ae:	e7650513          	addi	a0,a0,-394 # 80007220 <etext+0x220>
    800013b2:	010040ef          	jal	ra,800053c2 <panic>
    panic("sched locks");
    800013b6:	00006517          	auipc	a0,0x6
    800013ba:	e7a50513          	addi	a0,a0,-390 # 80007230 <etext+0x230>
    800013be:	004040ef          	jal	ra,800053c2 <panic>
    panic("sched running");
    800013c2:	00006517          	auipc	a0,0x6
    800013c6:	e7e50513          	addi	a0,a0,-386 # 80007240 <etext+0x240>
    800013ca:	7f9030ef          	jal	ra,800053c2 <panic>
    panic("sched interruptible");
    800013ce:	00006517          	auipc	a0,0x6
    800013d2:	e8250513          	addi	a0,a0,-382 # 80007250 <etext+0x250>
    800013d6:	7ed030ef          	jal	ra,800053c2 <panic>

00000000800013da <yield>:
{
    800013da:	1101                	addi	sp,sp,-32
    800013dc:	ec06                	sd	ra,24(sp)
    800013de:	e822                	sd	s0,16(sp)
    800013e0:	e426                	sd	s1,8(sp)
    800013e2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800013e4:	a57ff0ef          	jal	ra,80000e3a <myproc>
    800013e8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800013ea:	2e8040ef          	jal	ra,800056d2 <acquire>
  p->state = RUNNABLE;
    800013ee:	478d                	li	a5,3
    800013f0:	cc9c                	sw	a5,24(s1)
  sched();
    800013f2:	f2fff0ef          	jal	ra,80001320 <sched>
  release(&p->lock);
    800013f6:	8526                	mv	a0,s1
    800013f8:	372040ef          	jal	ra,8000576a <release>
}
    800013fc:	60e2                	ld	ra,24(sp)
    800013fe:	6442                	ld	s0,16(sp)
    80001400:	64a2                	ld	s1,8(sp)
    80001402:	6105                	addi	sp,sp,32
    80001404:	8082                	ret

0000000080001406 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001406:	7179                	addi	sp,sp,-48
    80001408:	f406                	sd	ra,40(sp)
    8000140a:	f022                	sd	s0,32(sp)
    8000140c:	ec26                	sd	s1,24(sp)
    8000140e:	e84a                	sd	s2,16(sp)
    80001410:	e44e                	sd	s3,8(sp)
    80001412:	1800                	addi	s0,sp,48
    80001414:	89aa                	mv	s3,a0
    80001416:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001418:	a23ff0ef          	jal	ra,80000e3a <myproc>
    8000141c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000141e:	2b4040ef          	jal	ra,800056d2 <acquire>
  release(lk);
    80001422:	854a                	mv	a0,s2
    80001424:	346040ef          	jal	ra,8000576a <release>

  // Go to sleep.
  p->chan = chan;
    80001428:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000142c:	4789                	li	a5,2
    8000142e:	cc9c                	sw	a5,24(s1)

  sched();
    80001430:	ef1ff0ef          	jal	ra,80001320 <sched>

  // Tidy up.
  p->chan = 0;
    80001434:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001438:	8526                	mv	a0,s1
    8000143a:	330040ef          	jal	ra,8000576a <release>
  acquire(lk);
    8000143e:	854a                	mv	a0,s2
    80001440:	292040ef          	jal	ra,800056d2 <acquire>
}
    80001444:	70a2                	ld	ra,40(sp)
    80001446:	7402                	ld	s0,32(sp)
    80001448:	64e2                	ld	s1,24(sp)
    8000144a:	6942                	ld	s2,16(sp)
    8000144c:	69a2                	ld	s3,8(sp)
    8000144e:	6145                	addi	sp,sp,48
    80001450:	8082                	ret

0000000080001452 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001452:	7139                	addi	sp,sp,-64
    80001454:	fc06                	sd	ra,56(sp)
    80001456:	f822                	sd	s0,48(sp)
    80001458:	f426                	sd	s1,40(sp)
    8000145a:	f04a                	sd	s2,32(sp)
    8000145c:	ec4e                	sd	s3,24(sp)
    8000145e:	e852                	sd	s4,16(sp)
    80001460:	e456                	sd	s5,8(sp)
    80001462:	0080                	addi	s0,sp,64
    80001464:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001466:	00007497          	auipc	s1,0x7
    8000146a:	9ba48493          	addi	s1,s1,-1606 # 80007e20 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000146e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001470:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001472:	0000c917          	auipc	s2,0xc
    80001476:	3ae90913          	addi	s2,s2,942 # 8000d820 <tickslock>
    8000147a:	a801                	j	8000148a <wakeup+0x38>
      }
      release(&p->lock);
    8000147c:	8526                	mv	a0,s1
    8000147e:	2ec040ef          	jal	ra,8000576a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001482:	16848493          	addi	s1,s1,360
    80001486:	03248263          	beq	s1,s2,800014aa <wakeup+0x58>
    if(p != myproc()){
    8000148a:	9b1ff0ef          	jal	ra,80000e3a <myproc>
    8000148e:	fea48ae3          	beq	s1,a0,80001482 <wakeup+0x30>
      acquire(&p->lock);
    80001492:	8526                	mv	a0,s1
    80001494:	23e040ef          	jal	ra,800056d2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001498:	4c9c                	lw	a5,24(s1)
    8000149a:	ff3791e3          	bne	a5,s3,8000147c <wakeup+0x2a>
    8000149e:	709c                	ld	a5,32(s1)
    800014a0:	fd479ee3          	bne	a5,s4,8000147c <wakeup+0x2a>
        p->state = RUNNABLE;
    800014a4:	0154ac23          	sw	s5,24(s1)
    800014a8:	bfd1                	j	8000147c <wakeup+0x2a>
    }
  }
}
    800014aa:	70e2                	ld	ra,56(sp)
    800014ac:	7442                	ld	s0,48(sp)
    800014ae:	74a2                	ld	s1,40(sp)
    800014b0:	7902                	ld	s2,32(sp)
    800014b2:	69e2                	ld	s3,24(sp)
    800014b4:	6a42                	ld	s4,16(sp)
    800014b6:	6aa2                	ld	s5,8(sp)
    800014b8:	6121                	addi	sp,sp,64
    800014ba:	8082                	ret

00000000800014bc <reparent>:
{
    800014bc:	7179                	addi	sp,sp,-48
    800014be:	f406                	sd	ra,40(sp)
    800014c0:	f022                	sd	s0,32(sp)
    800014c2:	ec26                	sd	s1,24(sp)
    800014c4:	e84a                	sd	s2,16(sp)
    800014c6:	e44e                	sd	s3,8(sp)
    800014c8:	e052                	sd	s4,0(sp)
    800014ca:	1800                	addi	s0,sp,48
    800014cc:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800014ce:	00007497          	auipc	s1,0x7
    800014d2:	95248493          	addi	s1,s1,-1710 # 80007e20 <proc>
      pp->parent = initproc;
    800014d6:	00006a17          	auipc	s4,0x6
    800014da:	4daa0a13          	addi	s4,s4,1242 # 800079b0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800014de:	0000c997          	auipc	s3,0xc
    800014e2:	34298993          	addi	s3,s3,834 # 8000d820 <tickslock>
    800014e6:	a029                	j	800014f0 <reparent+0x34>
    800014e8:	16848493          	addi	s1,s1,360
    800014ec:	01348b63          	beq	s1,s3,80001502 <reparent+0x46>
    if(pp->parent == p){
    800014f0:	7c9c                	ld	a5,56(s1)
    800014f2:	ff279be3          	bne	a5,s2,800014e8 <reparent+0x2c>
      pp->parent = initproc;
    800014f6:	000a3503          	ld	a0,0(s4)
    800014fa:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800014fc:	f57ff0ef          	jal	ra,80001452 <wakeup>
    80001500:	b7e5                	j	800014e8 <reparent+0x2c>
}
    80001502:	70a2                	ld	ra,40(sp)
    80001504:	7402                	ld	s0,32(sp)
    80001506:	64e2                	ld	s1,24(sp)
    80001508:	6942                	ld	s2,16(sp)
    8000150a:	69a2                	ld	s3,8(sp)
    8000150c:	6a02                	ld	s4,0(sp)
    8000150e:	6145                	addi	sp,sp,48
    80001510:	8082                	ret

0000000080001512 <exit>:
{
    80001512:	7179                	addi	sp,sp,-48
    80001514:	f406                	sd	ra,40(sp)
    80001516:	f022                	sd	s0,32(sp)
    80001518:	ec26                	sd	s1,24(sp)
    8000151a:	e84a                	sd	s2,16(sp)
    8000151c:	e44e                	sd	s3,8(sp)
    8000151e:	e052                	sd	s4,0(sp)
    80001520:	1800                	addi	s0,sp,48
    80001522:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001524:	917ff0ef          	jal	ra,80000e3a <myproc>
    80001528:	89aa                	mv	s3,a0
  if(p == initproc)
    8000152a:	00006797          	auipc	a5,0x6
    8000152e:	4867b783          	ld	a5,1158(a5) # 800079b0 <initproc>
    80001532:	0d050493          	addi	s1,a0,208
    80001536:	15050913          	addi	s2,a0,336
    8000153a:	00a79f63          	bne	a5,a0,80001558 <exit+0x46>
    panic("init exiting");
    8000153e:	00006517          	auipc	a0,0x6
    80001542:	d2a50513          	addi	a0,a0,-726 # 80007268 <etext+0x268>
    80001546:	67d030ef          	jal	ra,800053c2 <panic>
      fileclose(f);
    8000154a:	6ab010ef          	jal	ra,800033f4 <fileclose>
      p->ofile[fd] = 0;
    8000154e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001552:	04a1                	addi	s1,s1,8
    80001554:	01248563          	beq	s1,s2,8000155e <exit+0x4c>
    if(p->ofile[fd]){
    80001558:	6088                	ld	a0,0(s1)
    8000155a:	f965                	bnez	a0,8000154a <exit+0x38>
    8000155c:	bfdd                	j	80001552 <exit+0x40>
  begin_op();
    8000155e:	27f010ef          	jal	ra,80002fdc <begin_op>
  iput(p->cwd);
    80001562:	1509b503          	ld	a0,336(s3)
    80001566:	360010ef          	jal	ra,800028c6 <iput>
  end_op();
    8000156a:	2e1010ef          	jal	ra,8000304a <end_op>
  p->cwd = 0;
    8000156e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80001572:	00006497          	auipc	s1,0x6
    80001576:	49648493          	addi	s1,s1,1174 # 80007a08 <wait_lock>
    8000157a:	8526                	mv	a0,s1
    8000157c:	156040ef          	jal	ra,800056d2 <acquire>
  reparent(p);
    80001580:	854e                	mv	a0,s3
    80001582:	f3bff0ef          	jal	ra,800014bc <reparent>
  wakeup(p->parent);
    80001586:	0389b503          	ld	a0,56(s3)
    8000158a:	ec9ff0ef          	jal	ra,80001452 <wakeup>
  acquire(&p->lock);
    8000158e:	854e                	mv	a0,s3
    80001590:	142040ef          	jal	ra,800056d2 <acquire>
  p->xstate = status;
    80001594:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001598:	4795                	li	a5,5
    8000159a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000159e:	8526                	mv	a0,s1
    800015a0:	1ca040ef          	jal	ra,8000576a <release>
  sched();
    800015a4:	d7dff0ef          	jal	ra,80001320 <sched>
  panic("zombie exit");
    800015a8:	00006517          	auipc	a0,0x6
    800015ac:	cd050513          	addi	a0,a0,-816 # 80007278 <etext+0x278>
    800015b0:	613030ef          	jal	ra,800053c2 <panic>

00000000800015b4 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800015b4:	7179                	addi	sp,sp,-48
    800015b6:	f406                	sd	ra,40(sp)
    800015b8:	f022                	sd	s0,32(sp)
    800015ba:	ec26                	sd	s1,24(sp)
    800015bc:	e84a                	sd	s2,16(sp)
    800015be:	e44e                	sd	s3,8(sp)
    800015c0:	1800                	addi	s0,sp,48
    800015c2:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800015c4:	00007497          	auipc	s1,0x7
    800015c8:	85c48493          	addi	s1,s1,-1956 # 80007e20 <proc>
    800015cc:	0000c997          	auipc	s3,0xc
    800015d0:	25498993          	addi	s3,s3,596 # 8000d820 <tickslock>
    acquire(&p->lock);
    800015d4:	8526                	mv	a0,s1
    800015d6:	0fc040ef          	jal	ra,800056d2 <acquire>
    if(p->pid == pid){
    800015da:	589c                	lw	a5,48(s1)
    800015dc:	01278b63          	beq	a5,s2,800015f2 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800015e0:	8526                	mv	a0,s1
    800015e2:	188040ef          	jal	ra,8000576a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800015e6:	16848493          	addi	s1,s1,360
    800015ea:	ff3495e3          	bne	s1,s3,800015d4 <kill+0x20>
  }
  return -1;
    800015ee:	557d                	li	a0,-1
    800015f0:	a819                	j	80001606 <kill+0x52>
      p->killed = 1;
    800015f2:	4785                	li	a5,1
    800015f4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800015f6:	4c98                	lw	a4,24(s1)
    800015f8:	4789                	li	a5,2
    800015fa:	00f70d63          	beq	a4,a5,80001614 <kill+0x60>
      release(&p->lock);
    800015fe:	8526                	mv	a0,s1
    80001600:	16a040ef          	jal	ra,8000576a <release>
      return 0;
    80001604:	4501                	li	a0,0
}
    80001606:	70a2                	ld	ra,40(sp)
    80001608:	7402                	ld	s0,32(sp)
    8000160a:	64e2                	ld	s1,24(sp)
    8000160c:	6942                	ld	s2,16(sp)
    8000160e:	69a2                	ld	s3,8(sp)
    80001610:	6145                	addi	sp,sp,48
    80001612:	8082                	ret
        p->state = RUNNABLE;
    80001614:	478d                	li	a5,3
    80001616:	cc9c                	sw	a5,24(s1)
    80001618:	b7dd                	j	800015fe <kill+0x4a>

000000008000161a <setkilled>:

void
setkilled(struct proc *p)
{
    8000161a:	1101                	addi	sp,sp,-32
    8000161c:	ec06                	sd	ra,24(sp)
    8000161e:	e822                	sd	s0,16(sp)
    80001620:	e426                	sd	s1,8(sp)
    80001622:	1000                	addi	s0,sp,32
    80001624:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001626:	0ac040ef          	jal	ra,800056d2 <acquire>
  p->killed = 1;
    8000162a:	4785                	li	a5,1
    8000162c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000162e:	8526                	mv	a0,s1
    80001630:	13a040ef          	jal	ra,8000576a <release>
}
    80001634:	60e2                	ld	ra,24(sp)
    80001636:	6442                	ld	s0,16(sp)
    80001638:	64a2                	ld	s1,8(sp)
    8000163a:	6105                	addi	sp,sp,32
    8000163c:	8082                	ret

000000008000163e <killed>:

int
killed(struct proc *p)
{
    8000163e:	1101                	addi	sp,sp,-32
    80001640:	ec06                	sd	ra,24(sp)
    80001642:	e822                	sd	s0,16(sp)
    80001644:	e426                	sd	s1,8(sp)
    80001646:	e04a                	sd	s2,0(sp)
    80001648:	1000                	addi	s0,sp,32
    8000164a:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000164c:	086040ef          	jal	ra,800056d2 <acquire>
  k = p->killed;
    80001650:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001654:	8526                	mv	a0,s1
    80001656:	114040ef          	jal	ra,8000576a <release>
  return k;
}
    8000165a:	854a                	mv	a0,s2
    8000165c:	60e2                	ld	ra,24(sp)
    8000165e:	6442                	ld	s0,16(sp)
    80001660:	64a2                	ld	s1,8(sp)
    80001662:	6902                	ld	s2,0(sp)
    80001664:	6105                	addi	sp,sp,32
    80001666:	8082                	ret

0000000080001668 <wait>:
{
    80001668:	715d                	addi	sp,sp,-80
    8000166a:	e486                	sd	ra,72(sp)
    8000166c:	e0a2                	sd	s0,64(sp)
    8000166e:	fc26                	sd	s1,56(sp)
    80001670:	f84a                	sd	s2,48(sp)
    80001672:	f44e                	sd	s3,40(sp)
    80001674:	f052                	sd	s4,32(sp)
    80001676:	ec56                	sd	s5,24(sp)
    80001678:	e85a                	sd	s6,16(sp)
    8000167a:	e45e                	sd	s7,8(sp)
    8000167c:	e062                	sd	s8,0(sp)
    8000167e:	0880                	addi	s0,sp,80
    80001680:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001682:	fb8ff0ef          	jal	ra,80000e3a <myproc>
    80001686:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001688:	00006517          	auipc	a0,0x6
    8000168c:	38050513          	addi	a0,a0,896 # 80007a08 <wait_lock>
    80001690:	042040ef          	jal	ra,800056d2 <acquire>
    havekids = 0;
    80001694:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001696:	4a15                	li	s4,5
        havekids = 1;
    80001698:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000169a:	0000c997          	auipc	s3,0xc
    8000169e:	18698993          	addi	s3,s3,390 # 8000d820 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800016a2:	00006c17          	auipc	s8,0x6
    800016a6:	366c0c13          	addi	s8,s8,870 # 80007a08 <wait_lock>
    havekids = 0;
    800016aa:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800016ac:	00006497          	auipc	s1,0x6
    800016b0:	77448493          	addi	s1,s1,1908 # 80007e20 <proc>
    800016b4:	a899                	j	8000170a <wait+0xa2>
          pid = pp->pid;
    800016b6:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800016ba:	000b0c63          	beqz	s6,800016d2 <wait+0x6a>
    800016be:	4691                	li	a3,4
    800016c0:	02c48613          	addi	a2,s1,44
    800016c4:	85da                	mv	a1,s6
    800016c6:	05093503          	ld	a0,80(s2)
    800016ca:	b14ff0ef          	jal	ra,800009de <copyout>
    800016ce:	00054f63          	bltz	a0,800016ec <wait+0x84>
          freeproc(pp);
    800016d2:	8526                	mv	a0,s1
    800016d4:	8d9ff0ef          	jal	ra,80000fac <freeproc>
          release(&pp->lock);
    800016d8:	8526                	mv	a0,s1
    800016da:	090040ef          	jal	ra,8000576a <release>
          release(&wait_lock);
    800016de:	00006517          	auipc	a0,0x6
    800016e2:	32a50513          	addi	a0,a0,810 # 80007a08 <wait_lock>
    800016e6:	084040ef          	jal	ra,8000576a <release>
          return pid;
    800016ea:	a891                	j	8000173e <wait+0xd6>
            release(&pp->lock);
    800016ec:	8526                	mv	a0,s1
    800016ee:	07c040ef          	jal	ra,8000576a <release>
            release(&wait_lock);
    800016f2:	00006517          	auipc	a0,0x6
    800016f6:	31650513          	addi	a0,a0,790 # 80007a08 <wait_lock>
    800016fa:	070040ef          	jal	ra,8000576a <release>
            return -1;
    800016fe:	59fd                	li	s3,-1
    80001700:	a83d                	j	8000173e <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001702:	16848493          	addi	s1,s1,360
    80001706:	03348063          	beq	s1,s3,80001726 <wait+0xbe>
      if(pp->parent == p){
    8000170a:	7c9c                	ld	a5,56(s1)
    8000170c:	ff279be3          	bne	a5,s2,80001702 <wait+0x9a>
        acquire(&pp->lock);
    80001710:	8526                	mv	a0,s1
    80001712:	7c1030ef          	jal	ra,800056d2 <acquire>
        if(pp->state == ZOMBIE){
    80001716:	4c9c                	lw	a5,24(s1)
    80001718:	f9478fe3          	beq	a5,s4,800016b6 <wait+0x4e>
        release(&pp->lock);
    8000171c:	8526                	mv	a0,s1
    8000171e:	04c040ef          	jal	ra,8000576a <release>
        havekids = 1;
    80001722:	8756                	mv	a4,s5
    80001724:	bff9                	j	80001702 <wait+0x9a>
    if(!havekids || killed(p)){
    80001726:	c709                	beqz	a4,80001730 <wait+0xc8>
    80001728:	854a                	mv	a0,s2
    8000172a:	f15ff0ef          	jal	ra,8000163e <killed>
    8000172e:	c50d                	beqz	a0,80001758 <wait+0xf0>
      release(&wait_lock);
    80001730:	00006517          	auipc	a0,0x6
    80001734:	2d850513          	addi	a0,a0,728 # 80007a08 <wait_lock>
    80001738:	032040ef          	jal	ra,8000576a <release>
      return -1;
    8000173c:	59fd                	li	s3,-1
}
    8000173e:	854e                	mv	a0,s3
    80001740:	60a6                	ld	ra,72(sp)
    80001742:	6406                	ld	s0,64(sp)
    80001744:	74e2                	ld	s1,56(sp)
    80001746:	7942                	ld	s2,48(sp)
    80001748:	79a2                	ld	s3,40(sp)
    8000174a:	7a02                	ld	s4,32(sp)
    8000174c:	6ae2                	ld	s5,24(sp)
    8000174e:	6b42                	ld	s6,16(sp)
    80001750:	6ba2                	ld	s7,8(sp)
    80001752:	6c02                	ld	s8,0(sp)
    80001754:	6161                	addi	sp,sp,80
    80001756:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001758:	85e2                	mv	a1,s8
    8000175a:	854a                	mv	a0,s2
    8000175c:	cabff0ef          	jal	ra,80001406 <sleep>
    havekids = 0;
    80001760:	b7a9                	j	800016aa <wait+0x42>

0000000080001762 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001762:	7179                	addi	sp,sp,-48
    80001764:	f406                	sd	ra,40(sp)
    80001766:	f022                	sd	s0,32(sp)
    80001768:	ec26                	sd	s1,24(sp)
    8000176a:	e84a                	sd	s2,16(sp)
    8000176c:	e44e                	sd	s3,8(sp)
    8000176e:	e052                	sd	s4,0(sp)
    80001770:	1800                	addi	s0,sp,48
    80001772:	84aa                	mv	s1,a0
    80001774:	892e                	mv	s2,a1
    80001776:	89b2                	mv	s3,a2
    80001778:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000177a:	ec0ff0ef          	jal	ra,80000e3a <myproc>
  if(user_dst){
    8000177e:	cc99                	beqz	s1,8000179c <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80001780:	86d2                	mv	a3,s4
    80001782:	864e                	mv	a2,s3
    80001784:	85ca                	mv	a1,s2
    80001786:	6928                	ld	a0,80(a0)
    80001788:	a56ff0ef          	jal	ra,800009de <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000178c:	70a2                	ld	ra,40(sp)
    8000178e:	7402                	ld	s0,32(sp)
    80001790:	64e2                	ld	s1,24(sp)
    80001792:	6942                	ld	s2,16(sp)
    80001794:	69a2                	ld	s3,8(sp)
    80001796:	6a02                	ld	s4,0(sp)
    80001798:	6145                	addi	sp,sp,48
    8000179a:	8082                	ret
    memmove((char *)dst, src, len);
    8000179c:	000a061b          	sext.w	a2,s4
    800017a0:	85ce                	mv	a1,s3
    800017a2:	854a                	mv	a0,s2
    800017a4:	a07fe0ef          	jal	ra,800001aa <memmove>
    return 0;
    800017a8:	8526                	mv	a0,s1
    800017aa:	b7cd                	j	8000178c <either_copyout+0x2a>

00000000800017ac <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800017ac:	7179                	addi	sp,sp,-48
    800017ae:	f406                	sd	ra,40(sp)
    800017b0:	f022                	sd	s0,32(sp)
    800017b2:	ec26                	sd	s1,24(sp)
    800017b4:	e84a                	sd	s2,16(sp)
    800017b6:	e44e                	sd	s3,8(sp)
    800017b8:	e052                	sd	s4,0(sp)
    800017ba:	1800                	addi	s0,sp,48
    800017bc:	892a                	mv	s2,a0
    800017be:	84ae                	mv	s1,a1
    800017c0:	89b2                	mv	s3,a2
    800017c2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800017c4:	e76ff0ef          	jal	ra,80000e3a <myproc>
  if(user_src){
    800017c8:	cc99                	beqz	s1,800017e6 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800017ca:	86d2                	mv	a3,s4
    800017cc:	864e                	mv	a2,s3
    800017ce:	85ca                	mv	a1,s2
    800017d0:	6928                	ld	a0,80(a0)
    800017d2:	ac4ff0ef          	jal	ra,80000a96 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800017d6:	70a2                	ld	ra,40(sp)
    800017d8:	7402                	ld	s0,32(sp)
    800017da:	64e2                	ld	s1,24(sp)
    800017dc:	6942                	ld	s2,16(sp)
    800017de:	69a2                	ld	s3,8(sp)
    800017e0:	6a02                	ld	s4,0(sp)
    800017e2:	6145                	addi	sp,sp,48
    800017e4:	8082                	ret
    memmove(dst, (char*)src, len);
    800017e6:	000a061b          	sext.w	a2,s4
    800017ea:	85ce                	mv	a1,s3
    800017ec:	854a                	mv	a0,s2
    800017ee:	9bdfe0ef          	jal	ra,800001aa <memmove>
    return 0;
    800017f2:	8526                	mv	a0,s1
    800017f4:	b7cd                	j	800017d6 <either_copyin+0x2a>

00000000800017f6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800017f6:	715d                	addi	sp,sp,-80
    800017f8:	e486                	sd	ra,72(sp)
    800017fa:	e0a2                	sd	s0,64(sp)
    800017fc:	fc26                	sd	s1,56(sp)
    800017fe:	f84a                	sd	s2,48(sp)
    80001800:	f44e                	sd	s3,40(sp)
    80001802:	f052                	sd	s4,32(sp)
    80001804:	ec56                	sd	s5,24(sp)
    80001806:	e85a                	sd	s6,16(sp)
    80001808:	e45e                	sd	s7,8(sp)
    8000180a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000180c:	00006517          	auipc	a0,0x6
    80001810:	83c50513          	addi	a0,a0,-1988 # 80007048 <etext+0x48>
    80001814:	0fb030ef          	jal	ra,8000510e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001818:	00006497          	auipc	s1,0x6
    8000181c:	76048493          	addi	s1,s1,1888 # 80007f78 <proc+0x158>
    80001820:	0000c917          	auipc	s2,0xc
    80001824:	15890913          	addi	s2,s2,344 # 8000d978 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001828:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000182a:	00006997          	auipc	s3,0x6
    8000182e:	a5e98993          	addi	s3,s3,-1442 # 80007288 <etext+0x288>
    printf("%d %s %s", p->pid, state, p->name);
    80001832:	00006a97          	auipc	s5,0x6
    80001836:	a5ea8a93          	addi	s5,s5,-1442 # 80007290 <etext+0x290>
    printf("\n");
    8000183a:	00006a17          	auipc	s4,0x6
    8000183e:	80ea0a13          	addi	s4,s4,-2034 # 80007048 <etext+0x48>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001842:	00006b97          	auipc	s7,0x6
    80001846:	a8eb8b93          	addi	s7,s7,-1394 # 800072d0 <states.0>
    8000184a:	a829                	j	80001864 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000184c:	ed86a583          	lw	a1,-296(a3)
    80001850:	8556                	mv	a0,s5
    80001852:	0bd030ef          	jal	ra,8000510e <printf>
    printf("\n");
    80001856:	8552                	mv	a0,s4
    80001858:	0b7030ef          	jal	ra,8000510e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000185c:	16848493          	addi	s1,s1,360
    80001860:	03248263          	beq	s1,s2,80001884 <procdump+0x8e>
    if(p->state == UNUSED)
    80001864:	86a6                	mv	a3,s1
    80001866:	ec04a783          	lw	a5,-320(s1)
    8000186a:	dbed                	beqz	a5,8000185c <procdump+0x66>
      state = "???";
    8000186c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000186e:	fcfb6fe3          	bltu	s6,a5,8000184c <procdump+0x56>
    80001872:	02079713          	slli	a4,a5,0x20
    80001876:	01d75793          	srli	a5,a4,0x1d
    8000187a:	97de                	add	a5,a5,s7
    8000187c:	6390                	ld	a2,0(a5)
    8000187e:	f679                	bnez	a2,8000184c <procdump+0x56>
      state = "???";
    80001880:	864e                	mv	a2,s3
    80001882:	b7e9                	j	8000184c <procdump+0x56>
  }
}
    80001884:	60a6                	ld	ra,72(sp)
    80001886:	6406                	ld	s0,64(sp)
    80001888:	74e2                	ld	s1,56(sp)
    8000188a:	7942                	ld	s2,48(sp)
    8000188c:	79a2                	ld	s3,40(sp)
    8000188e:	7a02                	ld	s4,32(sp)
    80001890:	6ae2                	ld	s5,24(sp)
    80001892:	6b42                	ld	s6,16(sp)
    80001894:	6ba2                	ld	s7,8(sp)
    80001896:	6161                	addi	sp,sp,80
    80001898:	8082                	ret

000000008000189a <swtch>:
    8000189a:	00153023          	sd	ra,0(a0)
    8000189e:	00253423          	sd	sp,8(a0)
    800018a2:	e900                	sd	s0,16(a0)
    800018a4:	ed04                	sd	s1,24(a0)
    800018a6:	03253023          	sd	s2,32(a0)
    800018aa:	03353423          	sd	s3,40(a0)
    800018ae:	03453823          	sd	s4,48(a0)
    800018b2:	03553c23          	sd	s5,56(a0)
    800018b6:	05653023          	sd	s6,64(a0)
    800018ba:	05753423          	sd	s7,72(a0)
    800018be:	05853823          	sd	s8,80(a0)
    800018c2:	05953c23          	sd	s9,88(a0)
    800018c6:	07a53023          	sd	s10,96(a0)
    800018ca:	07b53423          	sd	s11,104(a0)
    800018ce:	0005b083          	ld	ra,0(a1)
    800018d2:	0085b103          	ld	sp,8(a1)
    800018d6:	6980                	ld	s0,16(a1)
    800018d8:	6d84                	ld	s1,24(a1)
    800018da:	0205b903          	ld	s2,32(a1)
    800018de:	0285b983          	ld	s3,40(a1)
    800018e2:	0305ba03          	ld	s4,48(a1)
    800018e6:	0385ba83          	ld	s5,56(a1)
    800018ea:	0405bb03          	ld	s6,64(a1)
    800018ee:	0485bb83          	ld	s7,72(a1)
    800018f2:	0505bc03          	ld	s8,80(a1)
    800018f6:	0585bc83          	ld	s9,88(a1)
    800018fa:	0605bd03          	ld	s10,96(a1)
    800018fe:	0685bd83          	ld	s11,104(a1)
    80001902:	8082                	ret

0000000080001904 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001904:	1141                	addi	sp,sp,-16
    80001906:	e406                	sd	ra,8(sp)
    80001908:	e022                	sd	s0,0(sp)
    8000190a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000190c:	00006597          	auipc	a1,0x6
    80001910:	9f458593          	addi	a1,a1,-1548 # 80007300 <states.0+0x30>
    80001914:	0000c517          	auipc	a0,0xc
    80001918:	f0c50513          	addi	a0,a0,-244 # 8000d820 <tickslock>
    8000191c:	537030ef          	jal	ra,80005652 <initlock>
}
    80001920:	60a2                	ld	ra,8(sp)
    80001922:	6402                	ld	s0,0(sp)
    80001924:	0141                	addi	sp,sp,16
    80001926:	8082                	ret

0000000080001928 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001928:	1141                	addi	sp,sp,-16
    8000192a:	e422                	sd	s0,8(sp)
    8000192c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000192e:	00003797          	auipc	a5,0x3
    80001932:	d8278793          	addi	a5,a5,-638 # 800046b0 <kernelvec>
    80001936:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000193a:	6422                	ld	s0,8(sp)
    8000193c:	0141                	addi	sp,sp,16
    8000193e:	8082                	ret

0000000080001940 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001940:	1141                	addi	sp,sp,-16
    80001942:	e406                	sd	ra,8(sp)
    80001944:	e022                	sd	s0,0(sp)
    80001946:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001948:	cf2ff0ef          	jal	ra,80000e3a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000194c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001950:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001952:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001956:	00004697          	auipc	a3,0x4
    8000195a:	6aa68693          	addi	a3,a3,1706 # 80006000 <_trampoline>
    8000195e:	00004717          	auipc	a4,0x4
    80001962:	6a270713          	addi	a4,a4,1698 # 80006000 <_trampoline>
    80001966:	8f15                	sub	a4,a4,a3
    80001968:	040007b7          	lui	a5,0x4000
    8000196c:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000196e:	07b2                	slli	a5,a5,0xc
    80001970:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001972:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001976:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001978:	18002673          	csrr	a2,satp
    8000197c:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000197e:	6d30                	ld	a2,88(a0)
    80001980:	6138                	ld	a4,64(a0)
    80001982:	6585                	lui	a1,0x1
    80001984:	972e                	add	a4,a4,a1
    80001986:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001988:	6d38                	ld	a4,88(a0)
    8000198a:	00000617          	auipc	a2,0x0
    8000198e:	10c60613          	addi	a2,a2,268 # 80001a96 <usertrap>
    80001992:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001994:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001996:	8612                	mv	a2,tp
    80001998:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000199a:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000199e:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800019a2:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800019a6:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800019aa:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800019ac:	6f18                	ld	a4,24(a4)
    800019ae:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800019b2:	6928                	ld	a0,80(a0)
    800019b4:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019b6:	00004717          	auipc	a4,0x4
    800019ba:	6e670713          	addi	a4,a4,1766 # 8000609c <userret>
    800019be:	8f15                	sub	a4,a4,a3
    800019c0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019c2:	577d                	li	a4,-1
    800019c4:	177e                	slli	a4,a4,0x3f
    800019c6:	8d59                	or	a0,a0,a4
    800019c8:	9782                	jalr	a5
}
    800019ca:	60a2                	ld	ra,8(sp)
    800019cc:	6402                	ld	s0,0(sp)
    800019ce:	0141                	addi	sp,sp,16
    800019d0:	8082                	ret

00000000800019d2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800019d2:	1101                	addi	sp,sp,-32
    800019d4:	ec06                	sd	ra,24(sp)
    800019d6:	e822                	sd	s0,16(sp)
    800019d8:	e426                	sd	s1,8(sp)
    800019da:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800019dc:	c32ff0ef          	jal	ra,80000e0e <cpuid>
    800019e0:	cd19                	beqz	a0,800019fe <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    800019e2:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800019e6:	000f4737          	lui	a4,0xf4
    800019ea:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800019ee:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800019f0:	14d79073          	csrw	0x14d,a5
}
    800019f4:	60e2                	ld	ra,24(sp)
    800019f6:	6442                	ld	s0,16(sp)
    800019f8:	64a2                	ld	s1,8(sp)
    800019fa:	6105                	addi	sp,sp,32
    800019fc:	8082                	ret
    acquire(&tickslock);
    800019fe:	0000c497          	auipc	s1,0xc
    80001a02:	e2248493          	addi	s1,s1,-478 # 8000d820 <tickslock>
    80001a06:	8526                	mv	a0,s1
    80001a08:	4cb030ef          	jal	ra,800056d2 <acquire>
    ticks++;
    80001a0c:	00006517          	auipc	a0,0x6
    80001a10:	fac50513          	addi	a0,a0,-84 # 800079b8 <ticks>
    80001a14:	411c                	lw	a5,0(a0)
    80001a16:	2785                	addiw	a5,a5,1
    80001a18:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001a1a:	a39ff0ef          	jal	ra,80001452 <wakeup>
    release(&tickslock);
    80001a1e:	8526                	mv	a0,s1
    80001a20:	54b030ef          	jal	ra,8000576a <release>
    80001a24:	bf7d                	j	800019e2 <clockintr+0x10>

0000000080001a26 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001a26:	1101                	addi	sp,sp,-32
    80001a28:	ec06                	sd	ra,24(sp)
    80001a2a:	e822                	sd	s0,16(sp)
    80001a2c:	e426                	sd	s1,8(sp)
    80001a2e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001a30:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001a34:	57fd                	li	a5,-1
    80001a36:	17fe                	slli	a5,a5,0x3f
    80001a38:	07a5                	addi	a5,a5,9
    80001a3a:	00f70d63          	beq	a4,a5,80001a54 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001a3e:	57fd                	li	a5,-1
    80001a40:	17fe                	slli	a5,a5,0x3f
    80001a42:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001a44:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001a46:	04f70463          	beq	a4,a5,80001a8e <devintr+0x68>
  }
}
    80001a4a:	60e2                	ld	ra,24(sp)
    80001a4c:	6442                	ld	s0,16(sp)
    80001a4e:	64a2                	ld	s1,8(sp)
    80001a50:	6105                	addi	sp,sp,32
    80001a52:	8082                	ret
    int irq = plic_claim();
    80001a54:	505020ef          	jal	ra,80004758 <plic_claim>
    80001a58:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001a5a:	47a9                	li	a5,10
    80001a5c:	02f50363          	beq	a0,a5,80001a82 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80001a60:	4785                	li	a5,1
    80001a62:	02f50363          	beq	a0,a5,80001a88 <devintr+0x62>
    return 1;
    80001a66:	4505                	li	a0,1
    } else if(irq){
    80001a68:	d0ed                	beqz	s1,80001a4a <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80001a6a:	85a6                	mv	a1,s1
    80001a6c:	00006517          	auipc	a0,0x6
    80001a70:	89c50513          	addi	a0,a0,-1892 # 80007308 <states.0+0x38>
    80001a74:	69a030ef          	jal	ra,8000510e <printf>
      plic_complete(irq);
    80001a78:	8526                	mv	a0,s1
    80001a7a:	4ff020ef          	jal	ra,80004778 <plic_complete>
    return 1;
    80001a7e:	4505                	li	a0,1
    80001a80:	b7e9                	j	80001a4a <devintr+0x24>
      uartintr();
    80001a82:	395030ef          	jal	ra,80005616 <uartintr>
    80001a86:	bfcd                	j	80001a78 <devintr+0x52>
      virtio_disk_intr();
    80001a88:	15c030ef          	jal	ra,80004be4 <virtio_disk_intr>
    80001a8c:	b7f5                	j	80001a78 <devintr+0x52>
    clockintr();
    80001a8e:	f45ff0ef          	jal	ra,800019d2 <clockintr>
    return 2;
    80001a92:	4509                	li	a0,2
    80001a94:	bf5d                	j	80001a4a <devintr+0x24>

0000000080001a96 <usertrap>:
{
    80001a96:	1101                	addi	sp,sp,-32
    80001a98:	ec06                	sd	ra,24(sp)
    80001a9a:	e822                	sd	s0,16(sp)
    80001a9c:	e426                	sd	s1,8(sp)
    80001a9e:	e04a                	sd	s2,0(sp)
    80001aa0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001aa2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001aa6:	1007f793          	andi	a5,a5,256
    80001aaa:	ef85                	bnez	a5,80001ae2 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001aac:	00003797          	auipc	a5,0x3
    80001ab0:	c0478793          	addi	a5,a5,-1020 # 800046b0 <kernelvec>
    80001ab4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001ab8:	b82ff0ef          	jal	ra,80000e3a <myproc>
    80001abc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001abe:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001ac0:	14102773          	csrr	a4,sepc
    80001ac4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001ac6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001aca:	47a1                	li	a5,8
    80001acc:	02f70163          	beq	a4,a5,80001aee <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001ad0:	f57ff0ef          	jal	ra,80001a26 <devintr>
    80001ad4:	892a                	mv	s2,a0
    80001ad6:	c135                	beqz	a0,80001b3a <usertrap+0xa4>
  if(killed(p))
    80001ad8:	8526                	mv	a0,s1
    80001ada:	b65ff0ef          	jal	ra,8000163e <killed>
    80001ade:	cd1d                	beqz	a0,80001b1c <usertrap+0x86>
    80001ae0:	a81d                	j	80001b16 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001ae2:	00006517          	auipc	a0,0x6
    80001ae6:	84650513          	addi	a0,a0,-1978 # 80007328 <states.0+0x58>
    80001aea:	0d9030ef          	jal	ra,800053c2 <panic>
    if(killed(p))
    80001aee:	b51ff0ef          	jal	ra,8000163e <killed>
    80001af2:	e121                	bnez	a0,80001b32 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001af4:	6cb8                	ld	a4,88(s1)
    80001af6:	6f1c                	ld	a5,24(a4)
    80001af8:	0791                	addi	a5,a5,4
    80001afa:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001afc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001b00:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b04:	10079073          	csrw	sstatus,a5
    syscall();
    80001b08:	248000ef          	jal	ra,80001d50 <syscall>
  if(killed(p))
    80001b0c:	8526                	mv	a0,s1
    80001b0e:	b31ff0ef          	jal	ra,8000163e <killed>
    80001b12:	c901                	beqz	a0,80001b22 <usertrap+0x8c>
    80001b14:	4901                	li	s2,0
    exit(-1);
    80001b16:	557d                	li	a0,-1
    80001b18:	9fbff0ef          	jal	ra,80001512 <exit>
  if(which_dev == 2)
    80001b1c:	4789                	li	a5,2
    80001b1e:	04f90563          	beq	s2,a5,80001b68 <usertrap+0xd2>
  usertrapret();
    80001b22:	e1fff0ef          	jal	ra,80001940 <usertrapret>
}
    80001b26:	60e2                	ld	ra,24(sp)
    80001b28:	6442                	ld	s0,16(sp)
    80001b2a:	64a2                	ld	s1,8(sp)
    80001b2c:	6902                	ld	s2,0(sp)
    80001b2e:	6105                	addi	sp,sp,32
    80001b30:	8082                	ret
      exit(-1);
    80001b32:	557d                	li	a0,-1
    80001b34:	9dfff0ef          	jal	ra,80001512 <exit>
    80001b38:	bf75                	j	80001af4 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b3a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001b3e:	5890                	lw	a2,48(s1)
    80001b40:	00006517          	auipc	a0,0x6
    80001b44:	80850513          	addi	a0,a0,-2040 # 80007348 <states.0+0x78>
    80001b48:	5c6030ef          	jal	ra,8000510e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b4c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001b50:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001b54:	00006517          	auipc	a0,0x6
    80001b58:	82450513          	addi	a0,a0,-2012 # 80007378 <states.0+0xa8>
    80001b5c:	5b2030ef          	jal	ra,8000510e <printf>
    setkilled(p);
    80001b60:	8526                	mv	a0,s1
    80001b62:	ab9ff0ef          	jal	ra,8000161a <setkilled>
    80001b66:	b75d                	j	80001b0c <usertrap+0x76>
    yield();
    80001b68:	873ff0ef          	jal	ra,800013da <yield>
    80001b6c:	bf5d                	j	80001b22 <usertrap+0x8c>

0000000080001b6e <kerneltrap>:
{
    80001b6e:	7179                	addi	sp,sp,-48
    80001b70:	f406                	sd	ra,40(sp)
    80001b72:	f022                	sd	s0,32(sp)
    80001b74:	ec26                	sd	s1,24(sp)
    80001b76:	e84a                	sd	s2,16(sp)
    80001b78:	e44e                	sd	s3,8(sp)
    80001b7a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b7c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b80:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b84:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001b88:	1004f793          	andi	a5,s1,256
    80001b8c:	c795                	beqz	a5,80001bb8 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b8e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001b92:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001b94:	eb85                	bnez	a5,80001bc4 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001b96:	e91ff0ef          	jal	ra,80001a26 <devintr>
    80001b9a:	c91d                	beqz	a0,80001bd0 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001b9c:	4789                	li	a5,2
    80001b9e:	04f50a63          	beq	a0,a5,80001bf2 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001ba2:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ba6:	10049073          	csrw	sstatus,s1
}
    80001baa:	70a2                	ld	ra,40(sp)
    80001bac:	7402                	ld	s0,32(sp)
    80001bae:	64e2                	ld	s1,24(sp)
    80001bb0:	6942                	ld	s2,16(sp)
    80001bb2:	69a2                	ld	s3,8(sp)
    80001bb4:	6145                	addi	sp,sp,48
    80001bb6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001bb8:	00005517          	auipc	a0,0x5
    80001bbc:	7e850513          	addi	a0,a0,2024 # 800073a0 <states.0+0xd0>
    80001bc0:	003030ef          	jal	ra,800053c2 <panic>
    panic("kerneltrap: interrupts enabled");
    80001bc4:	00006517          	auipc	a0,0x6
    80001bc8:	80450513          	addi	a0,a0,-2044 # 800073c8 <states.0+0xf8>
    80001bcc:	7f6030ef          	jal	ra,800053c2 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001bd0:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001bd4:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001bd8:	85ce                	mv	a1,s3
    80001bda:	00006517          	auipc	a0,0x6
    80001bde:	80e50513          	addi	a0,a0,-2034 # 800073e8 <states.0+0x118>
    80001be2:	52c030ef          	jal	ra,8000510e <printf>
    panic("kerneltrap");
    80001be6:	00006517          	auipc	a0,0x6
    80001bea:	82a50513          	addi	a0,a0,-2006 # 80007410 <states.0+0x140>
    80001bee:	7d4030ef          	jal	ra,800053c2 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001bf2:	a48ff0ef          	jal	ra,80000e3a <myproc>
    80001bf6:	d555                	beqz	a0,80001ba2 <kerneltrap+0x34>
    yield();
    80001bf8:	fe2ff0ef          	jal	ra,800013da <yield>
    80001bfc:	b75d                	j	80001ba2 <kerneltrap+0x34>

0000000080001bfe <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001bfe:	1101                	addi	sp,sp,-32
    80001c00:	ec06                	sd	ra,24(sp)
    80001c02:	e822                	sd	s0,16(sp)
    80001c04:	e426                	sd	s1,8(sp)
    80001c06:	1000                	addi	s0,sp,32
    80001c08:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c0a:	a30ff0ef          	jal	ra,80000e3a <myproc>
  switch (n) {
    80001c0e:	4795                	li	a5,5
    80001c10:	0497e163          	bltu	a5,s1,80001c52 <argraw+0x54>
    80001c14:	048a                	slli	s1,s1,0x2
    80001c16:	00006717          	auipc	a4,0x6
    80001c1a:	83270713          	addi	a4,a4,-1998 # 80007448 <states.0+0x178>
    80001c1e:	94ba                	add	s1,s1,a4
    80001c20:	409c                	lw	a5,0(s1)
    80001c22:	97ba                	add	a5,a5,a4
    80001c24:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001c26:	6d3c                	ld	a5,88(a0)
    80001c28:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001c2a:	60e2                	ld	ra,24(sp)
    80001c2c:	6442                	ld	s0,16(sp)
    80001c2e:	64a2                	ld	s1,8(sp)
    80001c30:	6105                	addi	sp,sp,32
    80001c32:	8082                	ret
    return p->trapframe->a1;
    80001c34:	6d3c                	ld	a5,88(a0)
    80001c36:	7fa8                	ld	a0,120(a5)
    80001c38:	bfcd                	j	80001c2a <argraw+0x2c>
    return p->trapframe->a2;
    80001c3a:	6d3c                	ld	a5,88(a0)
    80001c3c:	63c8                	ld	a0,128(a5)
    80001c3e:	b7f5                	j	80001c2a <argraw+0x2c>
    return p->trapframe->a3;
    80001c40:	6d3c                	ld	a5,88(a0)
    80001c42:	67c8                	ld	a0,136(a5)
    80001c44:	b7dd                	j	80001c2a <argraw+0x2c>
    return p->trapframe->a4;
    80001c46:	6d3c                	ld	a5,88(a0)
    80001c48:	6bc8                	ld	a0,144(a5)
    80001c4a:	b7c5                	j	80001c2a <argraw+0x2c>
    return p->trapframe->a5;
    80001c4c:	6d3c                	ld	a5,88(a0)
    80001c4e:	6fc8                	ld	a0,152(a5)
    80001c50:	bfe9                	j	80001c2a <argraw+0x2c>
  panic("argraw");
    80001c52:	00005517          	auipc	a0,0x5
    80001c56:	7ce50513          	addi	a0,a0,1998 # 80007420 <states.0+0x150>
    80001c5a:	768030ef          	jal	ra,800053c2 <panic>

0000000080001c5e <fetchaddr>:
{
    80001c5e:	1101                	addi	sp,sp,-32
    80001c60:	ec06                	sd	ra,24(sp)
    80001c62:	e822                	sd	s0,16(sp)
    80001c64:	e426                	sd	s1,8(sp)
    80001c66:	e04a                	sd	s2,0(sp)
    80001c68:	1000                	addi	s0,sp,32
    80001c6a:	84aa                	mv	s1,a0
    80001c6c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001c6e:	9ccff0ef          	jal	ra,80000e3a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001c72:	653c                	ld	a5,72(a0)
    80001c74:	02f4f663          	bgeu	s1,a5,80001ca0 <fetchaddr+0x42>
    80001c78:	00848713          	addi	a4,s1,8
    80001c7c:	02e7e463          	bltu	a5,a4,80001ca4 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001c80:	46a1                	li	a3,8
    80001c82:	8626                	mv	a2,s1
    80001c84:	85ca                	mv	a1,s2
    80001c86:	6928                	ld	a0,80(a0)
    80001c88:	e0ffe0ef          	jal	ra,80000a96 <copyin>
    80001c8c:	00a03533          	snez	a0,a0
    80001c90:	40a00533          	neg	a0,a0
}
    80001c94:	60e2                	ld	ra,24(sp)
    80001c96:	6442                	ld	s0,16(sp)
    80001c98:	64a2                	ld	s1,8(sp)
    80001c9a:	6902                	ld	s2,0(sp)
    80001c9c:	6105                	addi	sp,sp,32
    80001c9e:	8082                	ret
    return -1;
    80001ca0:	557d                	li	a0,-1
    80001ca2:	bfcd                	j	80001c94 <fetchaddr+0x36>
    80001ca4:	557d                	li	a0,-1
    80001ca6:	b7fd                	j	80001c94 <fetchaddr+0x36>

0000000080001ca8 <fetchstr>:
{
    80001ca8:	7179                	addi	sp,sp,-48
    80001caa:	f406                	sd	ra,40(sp)
    80001cac:	f022                	sd	s0,32(sp)
    80001cae:	ec26                	sd	s1,24(sp)
    80001cb0:	e84a                	sd	s2,16(sp)
    80001cb2:	e44e                	sd	s3,8(sp)
    80001cb4:	1800                	addi	s0,sp,48
    80001cb6:	892a                	mv	s2,a0
    80001cb8:	84ae                	mv	s1,a1
    80001cba:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001cbc:	97eff0ef          	jal	ra,80000e3a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001cc0:	86ce                	mv	a3,s3
    80001cc2:	864a                	mv	a2,s2
    80001cc4:	85a6                	mv	a1,s1
    80001cc6:	6928                	ld	a0,80(a0)
    80001cc8:	e55fe0ef          	jal	ra,80000b1c <copyinstr>
    80001ccc:	00054c63          	bltz	a0,80001ce4 <fetchstr+0x3c>
  return strlen(buf);
    80001cd0:	8526                	mv	a0,s1
    80001cd2:	df4fe0ef          	jal	ra,800002c6 <strlen>
}
    80001cd6:	70a2                	ld	ra,40(sp)
    80001cd8:	7402                	ld	s0,32(sp)
    80001cda:	64e2                	ld	s1,24(sp)
    80001cdc:	6942                	ld	s2,16(sp)
    80001cde:	69a2                	ld	s3,8(sp)
    80001ce0:	6145                	addi	sp,sp,48
    80001ce2:	8082                	ret
    return -1;
    80001ce4:	557d                	li	a0,-1
    80001ce6:	bfc5                	j	80001cd6 <fetchstr+0x2e>

0000000080001ce8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001ce8:	1101                	addi	sp,sp,-32
    80001cea:	ec06                	sd	ra,24(sp)
    80001cec:	e822                	sd	s0,16(sp)
    80001cee:	e426                	sd	s1,8(sp)
    80001cf0:	1000                	addi	s0,sp,32
    80001cf2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001cf4:	f0bff0ef          	jal	ra,80001bfe <argraw>
    80001cf8:	c088                	sw	a0,0(s1)
}
    80001cfa:	60e2                	ld	ra,24(sp)
    80001cfc:	6442                	ld	s0,16(sp)
    80001cfe:	64a2                	ld	s1,8(sp)
    80001d00:	6105                	addi	sp,sp,32
    80001d02:	8082                	ret

0000000080001d04 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001d04:	1101                	addi	sp,sp,-32
    80001d06:	ec06                	sd	ra,24(sp)
    80001d08:	e822                	sd	s0,16(sp)
    80001d0a:	e426                	sd	s1,8(sp)
    80001d0c:	1000                	addi	s0,sp,32
    80001d0e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001d10:	eefff0ef          	jal	ra,80001bfe <argraw>
    80001d14:	e088                	sd	a0,0(s1)
}
    80001d16:	60e2                	ld	ra,24(sp)
    80001d18:	6442                	ld	s0,16(sp)
    80001d1a:	64a2                	ld	s1,8(sp)
    80001d1c:	6105                	addi	sp,sp,32
    80001d1e:	8082                	ret

0000000080001d20 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001d20:	7179                	addi	sp,sp,-48
    80001d22:	f406                	sd	ra,40(sp)
    80001d24:	f022                	sd	s0,32(sp)
    80001d26:	ec26                	sd	s1,24(sp)
    80001d28:	e84a                	sd	s2,16(sp)
    80001d2a:	1800                	addi	s0,sp,48
    80001d2c:	84ae                	mv	s1,a1
    80001d2e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001d30:	fd840593          	addi	a1,s0,-40
    80001d34:	fd1ff0ef          	jal	ra,80001d04 <argaddr>
  return fetchstr(addr, buf, max);
    80001d38:	864a                	mv	a2,s2
    80001d3a:	85a6                	mv	a1,s1
    80001d3c:	fd843503          	ld	a0,-40(s0)
    80001d40:	f69ff0ef          	jal	ra,80001ca8 <fetchstr>
}
    80001d44:	70a2                	ld	ra,40(sp)
    80001d46:	7402                	ld	s0,32(sp)
    80001d48:	64e2                	ld	s1,24(sp)
    80001d4a:	6942                	ld	s2,16(sp)
    80001d4c:	6145                	addi	sp,sp,48
    80001d4e:	8082                	ret

0000000080001d50 <syscall>:
#endif
};

void
syscall(void)
{
    80001d50:	1101                	addi	sp,sp,-32
    80001d52:	ec06                	sd	ra,24(sp)
    80001d54:	e822                	sd	s0,16(sp)
    80001d56:	e426                	sd	s1,8(sp)
    80001d58:	e04a                	sd	s2,0(sp)
    80001d5a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001d5c:	8deff0ef          	jal	ra,80000e3a <myproc>
    80001d60:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001d62:	05853903          	ld	s2,88(a0)
    80001d66:	0a893783          	ld	a5,168(s2)
    80001d6a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001d6e:	37fd                	addiw	a5,a5,-1
    80001d70:	02100713          	li	a4,33
    80001d74:	00f76f63          	bltu	a4,a5,80001d92 <syscall+0x42>
    80001d78:	00369713          	slli	a4,a3,0x3
    80001d7c:	00005797          	auipc	a5,0x5
    80001d80:	6e478793          	addi	a5,a5,1764 # 80007460 <syscalls>
    80001d84:	97ba                	add	a5,a5,a4
    80001d86:	639c                	ld	a5,0(a5)
    80001d88:	c789                	beqz	a5,80001d92 <syscall+0x42>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001d8a:	9782                	jalr	a5
    80001d8c:	06a93823          	sd	a0,112(s2)
    80001d90:	a829                	j	80001daa <syscall+0x5a>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001d92:	15848613          	addi	a2,s1,344
    80001d96:	588c                	lw	a1,48(s1)
    80001d98:	00005517          	auipc	a0,0x5
    80001d9c:	69050513          	addi	a0,a0,1680 # 80007428 <states.0+0x158>
    80001da0:	36e030ef          	jal	ra,8000510e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001da4:	6cbc                	ld	a5,88(s1)
    80001da6:	577d                	li	a4,-1
    80001da8:	fbb8                	sd	a4,112(a5)
  }
}
    80001daa:	60e2                	ld	ra,24(sp)
    80001dac:	6442                	ld	s0,16(sp)
    80001dae:	64a2                	ld	s1,8(sp)
    80001db0:	6902                	ld	s2,0(sp)
    80001db2:	6105                	addi	sp,sp,32
    80001db4:	8082                	ret

0000000080001db6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80001db6:	1101                	addi	sp,sp,-32
    80001db8:	ec06                	sd	ra,24(sp)
    80001dba:	e822                	sd	s0,16(sp)
    80001dbc:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001dbe:	fec40593          	addi	a1,s0,-20
    80001dc2:	4501                	li	a0,0
    80001dc4:	f25ff0ef          	jal	ra,80001ce8 <argint>
  exit(n);
    80001dc8:	fec42503          	lw	a0,-20(s0)
    80001dcc:	f46ff0ef          	jal	ra,80001512 <exit>
  return 0;  // not reached
}
    80001dd0:	4501                	li	a0,0
    80001dd2:	60e2                	ld	ra,24(sp)
    80001dd4:	6442                	ld	s0,16(sp)
    80001dd6:	6105                	addi	sp,sp,32
    80001dd8:	8082                	ret

0000000080001dda <sys_getpid>:

uint64
sys_getpid(void)
{
    80001dda:	1141                	addi	sp,sp,-16
    80001ddc:	e406                	sd	ra,8(sp)
    80001dde:	e022                	sd	s0,0(sp)
    80001de0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001de2:	858ff0ef          	jal	ra,80000e3a <myproc>
}
    80001de6:	5908                	lw	a0,48(a0)
    80001de8:	60a2                	ld	ra,8(sp)
    80001dea:	6402                	ld	s0,0(sp)
    80001dec:	0141                	addi	sp,sp,16
    80001dee:	8082                	ret

0000000080001df0 <sys_fork>:

uint64
sys_fork(void)
{
    80001df0:	1141                	addi	sp,sp,-16
    80001df2:	e406                	sd	ra,8(sp)
    80001df4:	e022                	sd	s0,0(sp)
    80001df6:	0800                	addi	s0,sp,16
  return fork();
    80001df8:	b68ff0ef          	jal	ra,80001160 <fork>
}
    80001dfc:	60a2                	ld	ra,8(sp)
    80001dfe:	6402                	ld	s0,0(sp)
    80001e00:	0141                	addi	sp,sp,16
    80001e02:	8082                	ret

0000000080001e04 <sys_wait>:

uint64
sys_wait(void)
{
    80001e04:	1101                	addi	sp,sp,-32
    80001e06:	ec06                	sd	ra,24(sp)
    80001e08:	e822                	sd	s0,16(sp)
    80001e0a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001e0c:	fe840593          	addi	a1,s0,-24
    80001e10:	4501                	li	a0,0
    80001e12:	ef3ff0ef          	jal	ra,80001d04 <argaddr>
  return wait(p);
    80001e16:	fe843503          	ld	a0,-24(s0)
    80001e1a:	84fff0ef          	jal	ra,80001668 <wait>
}
    80001e1e:	60e2                	ld	ra,24(sp)
    80001e20:	6442                	ld	s0,16(sp)
    80001e22:	6105                	addi	sp,sp,32
    80001e24:	8082                	ret

0000000080001e26 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001e26:	7179                	addi	sp,sp,-48
    80001e28:	f406                	sd	ra,40(sp)
    80001e2a:	f022                	sd	s0,32(sp)
    80001e2c:	ec26                	sd	s1,24(sp)
    80001e2e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001e30:	fdc40593          	addi	a1,s0,-36
    80001e34:	4501                	li	a0,0
    80001e36:	eb3ff0ef          	jal	ra,80001ce8 <argint>
  addr = myproc()->sz;
    80001e3a:	800ff0ef          	jal	ra,80000e3a <myproc>
    80001e3e:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001e40:	fdc42503          	lw	a0,-36(s0)
    80001e44:	accff0ef          	jal	ra,80001110 <growproc>
    80001e48:	00054863          	bltz	a0,80001e58 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80001e4c:	8526                	mv	a0,s1
    80001e4e:	70a2                	ld	ra,40(sp)
    80001e50:	7402                	ld	s0,32(sp)
    80001e52:	64e2                	ld	s1,24(sp)
    80001e54:	6145                	addi	sp,sp,48
    80001e56:	8082                	ret
    return -1;
    80001e58:	54fd                	li	s1,-1
    80001e5a:	bfcd                	j	80001e4c <sys_sbrk+0x26>

0000000080001e5c <sys_sleep>:

uint64
sys_sleep(void)
{
    80001e5c:	7139                	addi	sp,sp,-64
    80001e5e:	fc06                	sd	ra,56(sp)
    80001e60:	f822                	sd	s0,48(sp)
    80001e62:	f426                	sd	s1,40(sp)
    80001e64:	f04a                	sd	s2,32(sp)
    80001e66:	ec4e                	sd	s3,24(sp)
    80001e68:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001e6a:	fcc40593          	addi	a1,s0,-52
    80001e6e:	4501                	li	a0,0
    80001e70:	e79ff0ef          	jal	ra,80001ce8 <argint>
  if(n < 0)
    80001e74:	fcc42783          	lw	a5,-52(s0)
    80001e78:	0607c563          	bltz	a5,80001ee2 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80001e7c:	0000c517          	auipc	a0,0xc
    80001e80:	9a450513          	addi	a0,a0,-1628 # 8000d820 <tickslock>
    80001e84:	04f030ef          	jal	ra,800056d2 <acquire>
  ticks0 = ticks;
    80001e88:	00006917          	auipc	s2,0x6
    80001e8c:	b3092903          	lw	s2,-1232(s2) # 800079b8 <ticks>
  while(ticks - ticks0 < n){
    80001e90:	fcc42783          	lw	a5,-52(s0)
    80001e94:	cb8d                	beqz	a5,80001ec6 <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001e96:	0000c997          	auipc	s3,0xc
    80001e9a:	98a98993          	addi	s3,s3,-1654 # 8000d820 <tickslock>
    80001e9e:	00006497          	auipc	s1,0x6
    80001ea2:	b1a48493          	addi	s1,s1,-1254 # 800079b8 <ticks>
    if(killed(myproc())){
    80001ea6:	f95fe0ef          	jal	ra,80000e3a <myproc>
    80001eaa:	f94ff0ef          	jal	ra,8000163e <killed>
    80001eae:	ed0d                	bnez	a0,80001ee8 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80001eb0:	85ce                	mv	a1,s3
    80001eb2:	8526                	mv	a0,s1
    80001eb4:	d52ff0ef          	jal	ra,80001406 <sleep>
  while(ticks - ticks0 < n){
    80001eb8:	409c                	lw	a5,0(s1)
    80001eba:	412787bb          	subw	a5,a5,s2
    80001ebe:	fcc42703          	lw	a4,-52(s0)
    80001ec2:	fee7e2e3          	bltu	a5,a4,80001ea6 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80001ec6:	0000c517          	auipc	a0,0xc
    80001eca:	95a50513          	addi	a0,a0,-1702 # 8000d820 <tickslock>
    80001ece:	09d030ef          	jal	ra,8000576a <release>
  return 0;
    80001ed2:	4501                	li	a0,0
}
    80001ed4:	70e2                	ld	ra,56(sp)
    80001ed6:	7442                	ld	s0,48(sp)
    80001ed8:	74a2                	ld	s1,40(sp)
    80001eda:	7902                	ld	s2,32(sp)
    80001edc:	69e2                	ld	s3,24(sp)
    80001ede:	6121                	addi	sp,sp,64
    80001ee0:	8082                	ret
    n = 0;
    80001ee2:	fc042623          	sw	zero,-52(s0)
    80001ee6:	bf59                	j	80001e7c <sys_sleep+0x20>
      release(&tickslock);
    80001ee8:	0000c517          	auipc	a0,0xc
    80001eec:	93850513          	addi	a0,a0,-1736 # 8000d820 <tickslock>
    80001ef0:	07b030ef          	jal	ra,8000576a <release>
      return -1;
    80001ef4:	557d                	li	a0,-1
    80001ef6:	bff9                	j	80001ed4 <sys_sleep+0x78>

0000000080001ef8 <sys_pgpte>:


#ifdef LAB_PGTBL
int
sys_pgpte(void)
{
    80001ef8:	7179                	addi	sp,sp,-48
    80001efa:	f406                	sd	ra,40(sp)
    80001efc:	f022                	sd	s0,32(sp)
    80001efe:	ec26                	sd	s1,24(sp)
    80001f00:	1800                	addi	s0,sp,48
  uint64 va;
  struct proc *p;

  p = myproc();
    80001f02:	f39fe0ef          	jal	ra,80000e3a <myproc>
    80001f06:	84aa                	mv	s1,a0
  argaddr(0, &va);
    80001f08:	fd840593          	addi	a1,s0,-40
    80001f0c:	4501                	li	a0,0
    80001f0e:	df7ff0ef          	jal	ra,80001d04 <argaddr>
  pte_t *pte = pgpte(p->pagetable, va);
    80001f12:	fd843583          	ld	a1,-40(s0)
    80001f16:	68a8                	ld	a0,80(s1)
    80001f18:	daffe0ef          	jal	ra,80000cc6 <pgpte>
    80001f1c:	87aa                	mv	a5,a0
  if(pte != 0) {
      return (uint64) *pte;
  }
  return 0;
    80001f1e:	4501                	li	a0,0
  if(pte != 0) {
    80001f20:	c391                	beqz	a5,80001f24 <sys_pgpte+0x2c>
      return (uint64) *pte;
    80001f22:	4388                	lw	a0,0(a5)
}
    80001f24:	70a2                	ld	ra,40(sp)
    80001f26:	7402                	ld	s0,32(sp)
    80001f28:	64e2                	ld	s1,24(sp)
    80001f2a:	6145                	addi	sp,sp,48
    80001f2c:	8082                	ret

0000000080001f2e <sys_kpgtbl>:
#endif

#ifdef LAB_PGTBL
int
sys_kpgtbl(void)
{
    80001f2e:	1141                	addi	sp,sp,-16
    80001f30:	e406                	sd	ra,8(sp)
    80001f32:	e022                	sd	s0,0(sp)
    80001f34:	0800                	addi	s0,sp,16
  struct proc *p;

  p = myproc();
    80001f36:	f05fe0ef          	jal	ra,80000e3a <myproc>
  vmprint(p->pagetable);
    80001f3a:	6928                	ld	a0,80(a0)
    80001f3c:	d5dfe0ef          	jal	ra,80000c98 <vmprint>
  return 0;
}
    80001f40:	4501                	li	a0,0
    80001f42:	60a2                	ld	ra,8(sp)
    80001f44:	6402                	ld	s0,0(sp)
    80001f46:	0141                	addi	sp,sp,16
    80001f48:	8082                	ret

0000000080001f4a <sys_kill>:
#endif


uint64
sys_kill(void)
{
    80001f4a:	1101                	addi	sp,sp,-32
    80001f4c:	ec06                	sd	ra,24(sp)
    80001f4e:	e822                	sd	s0,16(sp)
    80001f50:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001f52:	fec40593          	addi	a1,s0,-20
    80001f56:	4501                	li	a0,0
    80001f58:	d91ff0ef          	jal	ra,80001ce8 <argint>
  return kill(pid);
    80001f5c:	fec42503          	lw	a0,-20(s0)
    80001f60:	e54ff0ef          	jal	ra,800015b4 <kill>
}
    80001f64:	60e2                	ld	ra,24(sp)
    80001f66:	6442                	ld	s0,16(sp)
    80001f68:	6105                	addi	sp,sp,32
    80001f6a:	8082                	ret

0000000080001f6c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001f6c:	1101                	addi	sp,sp,-32
    80001f6e:	ec06                	sd	ra,24(sp)
    80001f70:	e822                	sd	s0,16(sp)
    80001f72:	e426                	sd	s1,8(sp)
    80001f74:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001f76:	0000c517          	auipc	a0,0xc
    80001f7a:	8aa50513          	addi	a0,a0,-1878 # 8000d820 <tickslock>
    80001f7e:	754030ef          	jal	ra,800056d2 <acquire>
  xticks = ticks;
    80001f82:	00006497          	auipc	s1,0x6
    80001f86:	a364a483          	lw	s1,-1482(s1) # 800079b8 <ticks>
  release(&tickslock);
    80001f8a:	0000c517          	auipc	a0,0xc
    80001f8e:	89650513          	addi	a0,a0,-1898 # 8000d820 <tickslock>
    80001f92:	7d8030ef          	jal	ra,8000576a <release>
  return xticks;
}
    80001f96:	02049513          	slli	a0,s1,0x20
    80001f9a:	9101                	srli	a0,a0,0x20
    80001f9c:	60e2                	ld	ra,24(sp)
    80001f9e:	6442                	ld	s0,16(sp)
    80001fa0:	64a2                	ld	s1,8(sp)
    80001fa2:	6105                	addi	sp,sp,32
    80001fa4:	8082                	ret

0000000080001fa6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80001fa6:	7179                	addi	sp,sp,-48
    80001fa8:	f406                	sd	ra,40(sp)
    80001faa:	f022                	sd	s0,32(sp)
    80001fac:	ec26                	sd	s1,24(sp)
    80001fae:	e84a                	sd	s2,16(sp)
    80001fb0:	e44e                	sd	s3,8(sp)
    80001fb2:	e052                	sd	s4,0(sp)
    80001fb4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80001fb6:	00005597          	auipc	a1,0x5
    80001fba:	5c258593          	addi	a1,a1,1474 # 80007578 <syscalls+0x118>
    80001fbe:	0000c517          	auipc	a0,0xc
    80001fc2:	87a50513          	addi	a0,a0,-1926 # 8000d838 <bcache>
    80001fc6:	68c030ef          	jal	ra,80005652 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80001fca:	00014797          	auipc	a5,0x14
    80001fce:	86e78793          	addi	a5,a5,-1938 # 80015838 <bcache+0x8000>
    80001fd2:	00014717          	auipc	a4,0x14
    80001fd6:	ace70713          	addi	a4,a4,-1330 # 80015aa0 <bcache+0x8268>
    80001fda:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80001fde:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001fe2:	0000c497          	auipc	s1,0xc
    80001fe6:	86e48493          	addi	s1,s1,-1938 # 8000d850 <bcache+0x18>
    b->next = bcache.head.next;
    80001fea:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80001fec:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80001fee:	00005a17          	auipc	s4,0x5
    80001ff2:	592a0a13          	addi	s4,s4,1426 # 80007580 <syscalls+0x120>
    b->next = bcache.head.next;
    80001ff6:	2b893783          	ld	a5,696(s2)
    80001ffa:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80001ffc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002000:	85d2                	mv	a1,s4
    80002002:	01048513          	addi	a0,s1,16
    80002006:	228010ef          	jal	ra,8000322e <initsleeplock>
    bcache.head.next->prev = b;
    8000200a:	2b893783          	ld	a5,696(s2)
    8000200e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002010:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002014:	45848493          	addi	s1,s1,1112
    80002018:	fd349fe3          	bne	s1,s3,80001ff6 <binit+0x50>
  }
}
    8000201c:	70a2                	ld	ra,40(sp)
    8000201e:	7402                	ld	s0,32(sp)
    80002020:	64e2                	ld	s1,24(sp)
    80002022:	6942                	ld	s2,16(sp)
    80002024:	69a2                	ld	s3,8(sp)
    80002026:	6a02                	ld	s4,0(sp)
    80002028:	6145                	addi	sp,sp,48
    8000202a:	8082                	ret

000000008000202c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000202c:	7179                	addi	sp,sp,-48
    8000202e:	f406                	sd	ra,40(sp)
    80002030:	f022                	sd	s0,32(sp)
    80002032:	ec26                	sd	s1,24(sp)
    80002034:	e84a                	sd	s2,16(sp)
    80002036:	e44e                	sd	s3,8(sp)
    80002038:	1800                	addi	s0,sp,48
    8000203a:	892a                	mv	s2,a0
    8000203c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000203e:	0000b517          	auipc	a0,0xb
    80002042:	7fa50513          	addi	a0,a0,2042 # 8000d838 <bcache>
    80002046:	68c030ef          	jal	ra,800056d2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000204a:	00014497          	auipc	s1,0x14
    8000204e:	aa64b483          	ld	s1,-1370(s1) # 80015af0 <bcache+0x82b8>
    80002052:	00014797          	auipc	a5,0x14
    80002056:	a4e78793          	addi	a5,a5,-1458 # 80015aa0 <bcache+0x8268>
    8000205a:	02f48b63          	beq	s1,a5,80002090 <bread+0x64>
    8000205e:	873e                	mv	a4,a5
    80002060:	a021                	j	80002068 <bread+0x3c>
    80002062:	68a4                	ld	s1,80(s1)
    80002064:	02e48663          	beq	s1,a4,80002090 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002068:	449c                	lw	a5,8(s1)
    8000206a:	ff279ce3          	bne	a5,s2,80002062 <bread+0x36>
    8000206e:	44dc                	lw	a5,12(s1)
    80002070:	ff3799e3          	bne	a5,s3,80002062 <bread+0x36>
      b->refcnt++;
    80002074:	40bc                	lw	a5,64(s1)
    80002076:	2785                	addiw	a5,a5,1
    80002078:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000207a:	0000b517          	auipc	a0,0xb
    8000207e:	7be50513          	addi	a0,a0,1982 # 8000d838 <bcache>
    80002082:	6e8030ef          	jal	ra,8000576a <release>
      acquiresleep(&b->lock);
    80002086:	01048513          	addi	a0,s1,16
    8000208a:	1da010ef          	jal	ra,80003264 <acquiresleep>
      return b;
    8000208e:	a889                	j	800020e0 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002090:	00014497          	auipc	s1,0x14
    80002094:	a584b483          	ld	s1,-1448(s1) # 80015ae8 <bcache+0x82b0>
    80002098:	00014797          	auipc	a5,0x14
    8000209c:	a0878793          	addi	a5,a5,-1528 # 80015aa0 <bcache+0x8268>
    800020a0:	00f48863          	beq	s1,a5,800020b0 <bread+0x84>
    800020a4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800020a6:	40bc                	lw	a5,64(s1)
    800020a8:	cb91                	beqz	a5,800020bc <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800020aa:	64a4                	ld	s1,72(s1)
    800020ac:	fee49de3          	bne	s1,a4,800020a6 <bread+0x7a>
  panic("bget: no buffers");
    800020b0:	00005517          	auipc	a0,0x5
    800020b4:	4d850513          	addi	a0,a0,1240 # 80007588 <syscalls+0x128>
    800020b8:	30a030ef          	jal	ra,800053c2 <panic>
      b->dev = dev;
    800020bc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800020c0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800020c4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800020c8:	4785                	li	a5,1
    800020ca:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800020cc:	0000b517          	auipc	a0,0xb
    800020d0:	76c50513          	addi	a0,a0,1900 # 8000d838 <bcache>
    800020d4:	696030ef          	jal	ra,8000576a <release>
      acquiresleep(&b->lock);
    800020d8:	01048513          	addi	a0,s1,16
    800020dc:	188010ef          	jal	ra,80003264 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800020e0:	409c                	lw	a5,0(s1)
    800020e2:	cb89                	beqz	a5,800020f4 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800020e4:	8526                	mv	a0,s1
    800020e6:	70a2                	ld	ra,40(sp)
    800020e8:	7402                	ld	s0,32(sp)
    800020ea:	64e2                	ld	s1,24(sp)
    800020ec:	6942                	ld	s2,16(sp)
    800020ee:	69a2                	ld	s3,8(sp)
    800020f0:	6145                	addi	sp,sp,48
    800020f2:	8082                	ret
    virtio_disk_rw(b, 0);
    800020f4:	4581                	li	a1,0
    800020f6:	8526                	mv	a0,s1
    800020f8:	0d3020ef          	jal	ra,800049ca <virtio_disk_rw>
    b->valid = 1;
    800020fc:	4785                	li	a5,1
    800020fe:	c09c                	sw	a5,0(s1)
  return b;
    80002100:	b7d5                	j	800020e4 <bread+0xb8>

0000000080002102 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002102:	1101                	addi	sp,sp,-32
    80002104:	ec06                	sd	ra,24(sp)
    80002106:	e822                	sd	s0,16(sp)
    80002108:	e426                	sd	s1,8(sp)
    8000210a:	1000                	addi	s0,sp,32
    8000210c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000210e:	0541                	addi	a0,a0,16
    80002110:	1d2010ef          	jal	ra,800032e2 <holdingsleep>
    80002114:	c911                	beqz	a0,80002128 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002116:	4585                	li	a1,1
    80002118:	8526                	mv	a0,s1
    8000211a:	0b1020ef          	jal	ra,800049ca <virtio_disk_rw>
}
    8000211e:	60e2                	ld	ra,24(sp)
    80002120:	6442                	ld	s0,16(sp)
    80002122:	64a2                	ld	s1,8(sp)
    80002124:	6105                	addi	sp,sp,32
    80002126:	8082                	ret
    panic("bwrite");
    80002128:	00005517          	auipc	a0,0x5
    8000212c:	47850513          	addi	a0,a0,1144 # 800075a0 <syscalls+0x140>
    80002130:	292030ef          	jal	ra,800053c2 <panic>

0000000080002134 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002134:	1101                	addi	sp,sp,-32
    80002136:	ec06                	sd	ra,24(sp)
    80002138:	e822                	sd	s0,16(sp)
    8000213a:	e426                	sd	s1,8(sp)
    8000213c:	e04a                	sd	s2,0(sp)
    8000213e:	1000                	addi	s0,sp,32
    80002140:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002142:	01050913          	addi	s2,a0,16
    80002146:	854a                	mv	a0,s2
    80002148:	19a010ef          	jal	ra,800032e2 <holdingsleep>
    8000214c:	c13d                	beqz	a0,800021b2 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    8000214e:	854a                	mv	a0,s2
    80002150:	15a010ef          	jal	ra,800032aa <releasesleep>

  acquire(&bcache.lock);
    80002154:	0000b517          	auipc	a0,0xb
    80002158:	6e450513          	addi	a0,a0,1764 # 8000d838 <bcache>
    8000215c:	576030ef          	jal	ra,800056d2 <acquire>
  b->refcnt--;
    80002160:	40bc                	lw	a5,64(s1)
    80002162:	37fd                	addiw	a5,a5,-1
    80002164:	0007871b          	sext.w	a4,a5
    80002168:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000216a:	eb05                	bnez	a4,8000219a <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000216c:	68bc                	ld	a5,80(s1)
    8000216e:	64b8                	ld	a4,72(s1)
    80002170:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002172:	64bc                	ld	a5,72(s1)
    80002174:	68b8                	ld	a4,80(s1)
    80002176:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002178:	00013797          	auipc	a5,0x13
    8000217c:	6c078793          	addi	a5,a5,1728 # 80015838 <bcache+0x8000>
    80002180:	2b87b703          	ld	a4,696(a5)
    80002184:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002186:	00014717          	auipc	a4,0x14
    8000218a:	91a70713          	addi	a4,a4,-1766 # 80015aa0 <bcache+0x8268>
    8000218e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002190:	2b87b703          	ld	a4,696(a5)
    80002194:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002196:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    8000219a:	0000b517          	auipc	a0,0xb
    8000219e:	69e50513          	addi	a0,a0,1694 # 8000d838 <bcache>
    800021a2:	5c8030ef          	jal	ra,8000576a <release>
}
    800021a6:	60e2                	ld	ra,24(sp)
    800021a8:	6442                	ld	s0,16(sp)
    800021aa:	64a2                	ld	s1,8(sp)
    800021ac:	6902                	ld	s2,0(sp)
    800021ae:	6105                	addi	sp,sp,32
    800021b0:	8082                	ret
    panic("brelse");
    800021b2:	00005517          	auipc	a0,0x5
    800021b6:	3f650513          	addi	a0,a0,1014 # 800075a8 <syscalls+0x148>
    800021ba:	208030ef          	jal	ra,800053c2 <panic>

00000000800021be <bpin>:

void
bpin(struct buf *b) {
    800021be:	1101                	addi	sp,sp,-32
    800021c0:	ec06                	sd	ra,24(sp)
    800021c2:	e822                	sd	s0,16(sp)
    800021c4:	e426                	sd	s1,8(sp)
    800021c6:	1000                	addi	s0,sp,32
    800021c8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800021ca:	0000b517          	auipc	a0,0xb
    800021ce:	66e50513          	addi	a0,a0,1646 # 8000d838 <bcache>
    800021d2:	500030ef          	jal	ra,800056d2 <acquire>
  b->refcnt++;
    800021d6:	40bc                	lw	a5,64(s1)
    800021d8:	2785                	addiw	a5,a5,1
    800021da:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800021dc:	0000b517          	auipc	a0,0xb
    800021e0:	65c50513          	addi	a0,a0,1628 # 8000d838 <bcache>
    800021e4:	586030ef          	jal	ra,8000576a <release>
}
    800021e8:	60e2                	ld	ra,24(sp)
    800021ea:	6442                	ld	s0,16(sp)
    800021ec:	64a2                	ld	s1,8(sp)
    800021ee:	6105                	addi	sp,sp,32
    800021f0:	8082                	ret

00000000800021f2 <bunpin>:

void
bunpin(struct buf *b) {
    800021f2:	1101                	addi	sp,sp,-32
    800021f4:	ec06                	sd	ra,24(sp)
    800021f6:	e822                	sd	s0,16(sp)
    800021f8:	e426                	sd	s1,8(sp)
    800021fa:	1000                	addi	s0,sp,32
    800021fc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800021fe:	0000b517          	auipc	a0,0xb
    80002202:	63a50513          	addi	a0,a0,1594 # 8000d838 <bcache>
    80002206:	4cc030ef          	jal	ra,800056d2 <acquire>
  b->refcnt--;
    8000220a:	40bc                	lw	a5,64(s1)
    8000220c:	37fd                	addiw	a5,a5,-1
    8000220e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002210:	0000b517          	auipc	a0,0xb
    80002214:	62850513          	addi	a0,a0,1576 # 8000d838 <bcache>
    80002218:	552030ef          	jal	ra,8000576a <release>
}
    8000221c:	60e2                	ld	ra,24(sp)
    8000221e:	6442                	ld	s0,16(sp)
    80002220:	64a2                	ld	s1,8(sp)
    80002222:	6105                	addi	sp,sp,32
    80002224:	8082                	ret

0000000080002226 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002226:	1101                	addi	sp,sp,-32
    80002228:	ec06                	sd	ra,24(sp)
    8000222a:	e822                	sd	s0,16(sp)
    8000222c:	e426                	sd	s1,8(sp)
    8000222e:	e04a                	sd	s2,0(sp)
    80002230:	1000                	addi	s0,sp,32
    80002232:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002234:	00d5d59b          	srliw	a1,a1,0xd
    80002238:	00014797          	auipc	a5,0x14
    8000223c:	cdc7a783          	lw	a5,-804(a5) # 80015f14 <sb+0x1c>
    80002240:	9dbd                	addw	a1,a1,a5
    80002242:	debff0ef          	jal	ra,8000202c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002246:	0074f713          	andi	a4,s1,7
    8000224a:	4785                	li	a5,1
    8000224c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002250:	14ce                	slli	s1,s1,0x33
    80002252:	90d9                	srli	s1,s1,0x36
    80002254:	00950733          	add	a4,a0,s1
    80002258:	05874703          	lbu	a4,88(a4)
    8000225c:	00e7f6b3          	and	a3,a5,a4
    80002260:	c29d                	beqz	a3,80002286 <bfree+0x60>
    80002262:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002264:	94aa                	add	s1,s1,a0
    80002266:	fff7c793          	not	a5,a5
    8000226a:	8f7d                	and	a4,a4,a5
    8000226c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002270:	6ef000ef          	jal	ra,8000315e <log_write>
  brelse(bp);
    80002274:	854a                	mv	a0,s2
    80002276:	ebfff0ef          	jal	ra,80002134 <brelse>
}
    8000227a:	60e2                	ld	ra,24(sp)
    8000227c:	6442                	ld	s0,16(sp)
    8000227e:	64a2                	ld	s1,8(sp)
    80002280:	6902                	ld	s2,0(sp)
    80002282:	6105                	addi	sp,sp,32
    80002284:	8082                	ret
    panic("freeing free block");
    80002286:	00005517          	auipc	a0,0x5
    8000228a:	32a50513          	addi	a0,a0,810 # 800075b0 <syscalls+0x150>
    8000228e:	134030ef          	jal	ra,800053c2 <panic>

0000000080002292 <balloc>:
{
    80002292:	711d                	addi	sp,sp,-96
    80002294:	ec86                	sd	ra,88(sp)
    80002296:	e8a2                	sd	s0,80(sp)
    80002298:	e4a6                	sd	s1,72(sp)
    8000229a:	e0ca                	sd	s2,64(sp)
    8000229c:	fc4e                	sd	s3,56(sp)
    8000229e:	f852                	sd	s4,48(sp)
    800022a0:	f456                	sd	s5,40(sp)
    800022a2:	f05a                	sd	s6,32(sp)
    800022a4:	ec5e                	sd	s7,24(sp)
    800022a6:	e862                	sd	s8,16(sp)
    800022a8:	e466                	sd	s9,8(sp)
    800022aa:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800022ac:	00014797          	auipc	a5,0x14
    800022b0:	c507a783          	lw	a5,-944(a5) # 80015efc <sb+0x4>
    800022b4:	cff1                	beqz	a5,80002390 <balloc+0xfe>
    800022b6:	8baa                	mv	s7,a0
    800022b8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800022ba:	00014b17          	auipc	s6,0x14
    800022be:	c3eb0b13          	addi	s6,s6,-962 # 80015ef8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800022c2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800022c4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800022c6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800022c8:	6c89                	lui	s9,0x2
    800022ca:	a0b5                	j	80002336 <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    800022cc:	97ca                	add	a5,a5,s2
    800022ce:	8e55                	or	a2,a2,a3
    800022d0:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800022d4:	854a                	mv	a0,s2
    800022d6:	689000ef          	jal	ra,8000315e <log_write>
        brelse(bp);
    800022da:	854a                	mv	a0,s2
    800022dc:	e59ff0ef          	jal	ra,80002134 <brelse>
  bp = bread(dev, bno);
    800022e0:	85a6                	mv	a1,s1
    800022e2:	855e                	mv	a0,s7
    800022e4:	d49ff0ef          	jal	ra,8000202c <bread>
    800022e8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800022ea:	40000613          	li	a2,1024
    800022ee:	4581                	li	a1,0
    800022f0:	05850513          	addi	a0,a0,88
    800022f4:	e5bfd0ef          	jal	ra,8000014e <memset>
  log_write(bp);
    800022f8:	854a                	mv	a0,s2
    800022fa:	665000ef          	jal	ra,8000315e <log_write>
  brelse(bp);
    800022fe:	854a                	mv	a0,s2
    80002300:	e35ff0ef          	jal	ra,80002134 <brelse>
}
    80002304:	8526                	mv	a0,s1
    80002306:	60e6                	ld	ra,88(sp)
    80002308:	6446                	ld	s0,80(sp)
    8000230a:	64a6                	ld	s1,72(sp)
    8000230c:	6906                	ld	s2,64(sp)
    8000230e:	79e2                	ld	s3,56(sp)
    80002310:	7a42                	ld	s4,48(sp)
    80002312:	7aa2                	ld	s5,40(sp)
    80002314:	7b02                	ld	s6,32(sp)
    80002316:	6be2                	ld	s7,24(sp)
    80002318:	6c42                	ld	s8,16(sp)
    8000231a:	6ca2                	ld	s9,8(sp)
    8000231c:	6125                	addi	sp,sp,96
    8000231e:	8082                	ret
    brelse(bp);
    80002320:	854a                	mv	a0,s2
    80002322:	e13ff0ef          	jal	ra,80002134 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002326:	015c87bb          	addw	a5,s9,s5
    8000232a:	00078a9b          	sext.w	s5,a5
    8000232e:	004b2703          	lw	a4,4(s6)
    80002332:	04eaff63          	bgeu	s5,a4,80002390 <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    80002336:	41fad79b          	sraiw	a5,s5,0x1f
    8000233a:	0137d79b          	srliw	a5,a5,0x13
    8000233e:	015787bb          	addw	a5,a5,s5
    80002342:	40d7d79b          	sraiw	a5,a5,0xd
    80002346:	01cb2583          	lw	a1,28(s6)
    8000234a:	9dbd                	addw	a1,a1,a5
    8000234c:	855e                	mv	a0,s7
    8000234e:	cdfff0ef          	jal	ra,8000202c <bread>
    80002352:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002354:	004b2503          	lw	a0,4(s6)
    80002358:	000a849b          	sext.w	s1,s5
    8000235c:	8762                	mv	a4,s8
    8000235e:	fca4f1e3          	bgeu	s1,a0,80002320 <balloc+0x8e>
      m = 1 << (bi % 8);
    80002362:	00777693          	andi	a3,a4,7
    80002366:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000236a:	41f7579b          	sraiw	a5,a4,0x1f
    8000236e:	01d7d79b          	srliw	a5,a5,0x1d
    80002372:	9fb9                	addw	a5,a5,a4
    80002374:	4037d79b          	sraiw	a5,a5,0x3
    80002378:	00f90633          	add	a2,s2,a5
    8000237c:	05864603          	lbu	a2,88(a2)
    80002380:	00c6f5b3          	and	a1,a3,a2
    80002384:	d5a1                	beqz	a1,800022cc <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002386:	2705                	addiw	a4,a4,1
    80002388:	2485                	addiw	s1,s1,1
    8000238a:	fd471ae3          	bne	a4,s4,8000235e <balloc+0xcc>
    8000238e:	bf49                	j	80002320 <balloc+0x8e>
  printf("balloc: out of blocks\n");
    80002390:	00005517          	auipc	a0,0x5
    80002394:	23850513          	addi	a0,a0,568 # 800075c8 <syscalls+0x168>
    80002398:	577020ef          	jal	ra,8000510e <printf>
  return 0;
    8000239c:	4481                	li	s1,0
    8000239e:	b79d                	j	80002304 <balloc+0x72>

00000000800023a0 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800023a0:	7179                	addi	sp,sp,-48
    800023a2:	f406                	sd	ra,40(sp)
    800023a4:	f022                	sd	s0,32(sp)
    800023a6:	ec26                	sd	s1,24(sp)
    800023a8:	e84a                	sd	s2,16(sp)
    800023aa:	e44e                	sd	s3,8(sp)
    800023ac:	e052                	sd	s4,0(sp)
    800023ae:	1800                	addi	s0,sp,48
    800023b0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800023b2:	47ad                	li	a5,11
    800023b4:	02b7e663          	bltu	a5,a1,800023e0 <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    800023b8:	02059793          	slli	a5,a1,0x20
    800023bc:	01e7d593          	srli	a1,a5,0x1e
    800023c0:	00b504b3          	add	s1,a0,a1
    800023c4:	0504a903          	lw	s2,80(s1)
    800023c8:	06091663          	bnez	s2,80002434 <bmap+0x94>
      addr = balloc(ip->dev);
    800023cc:	4108                	lw	a0,0(a0)
    800023ce:	ec5ff0ef          	jal	ra,80002292 <balloc>
    800023d2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800023d6:	04090f63          	beqz	s2,80002434 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    800023da:	0524a823          	sw	s2,80(s1)
    800023de:	a899                	j	80002434 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    800023e0:	ff45849b          	addiw	s1,a1,-12
    800023e4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800023e8:	0ff00793          	li	a5,255
    800023ec:	06e7eb63          	bltu	a5,a4,80002462 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800023f0:	08052903          	lw	s2,128(a0)
    800023f4:	00091b63          	bnez	s2,8000240a <bmap+0x6a>
      addr = balloc(ip->dev);
    800023f8:	4108                	lw	a0,0(a0)
    800023fa:	e99ff0ef          	jal	ra,80002292 <balloc>
    800023fe:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002402:	02090963          	beqz	s2,80002434 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002406:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000240a:	85ca                	mv	a1,s2
    8000240c:	0009a503          	lw	a0,0(s3)
    80002410:	c1dff0ef          	jal	ra,8000202c <bread>
    80002414:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002416:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000241a:	02049713          	slli	a4,s1,0x20
    8000241e:	01e75593          	srli	a1,a4,0x1e
    80002422:	00b784b3          	add	s1,a5,a1
    80002426:	0004a903          	lw	s2,0(s1)
    8000242a:	00090e63          	beqz	s2,80002446 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000242e:	8552                	mv	a0,s4
    80002430:	d05ff0ef          	jal	ra,80002134 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002434:	854a                	mv	a0,s2
    80002436:	70a2                	ld	ra,40(sp)
    80002438:	7402                	ld	s0,32(sp)
    8000243a:	64e2                	ld	s1,24(sp)
    8000243c:	6942                	ld	s2,16(sp)
    8000243e:	69a2                	ld	s3,8(sp)
    80002440:	6a02                	ld	s4,0(sp)
    80002442:	6145                	addi	sp,sp,48
    80002444:	8082                	ret
      addr = balloc(ip->dev);
    80002446:	0009a503          	lw	a0,0(s3)
    8000244a:	e49ff0ef          	jal	ra,80002292 <balloc>
    8000244e:	0005091b          	sext.w	s2,a0
      if(addr){
    80002452:	fc090ee3          	beqz	s2,8000242e <bmap+0x8e>
        a[bn] = addr;
    80002456:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000245a:	8552                	mv	a0,s4
    8000245c:	503000ef          	jal	ra,8000315e <log_write>
    80002460:	b7f9                	j	8000242e <bmap+0x8e>
  panic("bmap: out of range");
    80002462:	00005517          	auipc	a0,0x5
    80002466:	17e50513          	addi	a0,a0,382 # 800075e0 <syscalls+0x180>
    8000246a:	759020ef          	jal	ra,800053c2 <panic>

000000008000246e <iget>:
{
    8000246e:	7179                	addi	sp,sp,-48
    80002470:	f406                	sd	ra,40(sp)
    80002472:	f022                	sd	s0,32(sp)
    80002474:	ec26                	sd	s1,24(sp)
    80002476:	e84a                	sd	s2,16(sp)
    80002478:	e44e                	sd	s3,8(sp)
    8000247a:	e052                	sd	s4,0(sp)
    8000247c:	1800                	addi	s0,sp,48
    8000247e:	89aa                	mv	s3,a0
    80002480:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002482:	00014517          	auipc	a0,0x14
    80002486:	a9650513          	addi	a0,a0,-1386 # 80015f18 <itable>
    8000248a:	248030ef          	jal	ra,800056d2 <acquire>
  empty = 0;
    8000248e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002490:	00014497          	auipc	s1,0x14
    80002494:	aa048493          	addi	s1,s1,-1376 # 80015f30 <itable+0x18>
    80002498:	00015697          	auipc	a3,0x15
    8000249c:	52868693          	addi	a3,a3,1320 # 800179c0 <log>
    800024a0:	a039                	j	800024ae <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800024a2:	02090963          	beqz	s2,800024d4 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800024a6:	08848493          	addi	s1,s1,136
    800024aa:	02d48863          	beq	s1,a3,800024da <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800024ae:	449c                	lw	a5,8(s1)
    800024b0:	fef059e3          	blez	a5,800024a2 <iget+0x34>
    800024b4:	4098                	lw	a4,0(s1)
    800024b6:	ff3716e3          	bne	a4,s3,800024a2 <iget+0x34>
    800024ba:	40d8                	lw	a4,4(s1)
    800024bc:	ff4713e3          	bne	a4,s4,800024a2 <iget+0x34>
      ip->ref++;
    800024c0:	2785                	addiw	a5,a5,1
    800024c2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800024c4:	00014517          	auipc	a0,0x14
    800024c8:	a5450513          	addi	a0,a0,-1452 # 80015f18 <itable>
    800024cc:	29e030ef          	jal	ra,8000576a <release>
      return ip;
    800024d0:	8926                	mv	s2,s1
    800024d2:	a02d                	j	800024fc <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800024d4:	fbe9                	bnez	a5,800024a6 <iget+0x38>
    800024d6:	8926                	mv	s2,s1
    800024d8:	b7f9                	j	800024a6 <iget+0x38>
  if(empty == 0)
    800024da:	02090a63          	beqz	s2,8000250e <iget+0xa0>
  ip->dev = dev;
    800024de:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800024e2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800024e6:	4785                	li	a5,1
    800024e8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800024ec:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800024f0:	00014517          	auipc	a0,0x14
    800024f4:	a2850513          	addi	a0,a0,-1496 # 80015f18 <itable>
    800024f8:	272030ef          	jal	ra,8000576a <release>
}
    800024fc:	854a                	mv	a0,s2
    800024fe:	70a2                	ld	ra,40(sp)
    80002500:	7402                	ld	s0,32(sp)
    80002502:	64e2                	ld	s1,24(sp)
    80002504:	6942                	ld	s2,16(sp)
    80002506:	69a2                	ld	s3,8(sp)
    80002508:	6a02                	ld	s4,0(sp)
    8000250a:	6145                	addi	sp,sp,48
    8000250c:	8082                	ret
    panic("iget: no inodes");
    8000250e:	00005517          	auipc	a0,0x5
    80002512:	0ea50513          	addi	a0,a0,234 # 800075f8 <syscalls+0x198>
    80002516:	6ad020ef          	jal	ra,800053c2 <panic>

000000008000251a <fsinit>:
fsinit(int dev) {
    8000251a:	7179                	addi	sp,sp,-48
    8000251c:	f406                	sd	ra,40(sp)
    8000251e:	f022                	sd	s0,32(sp)
    80002520:	ec26                	sd	s1,24(sp)
    80002522:	e84a                	sd	s2,16(sp)
    80002524:	e44e                	sd	s3,8(sp)
    80002526:	1800                	addi	s0,sp,48
    80002528:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000252a:	4585                	li	a1,1
    8000252c:	b01ff0ef          	jal	ra,8000202c <bread>
    80002530:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002532:	00014997          	auipc	s3,0x14
    80002536:	9c698993          	addi	s3,s3,-1594 # 80015ef8 <sb>
    8000253a:	02000613          	li	a2,32
    8000253e:	05850593          	addi	a1,a0,88
    80002542:	854e                	mv	a0,s3
    80002544:	c67fd0ef          	jal	ra,800001aa <memmove>
  brelse(bp);
    80002548:	8526                	mv	a0,s1
    8000254a:	bebff0ef          	jal	ra,80002134 <brelse>
  if(sb.magic != FSMAGIC)
    8000254e:	0009a703          	lw	a4,0(s3)
    80002552:	102037b7          	lui	a5,0x10203
    80002556:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000255a:	02f71063          	bne	a4,a5,8000257a <fsinit+0x60>
  initlog(dev, &sb);
    8000255e:	00014597          	auipc	a1,0x14
    80002562:	99a58593          	addi	a1,a1,-1638 # 80015ef8 <sb>
    80002566:	854a                	mv	a0,s2
    80002568:	1e3000ef          	jal	ra,80002f4a <initlog>
}
    8000256c:	70a2                	ld	ra,40(sp)
    8000256e:	7402                	ld	s0,32(sp)
    80002570:	64e2                	ld	s1,24(sp)
    80002572:	6942                	ld	s2,16(sp)
    80002574:	69a2                	ld	s3,8(sp)
    80002576:	6145                	addi	sp,sp,48
    80002578:	8082                	ret
    panic("invalid file system");
    8000257a:	00005517          	auipc	a0,0x5
    8000257e:	08e50513          	addi	a0,a0,142 # 80007608 <syscalls+0x1a8>
    80002582:	641020ef          	jal	ra,800053c2 <panic>

0000000080002586 <iinit>:
{
    80002586:	7179                	addi	sp,sp,-48
    80002588:	f406                	sd	ra,40(sp)
    8000258a:	f022                	sd	s0,32(sp)
    8000258c:	ec26                	sd	s1,24(sp)
    8000258e:	e84a                	sd	s2,16(sp)
    80002590:	e44e                	sd	s3,8(sp)
    80002592:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002594:	00005597          	auipc	a1,0x5
    80002598:	08c58593          	addi	a1,a1,140 # 80007620 <syscalls+0x1c0>
    8000259c:	00014517          	auipc	a0,0x14
    800025a0:	97c50513          	addi	a0,a0,-1668 # 80015f18 <itable>
    800025a4:	0ae030ef          	jal	ra,80005652 <initlock>
  for(i = 0; i < NINODE; i++) {
    800025a8:	00014497          	auipc	s1,0x14
    800025ac:	99848493          	addi	s1,s1,-1640 # 80015f40 <itable+0x28>
    800025b0:	00015997          	auipc	s3,0x15
    800025b4:	42098993          	addi	s3,s3,1056 # 800179d0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800025b8:	00005917          	auipc	s2,0x5
    800025bc:	07090913          	addi	s2,s2,112 # 80007628 <syscalls+0x1c8>
    800025c0:	85ca                	mv	a1,s2
    800025c2:	8526                	mv	a0,s1
    800025c4:	46b000ef          	jal	ra,8000322e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800025c8:	08848493          	addi	s1,s1,136
    800025cc:	ff349ae3          	bne	s1,s3,800025c0 <iinit+0x3a>
}
    800025d0:	70a2                	ld	ra,40(sp)
    800025d2:	7402                	ld	s0,32(sp)
    800025d4:	64e2                	ld	s1,24(sp)
    800025d6:	6942                	ld	s2,16(sp)
    800025d8:	69a2                	ld	s3,8(sp)
    800025da:	6145                	addi	sp,sp,48
    800025dc:	8082                	ret

00000000800025de <ialloc>:
{
    800025de:	715d                	addi	sp,sp,-80
    800025e0:	e486                	sd	ra,72(sp)
    800025e2:	e0a2                	sd	s0,64(sp)
    800025e4:	fc26                	sd	s1,56(sp)
    800025e6:	f84a                	sd	s2,48(sp)
    800025e8:	f44e                	sd	s3,40(sp)
    800025ea:	f052                	sd	s4,32(sp)
    800025ec:	ec56                	sd	s5,24(sp)
    800025ee:	e85a                	sd	s6,16(sp)
    800025f0:	e45e                	sd	s7,8(sp)
    800025f2:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800025f4:	00014717          	auipc	a4,0x14
    800025f8:	91072703          	lw	a4,-1776(a4) # 80015f04 <sb+0xc>
    800025fc:	4785                	li	a5,1
    800025fe:	04e7f663          	bgeu	a5,a4,8000264a <ialloc+0x6c>
    80002602:	8aaa                	mv	s5,a0
    80002604:	8bae                	mv	s7,a1
    80002606:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002608:	00014a17          	auipc	s4,0x14
    8000260c:	8f0a0a13          	addi	s4,s4,-1808 # 80015ef8 <sb>
    80002610:	00048b1b          	sext.w	s6,s1
    80002614:	0044d593          	srli	a1,s1,0x4
    80002618:	018a2783          	lw	a5,24(s4)
    8000261c:	9dbd                	addw	a1,a1,a5
    8000261e:	8556                	mv	a0,s5
    80002620:	a0dff0ef          	jal	ra,8000202c <bread>
    80002624:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002626:	05850993          	addi	s3,a0,88
    8000262a:	00f4f793          	andi	a5,s1,15
    8000262e:	079a                	slli	a5,a5,0x6
    80002630:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002632:	00099783          	lh	a5,0(s3)
    80002636:	cf85                	beqz	a5,8000266e <ialloc+0x90>
    brelse(bp);
    80002638:	afdff0ef          	jal	ra,80002134 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000263c:	0485                	addi	s1,s1,1
    8000263e:	00ca2703          	lw	a4,12(s4)
    80002642:	0004879b          	sext.w	a5,s1
    80002646:	fce7e5e3          	bltu	a5,a4,80002610 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000264a:	00005517          	auipc	a0,0x5
    8000264e:	fe650513          	addi	a0,a0,-26 # 80007630 <syscalls+0x1d0>
    80002652:	2bd020ef          	jal	ra,8000510e <printf>
  return 0;
    80002656:	4501                	li	a0,0
}
    80002658:	60a6                	ld	ra,72(sp)
    8000265a:	6406                	ld	s0,64(sp)
    8000265c:	74e2                	ld	s1,56(sp)
    8000265e:	7942                	ld	s2,48(sp)
    80002660:	79a2                	ld	s3,40(sp)
    80002662:	7a02                	ld	s4,32(sp)
    80002664:	6ae2                	ld	s5,24(sp)
    80002666:	6b42                	ld	s6,16(sp)
    80002668:	6ba2                	ld	s7,8(sp)
    8000266a:	6161                	addi	sp,sp,80
    8000266c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000266e:	04000613          	li	a2,64
    80002672:	4581                	li	a1,0
    80002674:	854e                	mv	a0,s3
    80002676:	ad9fd0ef          	jal	ra,8000014e <memset>
      dip->type = type;
    8000267a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000267e:	854a                	mv	a0,s2
    80002680:	2df000ef          	jal	ra,8000315e <log_write>
      brelse(bp);
    80002684:	854a                	mv	a0,s2
    80002686:	aafff0ef          	jal	ra,80002134 <brelse>
      return iget(dev, inum);
    8000268a:	85da                	mv	a1,s6
    8000268c:	8556                	mv	a0,s5
    8000268e:	de1ff0ef          	jal	ra,8000246e <iget>
    80002692:	b7d9                	j	80002658 <ialloc+0x7a>

0000000080002694 <iupdate>:
{
    80002694:	1101                	addi	sp,sp,-32
    80002696:	ec06                	sd	ra,24(sp)
    80002698:	e822                	sd	s0,16(sp)
    8000269a:	e426                	sd	s1,8(sp)
    8000269c:	e04a                	sd	s2,0(sp)
    8000269e:	1000                	addi	s0,sp,32
    800026a0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800026a2:	415c                	lw	a5,4(a0)
    800026a4:	0047d79b          	srliw	a5,a5,0x4
    800026a8:	00014597          	auipc	a1,0x14
    800026ac:	8685a583          	lw	a1,-1944(a1) # 80015f10 <sb+0x18>
    800026b0:	9dbd                	addw	a1,a1,a5
    800026b2:	4108                	lw	a0,0(a0)
    800026b4:	979ff0ef          	jal	ra,8000202c <bread>
    800026b8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800026ba:	05850793          	addi	a5,a0,88
    800026be:	40d8                	lw	a4,4(s1)
    800026c0:	8b3d                	andi	a4,a4,15
    800026c2:	071a                	slli	a4,a4,0x6
    800026c4:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800026c6:	04449703          	lh	a4,68(s1)
    800026ca:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800026ce:	04649703          	lh	a4,70(s1)
    800026d2:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800026d6:	04849703          	lh	a4,72(s1)
    800026da:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800026de:	04a49703          	lh	a4,74(s1)
    800026e2:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800026e6:	44f8                	lw	a4,76(s1)
    800026e8:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800026ea:	03400613          	li	a2,52
    800026ee:	05048593          	addi	a1,s1,80
    800026f2:	00c78513          	addi	a0,a5,12
    800026f6:	ab5fd0ef          	jal	ra,800001aa <memmove>
  log_write(bp);
    800026fa:	854a                	mv	a0,s2
    800026fc:	263000ef          	jal	ra,8000315e <log_write>
  brelse(bp);
    80002700:	854a                	mv	a0,s2
    80002702:	a33ff0ef          	jal	ra,80002134 <brelse>
}
    80002706:	60e2                	ld	ra,24(sp)
    80002708:	6442                	ld	s0,16(sp)
    8000270a:	64a2                	ld	s1,8(sp)
    8000270c:	6902                	ld	s2,0(sp)
    8000270e:	6105                	addi	sp,sp,32
    80002710:	8082                	ret

0000000080002712 <idup>:
{
    80002712:	1101                	addi	sp,sp,-32
    80002714:	ec06                	sd	ra,24(sp)
    80002716:	e822                	sd	s0,16(sp)
    80002718:	e426                	sd	s1,8(sp)
    8000271a:	1000                	addi	s0,sp,32
    8000271c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000271e:	00013517          	auipc	a0,0x13
    80002722:	7fa50513          	addi	a0,a0,2042 # 80015f18 <itable>
    80002726:	7ad020ef          	jal	ra,800056d2 <acquire>
  ip->ref++;
    8000272a:	449c                	lw	a5,8(s1)
    8000272c:	2785                	addiw	a5,a5,1
    8000272e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002730:	00013517          	auipc	a0,0x13
    80002734:	7e850513          	addi	a0,a0,2024 # 80015f18 <itable>
    80002738:	032030ef          	jal	ra,8000576a <release>
}
    8000273c:	8526                	mv	a0,s1
    8000273e:	60e2                	ld	ra,24(sp)
    80002740:	6442                	ld	s0,16(sp)
    80002742:	64a2                	ld	s1,8(sp)
    80002744:	6105                	addi	sp,sp,32
    80002746:	8082                	ret

0000000080002748 <ilock>:
{
    80002748:	1101                	addi	sp,sp,-32
    8000274a:	ec06                	sd	ra,24(sp)
    8000274c:	e822                	sd	s0,16(sp)
    8000274e:	e426                	sd	s1,8(sp)
    80002750:	e04a                	sd	s2,0(sp)
    80002752:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002754:	c105                	beqz	a0,80002774 <ilock+0x2c>
    80002756:	84aa                	mv	s1,a0
    80002758:	451c                	lw	a5,8(a0)
    8000275a:	00f05d63          	blez	a5,80002774 <ilock+0x2c>
  acquiresleep(&ip->lock);
    8000275e:	0541                	addi	a0,a0,16
    80002760:	305000ef          	jal	ra,80003264 <acquiresleep>
  if(ip->valid == 0){
    80002764:	40bc                	lw	a5,64(s1)
    80002766:	cf89                	beqz	a5,80002780 <ilock+0x38>
}
    80002768:	60e2                	ld	ra,24(sp)
    8000276a:	6442                	ld	s0,16(sp)
    8000276c:	64a2                	ld	s1,8(sp)
    8000276e:	6902                	ld	s2,0(sp)
    80002770:	6105                	addi	sp,sp,32
    80002772:	8082                	ret
    panic("ilock");
    80002774:	00005517          	auipc	a0,0x5
    80002778:	ed450513          	addi	a0,a0,-300 # 80007648 <syscalls+0x1e8>
    8000277c:	447020ef          	jal	ra,800053c2 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002780:	40dc                	lw	a5,4(s1)
    80002782:	0047d79b          	srliw	a5,a5,0x4
    80002786:	00013597          	auipc	a1,0x13
    8000278a:	78a5a583          	lw	a1,1930(a1) # 80015f10 <sb+0x18>
    8000278e:	9dbd                	addw	a1,a1,a5
    80002790:	4088                	lw	a0,0(s1)
    80002792:	89bff0ef          	jal	ra,8000202c <bread>
    80002796:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002798:	05850593          	addi	a1,a0,88
    8000279c:	40dc                	lw	a5,4(s1)
    8000279e:	8bbd                	andi	a5,a5,15
    800027a0:	079a                	slli	a5,a5,0x6
    800027a2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800027a4:	00059783          	lh	a5,0(a1)
    800027a8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800027ac:	00259783          	lh	a5,2(a1)
    800027b0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800027b4:	00459783          	lh	a5,4(a1)
    800027b8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800027bc:	00659783          	lh	a5,6(a1)
    800027c0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800027c4:	459c                	lw	a5,8(a1)
    800027c6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800027c8:	03400613          	li	a2,52
    800027cc:	05b1                	addi	a1,a1,12
    800027ce:	05048513          	addi	a0,s1,80
    800027d2:	9d9fd0ef          	jal	ra,800001aa <memmove>
    brelse(bp);
    800027d6:	854a                	mv	a0,s2
    800027d8:	95dff0ef          	jal	ra,80002134 <brelse>
    ip->valid = 1;
    800027dc:	4785                	li	a5,1
    800027de:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800027e0:	04449783          	lh	a5,68(s1)
    800027e4:	f3d1                	bnez	a5,80002768 <ilock+0x20>
      panic("ilock: no type");
    800027e6:	00005517          	auipc	a0,0x5
    800027ea:	e6a50513          	addi	a0,a0,-406 # 80007650 <syscalls+0x1f0>
    800027ee:	3d5020ef          	jal	ra,800053c2 <panic>

00000000800027f2 <iunlock>:
{
    800027f2:	1101                	addi	sp,sp,-32
    800027f4:	ec06                	sd	ra,24(sp)
    800027f6:	e822                	sd	s0,16(sp)
    800027f8:	e426                	sd	s1,8(sp)
    800027fa:	e04a                	sd	s2,0(sp)
    800027fc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800027fe:	c505                	beqz	a0,80002826 <iunlock+0x34>
    80002800:	84aa                	mv	s1,a0
    80002802:	01050913          	addi	s2,a0,16
    80002806:	854a                	mv	a0,s2
    80002808:	2db000ef          	jal	ra,800032e2 <holdingsleep>
    8000280c:	cd09                	beqz	a0,80002826 <iunlock+0x34>
    8000280e:	449c                	lw	a5,8(s1)
    80002810:	00f05b63          	blez	a5,80002826 <iunlock+0x34>
  releasesleep(&ip->lock);
    80002814:	854a                	mv	a0,s2
    80002816:	295000ef          	jal	ra,800032aa <releasesleep>
}
    8000281a:	60e2                	ld	ra,24(sp)
    8000281c:	6442                	ld	s0,16(sp)
    8000281e:	64a2                	ld	s1,8(sp)
    80002820:	6902                	ld	s2,0(sp)
    80002822:	6105                	addi	sp,sp,32
    80002824:	8082                	ret
    panic("iunlock");
    80002826:	00005517          	auipc	a0,0x5
    8000282a:	e3a50513          	addi	a0,a0,-454 # 80007660 <syscalls+0x200>
    8000282e:	395020ef          	jal	ra,800053c2 <panic>

0000000080002832 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002832:	7179                	addi	sp,sp,-48
    80002834:	f406                	sd	ra,40(sp)
    80002836:	f022                	sd	s0,32(sp)
    80002838:	ec26                	sd	s1,24(sp)
    8000283a:	e84a                	sd	s2,16(sp)
    8000283c:	e44e                	sd	s3,8(sp)
    8000283e:	e052                	sd	s4,0(sp)
    80002840:	1800                	addi	s0,sp,48
    80002842:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002844:	05050493          	addi	s1,a0,80
    80002848:	08050913          	addi	s2,a0,128
    8000284c:	a021                	j	80002854 <itrunc+0x22>
    8000284e:	0491                	addi	s1,s1,4
    80002850:	01248b63          	beq	s1,s2,80002866 <itrunc+0x34>
    if(ip->addrs[i]){
    80002854:	408c                	lw	a1,0(s1)
    80002856:	dde5                	beqz	a1,8000284e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002858:	0009a503          	lw	a0,0(s3)
    8000285c:	9cbff0ef          	jal	ra,80002226 <bfree>
      ip->addrs[i] = 0;
    80002860:	0004a023          	sw	zero,0(s1)
    80002864:	b7ed                	j	8000284e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002866:	0809a583          	lw	a1,128(s3)
    8000286a:	ed91                	bnez	a1,80002886 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000286c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002870:	854e                	mv	a0,s3
    80002872:	e23ff0ef          	jal	ra,80002694 <iupdate>
}
    80002876:	70a2                	ld	ra,40(sp)
    80002878:	7402                	ld	s0,32(sp)
    8000287a:	64e2                	ld	s1,24(sp)
    8000287c:	6942                	ld	s2,16(sp)
    8000287e:	69a2                	ld	s3,8(sp)
    80002880:	6a02                	ld	s4,0(sp)
    80002882:	6145                	addi	sp,sp,48
    80002884:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002886:	0009a503          	lw	a0,0(s3)
    8000288a:	fa2ff0ef          	jal	ra,8000202c <bread>
    8000288e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002890:	05850493          	addi	s1,a0,88
    80002894:	45850913          	addi	s2,a0,1112
    80002898:	a021                	j	800028a0 <itrunc+0x6e>
    8000289a:	0491                	addi	s1,s1,4
    8000289c:	01248963          	beq	s1,s2,800028ae <itrunc+0x7c>
      if(a[j])
    800028a0:	408c                	lw	a1,0(s1)
    800028a2:	dde5                	beqz	a1,8000289a <itrunc+0x68>
        bfree(ip->dev, a[j]);
    800028a4:	0009a503          	lw	a0,0(s3)
    800028a8:	97fff0ef          	jal	ra,80002226 <bfree>
    800028ac:	b7fd                	j	8000289a <itrunc+0x68>
    brelse(bp);
    800028ae:	8552                	mv	a0,s4
    800028b0:	885ff0ef          	jal	ra,80002134 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800028b4:	0809a583          	lw	a1,128(s3)
    800028b8:	0009a503          	lw	a0,0(s3)
    800028bc:	96bff0ef          	jal	ra,80002226 <bfree>
    ip->addrs[NDIRECT] = 0;
    800028c0:	0809a023          	sw	zero,128(s3)
    800028c4:	b765                	j	8000286c <itrunc+0x3a>

00000000800028c6 <iput>:
{
    800028c6:	1101                	addi	sp,sp,-32
    800028c8:	ec06                	sd	ra,24(sp)
    800028ca:	e822                	sd	s0,16(sp)
    800028cc:	e426                	sd	s1,8(sp)
    800028ce:	e04a                	sd	s2,0(sp)
    800028d0:	1000                	addi	s0,sp,32
    800028d2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800028d4:	00013517          	auipc	a0,0x13
    800028d8:	64450513          	addi	a0,a0,1604 # 80015f18 <itable>
    800028dc:	5f7020ef          	jal	ra,800056d2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800028e0:	4498                	lw	a4,8(s1)
    800028e2:	4785                	li	a5,1
    800028e4:	02f70163          	beq	a4,a5,80002906 <iput+0x40>
  ip->ref--;
    800028e8:	449c                	lw	a5,8(s1)
    800028ea:	37fd                	addiw	a5,a5,-1
    800028ec:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800028ee:	00013517          	auipc	a0,0x13
    800028f2:	62a50513          	addi	a0,a0,1578 # 80015f18 <itable>
    800028f6:	675020ef          	jal	ra,8000576a <release>
}
    800028fa:	60e2                	ld	ra,24(sp)
    800028fc:	6442                	ld	s0,16(sp)
    800028fe:	64a2                	ld	s1,8(sp)
    80002900:	6902                	ld	s2,0(sp)
    80002902:	6105                	addi	sp,sp,32
    80002904:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002906:	40bc                	lw	a5,64(s1)
    80002908:	d3e5                	beqz	a5,800028e8 <iput+0x22>
    8000290a:	04a49783          	lh	a5,74(s1)
    8000290e:	ffe9                	bnez	a5,800028e8 <iput+0x22>
    acquiresleep(&ip->lock);
    80002910:	01048913          	addi	s2,s1,16
    80002914:	854a                	mv	a0,s2
    80002916:	14f000ef          	jal	ra,80003264 <acquiresleep>
    release(&itable.lock);
    8000291a:	00013517          	auipc	a0,0x13
    8000291e:	5fe50513          	addi	a0,a0,1534 # 80015f18 <itable>
    80002922:	649020ef          	jal	ra,8000576a <release>
    itrunc(ip);
    80002926:	8526                	mv	a0,s1
    80002928:	f0bff0ef          	jal	ra,80002832 <itrunc>
    ip->type = 0;
    8000292c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002930:	8526                	mv	a0,s1
    80002932:	d63ff0ef          	jal	ra,80002694 <iupdate>
    ip->valid = 0;
    80002936:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000293a:	854a                	mv	a0,s2
    8000293c:	16f000ef          	jal	ra,800032aa <releasesleep>
    acquire(&itable.lock);
    80002940:	00013517          	auipc	a0,0x13
    80002944:	5d850513          	addi	a0,a0,1496 # 80015f18 <itable>
    80002948:	58b020ef          	jal	ra,800056d2 <acquire>
    8000294c:	bf71                	j	800028e8 <iput+0x22>

000000008000294e <iunlockput>:
{
    8000294e:	1101                	addi	sp,sp,-32
    80002950:	ec06                	sd	ra,24(sp)
    80002952:	e822                	sd	s0,16(sp)
    80002954:	e426                	sd	s1,8(sp)
    80002956:	1000                	addi	s0,sp,32
    80002958:	84aa                	mv	s1,a0
  iunlock(ip);
    8000295a:	e99ff0ef          	jal	ra,800027f2 <iunlock>
  iput(ip);
    8000295e:	8526                	mv	a0,s1
    80002960:	f67ff0ef          	jal	ra,800028c6 <iput>
}
    80002964:	60e2                	ld	ra,24(sp)
    80002966:	6442                	ld	s0,16(sp)
    80002968:	64a2                	ld	s1,8(sp)
    8000296a:	6105                	addi	sp,sp,32
    8000296c:	8082                	ret

000000008000296e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000296e:	1141                	addi	sp,sp,-16
    80002970:	e422                	sd	s0,8(sp)
    80002972:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002974:	411c                	lw	a5,0(a0)
    80002976:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002978:	415c                	lw	a5,4(a0)
    8000297a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000297c:	04451783          	lh	a5,68(a0)
    80002980:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002984:	04a51783          	lh	a5,74(a0)
    80002988:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000298c:	04c56783          	lwu	a5,76(a0)
    80002990:	e99c                	sd	a5,16(a1)
}
    80002992:	6422                	ld	s0,8(sp)
    80002994:	0141                	addi	sp,sp,16
    80002996:	8082                	ret

0000000080002998 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002998:	457c                	lw	a5,76(a0)
    8000299a:	0cd7ef63          	bltu	a5,a3,80002a78 <readi+0xe0>
{
    8000299e:	7159                	addi	sp,sp,-112
    800029a0:	f486                	sd	ra,104(sp)
    800029a2:	f0a2                	sd	s0,96(sp)
    800029a4:	eca6                	sd	s1,88(sp)
    800029a6:	e8ca                	sd	s2,80(sp)
    800029a8:	e4ce                	sd	s3,72(sp)
    800029aa:	e0d2                	sd	s4,64(sp)
    800029ac:	fc56                	sd	s5,56(sp)
    800029ae:	f85a                	sd	s6,48(sp)
    800029b0:	f45e                	sd	s7,40(sp)
    800029b2:	f062                	sd	s8,32(sp)
    800029b4:	ec66                	sd	s9,24(sp)
    800029b6:	e86a                	sd	s10,16(sp)
    800029b8:	e46e                	sd	s11,8(sp)
    800029ba:	1880                	addi	s0,sp,112
    800029bc:	8b2a                	mv	s6,a0
    800029be:	8bae                	mv	s7,a1
    800029c0:	8a32                	mv	s4,a2
    800029c2:	84b6                	mv	s1,a3
    800029c4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800029c6:	9f35                	addw	a4,a4,a3
    return 0;
    800029c8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800029ca:	08d76663          	bltu	a4,a3,80002a56 <readi+0xbe>
  if(off + n > ip->size)
    800029ce:	00e7f463          	bgeu	a5,a4,800029d6 <readi+0x3e>
    n = ip->size - off;
    800029d2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800029d6:	080a8f63          	beqz	s5,80002a74 <readi+0xdc>
    800029da:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800029dc:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800029e0:	5c7d                	li	s8,-1
    800029e2:	a80d                	j	80002a14 <readi+0x7c>
    800029e4:	020d1d93          	slli	s11,s10,0x20
    800029e8:	020ddd93          	srli	s11,s11,0x20
    800029ec:	05890613          	addi	a2,s2,88
    800029f0:	86ee                	mv	a3,s11
    800029f2:	963a                	add	a2,a2,a4
    800029f4:	85d2                	mv	a1,s4
    800029f6:	855e                	mv	a0,s7
    800029f8:	d6bfe0ef          	jal	ra,80001762 <either_copyout>
    800029fc:	05850763          	beq	a0,s8,80002a4a <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002a00:	854a                	mv	a0,s2
    80002a02:	f32ff0ef          	jal	ra,80002134 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002a06:	013d09bb          	addw	s3,s10,s3
    80002a0a:	009d04bb          	addw	s1,s10,s1
    80002a0e:	9a6e                	add	s4,s4,s11
    80002a10:	0559f163          	bgeu	s3,s5,80002a52 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80002a14:	00a4d59b          	srliw	a1,s1,0xa
    80002a18:	855a                	mv	a0,s6
    80002a1a:	987ff0ef          	jal	ra,800023a0 <bmap>
    80002a1e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002a22:	c985                	beqz	a1,80002a52 <readi+0xba>
    bp = bread(ip->dev, addr);
    80002a24:	000b2503          	lw	a0,0(s6)
    80002a28:	e04ff0ef          	jal	ra,8000202c <bread>
    80002a2c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002a2e:	3ff4f713          	andi	a4,s1,1023
    80002a32:	40ec87bb          	subw	a5,s9,a4
    80002a36:	413a86bb          	subw	a3,s5,s3
    80002a3a:	8d3e                	mv	s10,a5
    80002a3c:	2781                	sext.w	a5,a5
    80002a3e:	0006861b          	sext.w	a2,a3
    80002a42:	faf671e3          	bgeu	a2,a5,800029e4 <readi+0x4c>
    80002a46:	8d36                	mv	s10,a3
    80002a48:	bf71                	j	800029e4 <readi+0x4c>
      brelse(bp);
    80002a4a:	854a                	mv	a0,s2
    80002a4c:	ee8ff0ef          	jal	ra,80002134 <brelse>
      tot = -1;
    80002a50:	59fd                	li	s3,-1
  }
  return tot;
    80002a52:	0009851b          	sext.w	a0,s3
}
    80002a56:	70a6                	ld	ra,104(sp)
    80002a58:	7406                	ld	s0,96(sp)
    80002a5a:	64e6                	ld	s1,88(sp)
    80002a5c:	6946                	ld	s2,80(sp)
    80002a5e:	69a6                	ld	s3,72(sp)
    80002a60:	6a06                	ld	s4,64(sp)
    80002a62:	7ae2                	ld	s5,56(sp)
    80002a64:	7b42                	ld	s6,48(sp)
    80002a66:	7ba2                	ld	s7,40(sp)
    80002a68:	7c02                	ld	s8,32(sp)
    80002a6a:	6ce2                	ld	s9,24(sp)
    80002a6c:	6d42                	ld	s10,16(sp)
    80002a6e:	6da2                	ld	s11,8(sp)
    80002a70:	6165                	addi	sp,sp,112
    80002a72:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002a74:	89d6                	mv	s3,s5
    80002a76:	bff1                	j	80002a52 <readi+0xba>
    return 0;
    80002a78:	4501                	li	a0,0
}
    80002a7a:	8082                	ret

0000000080002a7c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002a7c:	457c                	lw	a5,76(a0)
    80002a7e:	0ed7ea63          	bltu	a5,a3,80002b72 <writei+0xf6>
{
    80002a82:	7159                	addi	sp,sp,-112
    80002a84:	f486                	sd	ra,104(sp)
    80002a86:	f0a2                	sd	s0,96(sp)
    80002a88:	eca6                	sd	s1,88(sp)
    80002a8a:	e8ca                	sd	s2,80(sp)
    80002a8c:	e4ce                	sd	s3,72(sp)
    80002a8e:	e0d2                	sd	s4,64(sp)
    80002a90:	fc56                	sd	s5,56(sp)
    80002a92:	f85a                	sd	s6,48(sp)
    80002a94:	f45e                	sd	s7,40(sp)
    80002a96:	f062                	sd	s8,32(sp)
    80002a98:	ec66                	sd	s9,24(sp)
    80002a9a:	e86a                	sd	s10,16(sp)
    80002a9c:	e46e                	sd	s11,8(sp)
    80002a9e:	1880                	addi	s0,sp,112
    80002aa0:	8aaa                	mv	s5,a0
    80002aa2:	8bae                	mv	s7,a1
    80002aa4:	8a32                	mv	s4,a2
    80002aa6:	8936                	mv	s2,a3
    80002aa8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002aaa:	00e687bb          	addw	a5,a3,a4
    80002aae:	0cd7e463          	bltu	a5,a3,80002b76 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002ab2:	00043737          	lui	a4,0x43
    80002ab6:	0cf76263          	bltu	a4,a5,80002b7a <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002aba:	0a0b0a63          	beqz	s6,80002b6e <writei+0xf2>
    80002abe:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002ac0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002ac4:	5c7d                	li	s8,-1
    80002ac6:	a825                	j	80002afe <writei+0x82>
    80002ac8:	020d1d93          	slli	s11,s10,0x20
    80002acc:	020ddd93          	srli	s11,s11,0x20
    80002ad0:	05848513          	addi	a0,s1,88
    80002ad4:	86ee                	mv	a3,s11
    80002ad6:	8652                	mv	a2,s4
    80002ad8:	85de                	mv	a1,s7
    80002ada:	953a                	add	a0,a0,a4
    80002adc:	cd1fe0ef          	jal	ra,800017ac <either_copyin>
    80002ae0:	05850a63          	beq	a0,s8,80002b34 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002ae4:	8526                	mv	a0,s1
    80002ae6:	678000ef          	jal	ra,8000315e <log_write>
    brelse(bp);
    80002aea:	8526                	mv	a0,s1
    80002aec:	e48ff0ef          	jal	ra,80002134 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002af0:	013d09bb          	addw	s3,s10,s3
    80002af4:	012d093b          	addw	s2,s10,s2
    80002af8:	9a6e                	add	s4,s4,s11
    80002afa:	0569f063          	bgeu	s3,s6,80002b3a <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002afe:	00a9559b          	srliw	a1,s2,0xa
    80002b02:	8556                	mv	a0,s5
    80002b04:	89dff0ef          	jal	ra,800023a0 <bmap>
    80002b08:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002b0c:	c59d                	beqz	a1,80002b3a <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002b0e:	000aa503          	lw	a0,0(s5)
    80002b12:	d1aff0ef          	jal	ra,8000202c <bread>
    80002b16:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b18:	3ff97713          	andi	a4,s2,1023
    80002b1c:	40ec87bb          	subw	a5,s9,a4
    80002b20:	413b06bb          	subw	a3,s6,s3
    80002b24:	8d3e                	mv	s10,a5
    80002b26:	2781                	sext.w	a5,a5
    80002b28:	0006861b          	sext.w	a2,a3
    80002b2c:	f8f67ee3          	bgeu	a2,a5,80002ac8 <writei+0x4c>
    80002b30:	8d36                	mv	s10,a3
    80002b32:	bf59                	j	80002ac8 <writei+0x4c>
      brelse(bp);
    80002b34:	8526                	mv	a0,s1
    80002b36:	dfeff0ef          	jal	ra,80002134 <brelse>
  }

  if(off > ip->size)
    80002b3a:	04caa783          	lw	a5,76(s5)
    80002b3e:	0127f463          	bgeu	a5,s2,80002b46 <writei+0xca>
    ip->size = off;
    80002b42:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002b46:	8556                	mv	a0,s5
    80002b48:	b4dff0ef          	jal	ra,80002694 <iupdate>

  return tot;
    80002b4c:	0009851b          	sext.w	a0,s3
}
    80002b50:	70a6                	ld	ra,104(sp)
    80002b52:	7406                	ld	s0,96(sp)
    80002b54:	64e6                	ld	s1,88(sp)
    80002b56:	6946                	ld	s2,80(sp)
    80002b58:	69a6                	ld	s3,72(sp)
    80002b5a:	6a06                	ld	s4,64(sp)
    80002b5c:	7ae2                	ld	s5,56(sp)
    80002b5e:	7b42                	ld	s6,48(sp)
    80002b60:	7ba2                	ld	s7,40(sp)
    80002b62:	7c02                	ld	s8,32(sp)
    80002b64:	6ce2                	ld	s9,24(sp)
    80002b66:	6d42                	ld	s10,16(sp)
    80002b68:	6da2                	ld	s11,8(sp)
    80002b6a:	6165                	addi	sp,sp,112
    80002b6c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002b6e:	89da                	mv	s3,s6
    80002b70:	bfd9                	j	80002b46 <writei+0xca>
    return -1;
    80002b72:	557d                	li	a0,-1
}
    80002b74:	8082                	ret
    return -1;
    80002b76:	557d                	li	a0,-1
    80002b78:	bfe1                	j	80002b50 <writei+0xd4>
    return -1;
    80002b7a:	557d                	li	a0,-1
    80002b7c:	bfd1                	j	80002b50 <writei+0xd4>

0000000080002b7e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002b7e:	1141                	addi	sp,sp,-16
    80002b80:	e406                	sd	ra,8(sp)
    80002b82:	e022                	sd	s0,0(sp)
    80002b84:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002b86:	4639                	li	a2,14
    80002b88:	e92fd0ef          	jal	ra,8000021a <strncmp>
}
    80002b8c:	60a2                	ld	ra,8(sp)
    80002b8e:	6402                	ld	s0,0(sp)
    80002b90:	0141                	addi	sp,sp,16
    80002b92:	8082                	ret

0000000080002b94 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002b94:	7139                	addi	sp,sp,-64
    80002b96:	fc06                	sd	ra,56(sp)
    80002b98:	f822                	sd	s0,48(sp)
    80002b9a:	f426                	sd	s1,40(sp)
    80002b9c:	f04a                	sd	s2,32(sp)
    80002b9e:	ec4e                	sd	s3,24(sp)
    80002ba0:	e852                	sd	s4,16(sp)
    80002ba2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002ba4:	04451703          	lh	a4,68(a0)
    80002ba8:	4785                	li	a5,1
    80002baa:	00f71a63          	bne	a4,a5,80002bbe <dirlookup+0x2a>
    80002bae:	892a                	mv	s2,a0
    80002bb0:	89ae                	mv	s3,a1
    80002bb2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002bb4:	457c                	lw	a5,76(a0)
    80002bb6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002bb8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002bba:	e39d                	bnez	a5,80002be0 <dirlookup+0x4c>
    80002bbc:	a095                	j	80002c20 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002bbe:	00005517          	auipc	a0,0x5
    80002bc2:	aaa50513          	addi	a0,a0,-1366 # 80007668 <syscalls+0x208>
    80002bc6:	7fc020ef          	jal	ra,800053c2 <panic>
      panic("dirlookup read");
    80002bca:	00005517          	auipc	a0,0x5
    80002bce:	ab650513          	addi	a0,a0,-1354 # 80007680 <syscalls+0x220>
    80002bd2:	7f0020ef          	jal	ra,800053c2 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002bd6:	24c1                	addiw	s1,s1,16
    80002bd8:	04c92783          	lw	a5,76(s2)
    80002bdc:	04f4f163          	bgeu	s1,a5,80002c1e <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002be0:	4741                	li	a4,16
    80002be2:	86a6                	mv	a3,s1
    80002be4:	fc040613          	addi	a2,s0,-64
    80002be8:	4581                	li	a1,0
    80002bea:	854a                	mv	a0,s2
    80002bec:	dadff0ef          	jal	ra,80002998 <readi>
    80002bf0:	47c1                	li	a5,16
    80002bf2:	fcf51ce3          	bne	a0,a5,80002bca <dirlookup+0x36>
    if(de.inum == 0)
    80002bf6:	fc045783          	lhu	a5,-64(s0)
    80002bfa:	dff1                	beqz	a5,80002bd6 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002bfc:	fc240593          	addi	a1,s0,-62
    80002c00:	854e                	mv	a0,s3
    80002c02:	f7dff0ef          	jal	ra,80002b7e <namecmp>
    80002c06:	f961                	bnez	a0,80002bd6 <dirlookup+0x42>
      if(poff)
    80002c08:	000a0463          	beqz	s4,80002c10 <dirlookup+0x7c>
        *poff = off;
    80002c0c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002c10:	fc045583          	lhu	a1,-64(s0)
    80002c14:	00092503          	lw	a0,0(s2)
    80002c18:	857ff0ef          	jal	ra,8000246e <iget>
    80002c1c:	a011                	j	80002c20 <dirlookup+0x8c>
  return 0;
    80002c1e:	4501                	li	a0,0
}
    80002c20:	70e2                	ld	ra,56(sp)
    80002c22:	7442                	ld	s0,48(sp)
    80002c24:	74a2                	ld	s1,40(sp)
    80002c26:	7902                	ld	s2,32(sp)
    80002c28:	69e2                	ld	s3,24(sp)
    80002c2a:	6a42                	ld	s4,16(sp)
    80002c2c:	6121                	addi	sp,sp,64
    80002c2e:	8082                	ret

0000000080002c30 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002c30:	711d                	addi	sp,sp,-96
    80002c32:	ec86                	sd	ra,88(sp)
    80002c34:	e8a2                	sd	s0,80(sp)
    80002c36:	e4a6                	sd	s1,72(sp)
    80002c38:	e0ca                	sd	s2,64(sp)
    80002c3a:	fc4e                	sd	s3,56(sp)
    80002c3c:	f852                	sd	s4,48(sp)
    80002c3e:	f456                	sd	s5,40(sp)
    80002c40:	f05a                	sd	s6,32(sp)
    80002c42:	ec5e                	sd	s7,24(sp)
    80002c44:	e862                	sd	s8,16(sp)
    80002c46:	e466                	sd	s9,8(sp)
    80002c48:	e06a                	sd	s10,0(sp)
    80002c4a:	1080                	addi	s0,sp,96
    80002c4c:	84aa                	mv	s1,a0
    80002c4e:	8b2e                	mv	s6,a1
    80002c50:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002c52:	00054703          	lbu	a4,0(a0)
    80002c56:	02f00793          	li	a5,47
    80002c5a:	00f70f63          	beq	a4,a5,80002c78 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002c5e:	9dcfe0ef          	jal	ra,80000e3a <myproc>
    80002c62:	15053503          	ld	a0,336(a0)
    80002c66:	aadff0ef          	jal	ra,80002712 <idup>
    80002c6a:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002c6c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002c70:	4cb5                	li	s9,13
  len = path - s;
    80002c72:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002c74:	4c05                	li	s8,1
    80002c76:	a879                	j	80002d14 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80002c78:	4585                	li	a1,1
    80002c7a:	4505                	li	a0,1
    80002c7c:	ff2ff0ef          	jal	ra,8000246e <iget>
    80002c80:	8a2a                	mv	s4,a0
    80002c82:	b7ed                	j	80002c6c <namex+0x3c>
      iunlockput(ip);
    80002c84:	8552                	mv	a0,s4
    80002c86:	cc9ff0ef          	jal	ra,8000294e <iunlockput>
      return 0;
    80002c8a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002c8c:	8552                	mv	a0,s4
    80002c8e:	60e6                	ld	ra,88(sp)
    80002c90:	6446                	ld	s0,80(sp)
    80002c92:	64a6                	ld	s1,72(sp)
    80002c94:	6906                	ld	s2,64(sp)
    80002c96:	79e2                	ld	s3,56(sp)
    80002c98:	7a42                	ld	s4,48(sp)
    80002c9a:	7aa2                	ld	s5,40(sp)
    80002c9c:	7b02                	ld	s6,32(sp)
    80002c9e:	6be2                	ld	s7,24(sp)
    80002ca0:	6c42                	ld	s8,16(sp)
    80002ca2:	6ca2                	ld	s9,8(sp)
    80002ca4:	6d02                	ld	s10,0(sp)
    80002ca6:	6125                	addi	sp,sp,96
    80002ca8:	8082                	ret
      iunlock(ip);
    80002caa:	8552                	mv	a0,s4
    80002cac:	b47ff0ef          	jal	ra,800027f2 <iunlock>
      return ip;
    80002cb0:	bff1                	j	80002c8c <namex+0x5c>
      iunlockput(ip);
    80002cb2:	8552                	mv	a0,s4
    80002cb4:	c9bff0ef          	jal	ra,8000294e <iunlockput>
      return 0;
    80002cb8:	8a4e                	mv	s4,s3
    80002cba:	bfc9                	j	80002c8c <namex+0x5c>
  len = path - s;
    80002cbc:	40998633          	sub	a2,s3,s1
    80002cc0:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80002cc4:	09acd063          	bge	s9,s10,80002d44 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80002cc8:	4639                	li	a2,14
    80002cca:	85a6                	mv	a1,s1
    80002ccc:	8556                	mv	a0,s5
    80002cce:	cdcfd0ef          	jal	ra,800001aa <memmove>
    80002cd2:	84ce                	mv	s1,s3
  while(*path == '/')
    80002cd4:	0004c783          	lbu	a5,0(s1)
    80002cd8:	01279763          	bne	a5,s2,80002ce6 <namex+0xb6>
    path++;
    80002cdc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002cde:	0004c783          	lbu	a5,0(s1)
    80002ce2:	ff278de3          	beq	a5,s2,80002cdc <namex+0xac>
    ilock(ip);
    80002ce6:	8552                	mv	a0,s4
    80002ce8:	a61ff0ef          	jal	ra,80002748 <ilock>
    if(ip->type != T_DIR){
    80002cec:	044a1783          	lh	a5,68(s4)
    80002cf0:	f9879ae3          	bne	a5,s8,80002c84 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80002cf4:	000b0563          	beqz	s6,80002cfe <namex+0xce>
    80002cf8:	0004c783          	lbu	a5,0(s1)
    80002cfc:	d7dd                	beqz	a5,80002caa <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002cfe:	865e                	mv	a2,s7
    80002d00:	85d6                	mv	a1,s5
    80002d02:	8552                	mv	a0,s4
    80002d04:	e91ff0ef          	jal	ra,80002b94 <dirlookup>
    80002d08:	89aa                	mv	s3,a0
    80002d0a:	d545                	beqz	a0,80002cb2 <namex+0x82>
    iunlockput(ip);
    80002d0c:	8552                	mv	a0,s4
    80002d0e:	c41ff0ef          	jal	ra,8000294e <iunlockput>
    ip = next;
    80002d12:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002d14:	0004c783          	lbu	a5,0(s1)
    80002d18:	01279763          	bne	a5,s2,80002d26 <namex+0xf6>
    path++;
    80002d1c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002d1e:	0004c783          	lbu	a5,0(s1)
    80002d22:	ff278de3          	beq	a5,s2,80002d1c <namex+0xec>
  if(*path == 0)
    80002d26:	cb8d                	beqz	a5,80002d58 <namex+0x128>
  while(*path != '/' && *path != 0)
    80002d28:	0004c783          	lbu	a5,0(s1)
    80002d2c:	89a6                	mv	s3,s1
  len = path - s;
    80002d2e:	8d5e                	mv	s10,s7
    80002d30:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80002d32:	01278963          	beq	a5,s2,80002d44 <namex+0x114>
    80002d36:	d3d9                	beqz	a5,80002cbc <namex+0x8c>
    path++;
    80002d38:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002d3a:	0009c783          	lbu	a5,0(s3)
    80002d3e:	ff279ce3          	bne	a5,s2,80002d36 <namex+0x106>
    80002d42:	bfad                	j	80002cbc <namex+0x8c>
    memmove(name, s, len);
    80002d44:	2601                	sext.w	a2,a2
    80002d46:	85a6                	mv	a1,s1
    80002d48:	8556                	mv	a0,s5
    80002d4a:	c60fd0ef          	jal	ra,800001aa <memmove>
    name[len] = 0;
    80002d4e:	9d56                	add	s10,s10,s5
    80002d50:	000d0023          	sb	zero,0(s10)
    80002d54:	84ce                	mv	s1,s3
    80002d56:	bfbd                	j	80002cd4 <namex+0xa4>
  if(nameiparent){
    80002d58:	f20b0ae3          	beqz	s6,80002c8c <namex+0x5c>
    iput(ip);
    80002d5c:	8552                	mv	a0,s4
    80002d5e:	b69ff0ef          	jal	ra,800028c6 <iput>
    return 0;
    80002d62:	4a01                	li	s4,0
    80002d64:	b725                	j	80002c8c <namex+0x5c>

0000000080002d66 <dirlink>:
{
    80002d66:	7139                	addi	sp,sp,-64
    80002d68:	fc06                	sd	ra,56(sp)
    80002d6a:	f822                	sd	s0,48(sp)
    80002d6c:	f426                	sd	s1,40(sp)
    80002d6e:	f04a                	sd	s2,32(sp)
    80002d70:	ec4e                	sd	s3,24(sp)
    80002d72:	e852                	sd	s4,16(sp)
    80002d74:	0080                	addi	s0,sp,64
    80002d76:	892a                	mv	s2,a0
    80002d78:	8a2e                	mv	s4,a1
    80002d7a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002d7c:	4601                	li	a2,0
    80002d7e:	e17ff0ef          	jal	ra,80002b94 <dirlookup>
    80002d82:	e52d                	bnez	a0,80002dec <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d84:	04c92483          	lw	s1,76(s2)
    80002d88:	c48d                	beqz	s1,80002db2 <dirlink+0x4c>
    80002d8a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002d8c:	4741                	li	a4,16
    80002d8e:	86a6                	mv	a3,s1
    80002d90:	fc040613          	addi	a2,s0,-64
    80002d94:	4581                	li	a1,0
    80002d96:	854a                	mv	a0,s2
    80002d98:	c01ff0ef          	jal	ra,80002998 <readi>
    80002d9c:	47c1                	li	a5,16
    80002d9e:	04f51b63          	bne	a0,a5,80002df4 <dirlink+0x8e>
    if(de.inum == 0)
    80002da2:	fc045783          	lhu	a5,-64(s0)
    80002da6:	c791                	beqz	a5,80002db2 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002da8:	24c1                	addiw	s1,s1,16
    80002daa:	04c92783          	lw	a5,76(s2)
    80002dae:	fcf4efe3          	bltu	s1,a5,80002d8c <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002db2:	4639                	li	a2,14
    80002db4:	85d2                	mv	a1,s4
    80002db6:	fc240513          	addi	a0,s0,-62
    80002dba:	c9cfd0ef          	jal	ra,80000256 <strncpy>
  de.inum = inum;
    80002dbe:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002dc2:	4741                	li	a4,16
    80002dc4:	86a6                	mv	a3,s1
    80002dc6:	fc040613          	addi	a2,s0,-64
    80002dca:	4581                	li	a1,0
    80002dcc:	854a                	mv	a0,s2
    80002dce:	cafff0ef          	jal	ra,80002a7c <writei>
    80002dd2:	1541                	addi	a0,a0,-16
    80002dd4:	00a03533          	snez	a0,a0
    80002dd8:	40a00533          	neg	a0,a0
}
    80002ddc:	70e2                	ld	ra,56(sp)
    80002dde:	7442                	ld	s0,48(sp)
    80002de0:	74a2                	ld	s1,40(sp)
    80002de2:	7902                	ld	s2,32(sp)
    80002de4:	69e2                	ld	s3,24(sp)
    80002de6:	6a42                	ld	s4,16(sp)
    80002de8:	6121                	addi	sp,sp,64
    80002dea:	8082                	ret
    iput(ip);
    80002dec:	adbff0ef          	jal	ra,800028c6 <iput>
    return -1;
    80002df0:	557d                	li	a0,-1
    80002df2:	b7ed                	j	80002ddc <dirlink+0x76>
      panic("dirlink read");
    80002df4:	00005517          	auipc	a0,0x5
    80002df8:	89c50513          	addi	a0,a0,-1892 # 80007690 <syscalls+0x230>
    80002dfc:	5c6020ef          	jal	ra,800053c2 <panic>

0000000080002e00 <namei>:

struct inode*
namei(char *path)
{
    80002e00:	1101                	addi	sp,sp,-32
    80002e02:	ec06                	sd	ra,24(sp)
    80002e04:	e822                	sd	s0,16(sp)
    80002e06:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002e08:	fe040613          	addi	a2,s0,-32
    80002e0c:	4581                	li	a1,0
    80002e0e:	e23ff0ef          	jal	ra,80002c30 <namex>
}
    80002e12:	60e2                	ld	ra,24(sp)
    80002e14:	6442                	ld	s0,16(sp)
    80002e16:	6105                	addi	sp,sp,32
    80002e18:	8082                	ret

0000000080002e1a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002e1a:	1141                	addi	sp,sp,-16
    80002e1c:	e406                	sd	ra,8(sp)
    80002e1e:	e022                	sd	s0,0(sp)
    80002e20:	0800                	addi	s0,sp,16
    80002e22:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002e24:	4585                	li	a1,1
    80002e26:	e0bff0ef          	jal	ra,80002c30 <namex>
}
    80002e2a:	60a2                	ld	ra,8(sp)
    80002e2c:	6402                	ld	s0,0(sp)
    80002e2e:	0141                	addi	sp,sp,16
    80002e30:	8082                	ret

0000000080002e32 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002e32:	1101                	addi	sp,sp,-32
    80002e34:	ec06                	sd	ra,24(sp)
    80002e36:	e822                	sd	s0,16(sp)
    80002e38:	e426                	sd	s1,8(sp)
    80002e3a:	e04a                	sd	s2,0(sp)
    80002e3c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002e3e:	00015917          	auipc	s2,0x15
    80002e42:	b8290913          	addi	s2,s2,-1150 # 800179c0 <log>
    80002e46:	01892583          	lw	a1,24(s2)
    80002e4a:	02892503          	lw	a0,40(s2)
    80002e4e:	9deff0ef          	jal	ra,8000202c <bread>
    80002e52:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002e54:	02c92683          	lw	a3,44(s2)
    80002e58:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002e5a:	02d05863          	blez	a3,80002e8a <write_head+0x58>
    80002e5e:	00015797          	auipc	a5,0x15
    80002e62:	b9278793          	addi	a5,a5,-1134 # 800179f0 <log+0x30>
    80002e66:	05c50713          	addi	a4,a0,92
    80002e6a:	36fd                	addiw	a3,a3,-1
    80002e6c:	02069613          	slli	a2,a3,0x20
    80002e70:	01e65693          	srli	a3,a2,0x1e
    80002e74:	00015617          	auipc	a2,0x15
    80002e78:	b8060613          	addi	a2,a2,-1152 # 800179f4 <log+0x34>
    80002e7c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80002e7e:	4390                	lw	a2,0(a5)
    80002e80:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80002e82:	0791                	addi	a5,a5,4
    80002e84:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80002e86:	fed79ce3          	bne	a5,a3,80002e7e <write_head+0x4c>
  }
  bwrite(buf);
    80002e8a:	8526                	mv	a0,s1
    80002e8c:	a76ff0ef          	jal	ra,80002102 <bwrite>
  brelse(buf);
    80002e90:	8526                	mv	a0,s1
    80002e92:	aa2ff0ef          	jal	ra,80002134 <brelse>
}
    80002e96:	60e2                	ld	ra,24(sp)
    80002e98:	6442                	ld	s0,16(sp)
    80002e9a:	64a2                	ld	s1,8(sp)
    80002e9c:	6902                	ld	s2,0(sp)
    80002e9e:	6105                	addi	sp,sp,32
    80002ea0:	8082                	ret

0000000080002ea2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80002ea2:	00015797          	auipc	a5,0x15
    80002ea6:	b4a7a783          	lw	a5,-1206(a5) # 800179ec <log+0x2c>
    80002eaa:	08f05f63          	blez	a5,80002f48 <install_trans+0xa6>
{
    80002eae:	7139                	addi	sp,sp,-64
    80002eb0:	fc06                	sd	ra,56(sp)
    80002eb2:	f822                	sd	s0,48(sp)
    80002eb4:	f426                	sd	s1,40(sp)
    80002eb6:	f04a                	sd	s2,32(sp)
    80002eb8:	ec4e                	sd	s3,24(sp)
    80002eba:	e852                	sd	s4,16(sp)
    80002ebc:	e456                	sd	s5,8(sp)
    80002ebe:	e05a                	sd	s6,0(sp)
    80002ec0:	0080                	addi	s0,sp,64
    80002ec2:	8b2a                	mv	s6,a0
    80002ec4:	00015a97          	auipc	s5,0x15
    80002ec8:	b2ca8a93          	addi	s5,s5,-1236 # 800179f0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002ecc:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002ece:	00015997          	auipc	s3,0x15
    80002ed2:	af298993          	addi	s3,s3,-1294 # 800179c0 <log>
    80002ed6:	a829                	j	80002ef0 <install_trans+0x4e>
    brelse(lbuf);
    80002ed8:	854a                	mv	a0,s2
    80002eda:	a5aff0ef          	jal	ra,80002134 <brelse>
    brelse(dbuf);
    80002ede:	8526                	mv	a0,s1
    80002ee0:	a54ff0ef          	jal	ra,80002134 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002ee4:	2a05                	addiw	s4,s4,1
    80002ee6:	0a91                	addi	s5,s5,4
    80002ee8:	02c9a783          	lw	a5,44(s3)
    80002eec:	04fa5463          	bge	s4,a5,80002f34 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002ef0:	0189a583          	lw	a1,24(s3)
    80002ef4:	014585bb          	addw	a1,a1,s4
    80002ef8:	2585                	addiw	a1,a1,1
    80002efa:	0289a503          	lw	a0,40(s3)
    80002efe:	92eff0ef          	jal	ra,8000202c <bread>
    80002f02:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80002f04:	000aa583          	lw	a1,0(s5)
    80002f08:	0289a503          	lw	a0,40(s3)
    80002f0c:	920ff0ef          	jal	ra,8000202c <bread>
    80002f10:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80002f12:	40000613          	li	a2,1024
    80002f16:	05890593          	addi	a1,s2,88
    80002f1a:	05850513          	addi	a0,a0,88
    80002f1e:	a8cfd0ef          	jal	ra,800001aa <memmove>
    bwrite(dbuf);  // write dst to disk
    80002f22:	8526                	mv	a0,s1
    80002f24:	9deff0ef          	jal	ra,80002102 <bwrite>
    if(recovering == 0)
    80002f28:	fa0b18e3          	bnez	s6,80002ed8 <install_trans+0x36>
      bunpin(dbuf);
    80002f2c:	8526                	mv	a0,s1
    80002f2e:	ac4ff0ef          	jal	ra,800021f2 <bunpin>
    80002f32:	b75d                	j	80002ed8 <install_trans+0x36>
}
    80002f34:	70e2                	ld	ra,56(sp)
    80002f36:	7442                	ld	s0,48(sp)
    80002f38:	74a2                	ld	s1,40(sp)
    80002f3a:	7902                	ld	s2,32(sp)
    80002f3c:	69e2                	ld	s3,24(sp)
    80002f3e:	6a42                	ld	s4,16(sp)
    80002f40:	6aa2                	ld	s5,8(sp)
    80002f42:	6b02                	ld	s6,0(sp)
    80002f44:	6121                	addi	sp,sp,64
    80002f46:	8082                	ret
    80002f48:	8082                	ret

0000000080002f4a <initlog>:
{
    80002f4a:	7179                	addi	sp,sp,-48
    80002f4c:	f406                	sd	ra,40(sp)
    80002f4e:	f022                	sd	s0,32(sp)
    80002f50:	ec26                	sd	s1,24(sp)
    80002f52:	e84a                	sd	s2,16(sp)
    80002f54:	e44e                	sd	s3,8(sp)
    80002f56:	1800                	addi	s0,sp,48
    80002f58:	892a                	mv	s2,a0
    80002f5a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80002f5c:	00015497          	auipc	s1,0x15
    80002f60:	a6448493          	addi	s1,s1,-1436 # 800179c0 <log>
    80002f64:	00004597          	auipc	a1,0x4
    80002f68:	73c58593          	addi	a1,a1,1852 # 800076a0 <syscalls+0x240>
    80002f6c:	8526                	mv	a0,s1
    80002f6e:	6e4020ef          	jal	ra,80005652 <initlock>
  log.start = sb->logstart;
    80002f72:	0149a583          	lw	a1,20(s3)
    80002f76:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80002f78:	0109a783          	lw	a5,16(s3)
    80002f7c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80002f7e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80002f82:	854a                	mv	a0,s2
    80002f84:	8a8ff0ef          	jal	ra,8000202c <bread>
  log.lh.n = lh->n;
    80002f88:	4d34                	lw	a3,88(a0)
    80002f8a:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80002f8c:	02d05663          	blez	a3,80002fb8 <initlog+0x6e>
    80002f90:	05c50793          	addi	a5,a0,92
    80002f94:	00015717          	auipc	a4,0x15
    80002f98:	a5c70713          	addi	a4,a4,-1444 # 800179f0 <log+0x30>
    80002f9c:	36fd                	addiw	a3,a3,-1
    80002f9e:	02069613          	slli	a2,a3,0x20
    80002fa2:	01e65693          	srli	a3,a2,0x1e
    80002fa6:	06050613          	addi	a2,a0,96
    80002faa:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80002fac:	4390                	lw	a2,0(a5)
    80002fae:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80002fb0:	0791                	addi	a5,a5,4
    80002fb2:	0711                	addi	a4,a4,4
    80002fb4:	fed79ce3          	bne	a5,a3,80002fac <initlog+0x62>
  brelse(buf);
    80002fb8:	97cff0ef          	jal	ra,80002134 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80002fbc:	4505                	li	a0,1
    80002fbe:	ee5ff0ef          	jal	ra,80002ea2 <install_trans>
  log.lh.n = 0;
    80002fc2:	00015797          	auipc	a5,0x15
    80002fc6:	a207a523          	sw	zero,-1494(a5) # 800179ec <log+0x2c>
  write_head(); // clear the log
    80002fca:	e69ff0ef          	jal	ra,80002e32 <write_head>
}
    80002fce:	70a2                	ld	ra,40(sp)
    80002fd0:	7402                	ld	s0,32(sp)
    80002fd2:	64e2                	ld	s1,24(sp)
    80002fd4:	6942                	ld	s2,16(sp)
    80002fd6:	69a2                	ld	s3,8(sp)
    80002fd8:	6145                	addi	sp,sp,48
    80002fda:	8082                	ret

0000000080002fdc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80002fdc:	1101                	addi	sp,sp,-32
    80002fde:	ec06                	sd	ra,24(sp)
    80002fe0:	e822                	sd	s0,16(sp)
    80002fe2:	e426                	sd	s1,8(sp)
    80002fe4:	e04a                	sd	s2,0(sp)
    80002fe6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80002fe8:	00015517          	auipc	a0,0x15
    80002fec:	9d850513          	addi	a0,a0,-1576 # 800179c0 <log>
    80002ff0:	6e2020ef          	jal	ra,800056d2 <acquire>
  while(1){
    if(log.committing){
    80002ff4:	00015497          	auipc	s1,0x15
    80002ff8:	9cc48493          	addi	s1,s1,-1588 # 800179c0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80002ffc:	4979                	li	s2,30
    80002ffe:	a029                	j	80003008 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003000:	85a6                	mv	a1,s1
    80003002:	8526                	mv	a0,s1
    80003004:	c02fe0ef          	jal	ra,80001406 <sleep>
    if(log.committing){
    80003008:	50dc                	lw	a5,36(s1)
    8000300a:	fbfd                	bnez	a5,80003000 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000300c:	5098                	lw	a4,32(s1)
    8000300e:	2705                	addiw	a4,a4,1
    80003010:	0007069b          	sext.w	a3,a4
    80003014:	0027179b          	slliw	a5,a4,0x2
    80003018:	9fb9                	addw	a5,a5,a4
    8000301a:	0017979b          	slliw	a5,a5,0x1
    8000301e:	54d8                	lw	a4,44(s1)
    80003020:	9fb9                	addw	a5,a5,a4
    80003022:	00f95763          	bge	s2,a5,80003030 <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003026:	85a6                	mv	a1,s1
    80003028:	8526                	mv	a0,s1
    8000302a:	bdcfe0ef          	jal	ra,80001406 <sleep>
    8000302e:	bfe9                	j	80003008 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003030:	00015517          	auipc	a0,0x15
    80003034:	99050513          	addi	a0,a0,-1648 # 800179c0 <log>
    80003038:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000303a:	730020ef          	jal	ra,8000576a <release>
      break;
    }
  }
}
    8000303e:	60e2                	ld	ra,24(sp)
    80003040:	6442                	ld	s0,16(sp)
    80003042:	64a2                	ld	s1,8(sp)
    80003044:	6902                	ld	s2,0(sp)
    80003046:	6105                	addi	sp,sp,32
    80003048:	8082                	ret

000000008000304a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000304a:	7139                	addi	sp,sp,-64
    8000304c:	fc06                	sd	ra,56(sp)
    8000304e:	f822                	sd	s0,48(sp)
    80003050:	f426                	sd	s1,40(sp)
    80003052:	f04a                	sd	s2,32(sp)
    80003054:	ec4e                	sd	s3,24(sp)
    80003056:	e852                	sd	s4,16(sp)
    80003058:	e456                	sd	s5,8(sp)
    8000305a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000305c:	00015497          	auipc	s1,0x15
    80003060:	96448493          	addi	s1,s1,-1692 # 800179c0 <log>
    80003064:	8526                	mv	a0,s1
    80003066:	66c020ef          	jal	ra,800056d2 <acquire>
  log.outstanding -= 1;
    8000306a:	509c                	lw	a5,32(s1)
    8000306c:	37fd                	addiw	a5,a5,-1
    8000306e:	0007891b          	sext.w	s2,a5
    80003072:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003074:	50dc                	lw	a5,36(s1)
    80003076:	ef9d                	bnez	a5,800030b4 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003078:	04091463          	bnez	s2,800030c0 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    8000307c:	00015497          	auipc	s1,0x15
    80003080:	94448493          	addi	s1,s1,-1724 # 800179c0 <log>
    80003084:	4785                	li	a5,1
    80003086:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003088:	8526                	mv	a0,s1
    8000308a:	6e0020ef          	jal	ra,8000576a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000308e:	54dc                	lw	a5,44(s1)
    80003090:	04f04b63          	bgtz	a5,800030e6 <end_op+0x9c>
    acquire(&log.lock);
    80003094:	00015497          	auipc	s1,0x15
    80003098:	92c48493          	addi	s1,s1,-1748 # 800179c0 <log>
    8000309c:	8526                	mv	a0,s1
    8000309e:	634020ef          	jal	ra,800056d2 <acquire>
    log.committing = 0;
    800030a2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800030a6:	8526                	mv	a0,s1
    800030a8:	baafe0ef          	jal	ra,80001452 <wakeup>
    release(&log.lock);
    800030ac:	8526                	mv	a0,s1
    800030ae:	6bc020ef          	jal	ra,8000576a <release>
}
    800030b2:	a00d                	j	800030d4 <end_op+0x8a>
    panic("log.committing");
    800030b4:	00004517          	auipc	a0,0x4
    800030b8:	5f450513          	addi	a0,a0,1524 # 800076a8 <syscalls+0x248>
    800030bc:	306020ef          	jal	ra,800053c2 <panic>
    wakeup(&log);
    800030c0:	00015497          	auipc	s1,0x15
    800030c4:	90048493          	addi	s1,s1,-1792 # 800179c0 <log>
    800030c8:	8526                	mv	a0,s1
    800030ca:	b88fe0ef          	jal	ra,80001452 <wakeup>
  release(&log.lock);
    800030ce:	8526                	mv	a0,s1
    800030d0:	69a020ef          	jal	ra,8000576a <release>
}
    800030d4:	70e2                	ld	ra,56(sp)
    800030d6:	7442                	ld	s0,48(sp)
    800030d8:	74a2                	ld	s1,40(sp)
    800030da:	7902                	ld	s2,32(sp)
    800030dc:	69e2                	ld	s3,24(sp)
    800030de:	6a42                	ld	s4,16(sp)
    800030e0:	6aa2                	ld	s5,8(sp)
    800030e2:	6121                	addi	sp,sp,64
    800030e4:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800030e6:	00015a97          	auipc	s5,0x15
    800030ea:	90aa8a93          	addi	s5,s5,-1782 # 800179f0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800030ee:	00015a17          	auipc	s4,0x15
    800030f2:	8d2a0a13          	addi	s4,s4,-1838 # 800179c0 <log>
    800030f6:	018a2583          	lw	a1,24(s4)
    800030fa:	012585bb          	addw	a1,a1,s2
    800030fe:	2585                	addiw	a1,a1,1
    80003100:	028a2503          	lw	a0,40(s4)
    80003104:	f29fe0ef          	jal	ra,8000202c <bread>
    80003108:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000310a:	000aa583          	lw	a1,0(s5)
    8000310e:	028a2503          	lw	a0,40(s4)
    80003112:	f1bfe0ef          	jal	ra,8000202c <bread>
    80003116:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003118:	40000613          	li	a2,1024
    8000311c:	05850593          	addi	a1,a0,88
    80003120:	05848513          	addi	a0,s1,88
    80003124:	886fd0ef          	jal	ra,800001aa <memmove>
    bwrite(to);  // write the log
    80003128:	8526                	mv	a0,s1
    8000312a:	fd9fe0ef          	jal	ra,80002102 <bwrite>
    brelse(from);
    8000312e:	854e                	mv	a0,s3
    80003130:	804ff0ef          	jal	ra,80002134 <brelse>
    brelse(to);
    80003134:	8526                	mv	a0,s1
    80003136:	ffffe0ef          	jal	ra,80002134 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000313a:	2905                	addiw	s2,s2,1
    8000313c:	0a91                	addi	s5,s5,4
    8000313e:	02ca2783          	lw	a5,44(s4)
    80003142:	faf94ae3          	blt	s2,a5,800030f6 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003146:	cedff0ef          	jal	ra,80002e32 <write_head>
    install_trans(0); // Now install writes to home locations
    8000314a:	4501                	li	a0,0
    8000314c:	d57ff0ef          	jal	ra,80002ea2 <install_trans>
    log.lh.n = 0;
    80003150:	00015797          	auipc	a5,0x15
    80003154:	8807ae23          	sw	zero,-1892(a5) # 800179ec <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003158:	cdbff0ef          	jal	ra,80002e32 <write_head>
    8000315c:	bf25                	j	80003094 <end_op+0x4a>

000000008000315e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000315e:	1101                	addi	sp,sp,-32
    80003160:	ec06                	sd	ra,24(sp)
    80003162:	e822                	sd	s0,16(sp)
    80003164:	e426                	sd	s1,8(sp)
    80003166:	e04a                	sd	s2,0(sp)
    80003168:	1000                	addi	s0,sp,32
    8000316a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000316c:	00015917          	auipc	s2,0x15
    80003170:	85490913          	addi	s2,s2,-1964 # 800179c0 <log>
    80003174:	854a                	mv	a0,s2
    80003176:	55c020ef          	jal	ra,800056d2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000317a:	02c92603          	lw	a2,44(s2)
    8000317e:	47f5                	li	a5,29
    80003180:	06c7c363          	blt	a5,a2,800031e6 <log_write+0x88>
    80003184:	00015797          	auipc	a5,0x15
    80003188:	8587a783          	lw	a5,-1960(a5) # 800179dc <log+0x1c>
    8000318c:	37fd                	addiw	a5,a5,-1
    8000318e:	04f65c63          	bge	a2,a5,800031e6 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003192:	00015797          	auipc	a5,0x15
    80003196:	84e7a783          	lw	a5,-1970(a5) # 800179e0 <log+0x20>
    8000319a:	04f05c63          	blez	a5,800031f2 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000319e:	4781                	li	a5,0
    800031a0:	04c05f63          	blez	a2,800031fe <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800031a4:	44cc                	lw	a1,12(s1)
    800031a6:	00015717          	auipc	a4,0x15
    800031aa:	84a70713          	addi	a4,a4,-1974 # 800179f0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800031ae:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800031b0:	4314                	lw	a3,0(a4)
    800031b2:	04b68663          	beq	a3,a1,800031fe <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    800031b6:	2785                	addiw	a5,a5,1
    800031b8:	0711                	addi	a4,a4,4
    800031ba:	fef61be3          	bne	a2,a5,800031b0 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    800031be:	0621                	addi	a2,a2,8
    800031c0:	060a                	slli	a2,a2,0x2
    800031c2:	00014797          	auipc	a5,0x14
    800031c6:	7fe78793          	addi	a5,a5,2046 # 800179c0 <log>
    800031ca:	97b2                	add	a5,a5,a2
    800031cc:	44d8                	lw	a4,12(s1)
    800031ce:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800031d0:	8526                	mv	a0,s1
    800031d2:	fedfe0ef          	jal	ra,800021be <bpin>
    log.lh.n++;
    800031d6:	00014717          	auipc	a4,0x14
    800031da:	7ea70713          	addi	a4,a4,2026 # 800179c0 <log>
    800031de:	575c                	lw	a5,44(a4)
    800031e0:	2785                	addiw	a5,a5,1
    800031e2:	d75c                	sw	a5,44(a4)
    800031e4:	a80d                	j	80003216 <log_write+0xb8>
    panic("too big a transaction");
    800031e6:	00004517          	auipc	a0,0x4
    800031ea:	4d250513          	addi	a0,a0,1234 # 800076b8 <syscalls+0x258>
    800031ee:	1d4020ef          	jal	ra,800053c2 <panic>
    panic("log_write outside of trans");
    800031f2:	00004517          	auipc	a0,0x4
    800031f6:	4de50513          	addi	a0,a0,1246 # 800076d0 <syscalls+0x270>
    800031fa:	1c8020ef          	jal	ra,800053c2 <panic>
  log.lh.block[i] = b->blockno;
    800031fe:	00878693          	addi	a3,a5,8
    80003202:	068a                	slli	a3,a3,0x2
    80003204:	00014717          	auipc	a4,0x14
    80003208:	7bc70713          	addi	a4,a4,1980 # 800179c0 <log>
    8000320c:	9736                	add	a4,a4,a3
    8000320e:	44d4                	lw	a3,12(s1)
    80003210:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003212:	faf60fe3          	beq	a2,a5,800031d0 <log_write+0x72>
  }
  release(&log.lock);
    80003216:	00014517          	auipc	a0,0x14
    8000321a:	7aa50513          	addi	a0,a0,1962 # 800179c0 <log>
    8000321e:	54c020ef          	jal	ra,8000576a <release>
}
    80003222:	60e2                	ld	ra,24(sp)
    80003224:	6442                	ld	s0,16(sp)
    80003226:	64a2                	ld	s1,8(sp)
    80003228:	6902                	ld	s2,0(sp)
    8000322a:	6105                	addi	sp,sp,32
    8000322c:	8082                	ret

000000008000322e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000322e:	1101                	addi	sp,sp,-32
    80003230:	ec06                	sd	ra,24(sp)
    80003232:	e822                	sd	s0,16(sp)
    80003234:	e426                	sd	s1,8(sp)
    80003236:	e04a                	sd	s2,0(sp)
    80003238:	1000                	addi	s0,sp,32
    8000323a:	84aa                	mv	s1,a0
    8000323c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000323e:	00004597          	auipc	a1,0x4
    80003242:	4b258593          	addi	a1,a1,1202 # 800076f0 <syscalls+0x290>
    80003246:	0521                	addi	a0,a0,8
    80003248:	40a020ef          	jal	ra,80005652 <initlock>
  lk->name = name;
    8000324c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003250:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003254:	0204a423          	sw	zero,40(s1)
}
    80003258:	60e2                	ld	ra,24(sp)
    8000325a:	6442                	ld	s0,16(sp)
    8000325c:	64a2                	ld	s1,8(sp)
    8000325e:	6902                	ld	s2,0(sp)
    80003260:	6105                	addi	sp,sp,32
    80003262:	8082                	ret

0000000080003264 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003264:	1101                	addi	sp,sp,-32
    80003266:	ec06                	sd	ra,24(sp)
    80003268:	e822                	sd	s0,16(sp)
    8000326a:	e426                	sd	s1,8(sp)
    8000326c:	e04a                	sd	s2,0(sp)
    8000326e:	1000                	addi	s0,sp,32
    80003270:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003272:	00850913          	addi	s2,a0,8
    80003276:	854a                	mv	a0,s2
    80003278:	45a020ef          	jal	ra,800056d2 <acquire>
  while (lk->locked) {
    8000327c:	409c                	lw	a5,0(s1)
    8000327e:	c799                	beqz	a5,8000328c <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003280:	85ca                	mv	a1,s2
    80003282:	8526                	mv	a0,s1
    80003284:	982fe0ef          	jal	ra,80001406 <sleep>
  while (lk->locked) {
    80003288:	409c                	lw	a5,0(s1)
    8000328a:	fbfd                	bnez	a5,80003280 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000328c:	4785                	li	a5,1
    8000328e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003290:	babfd0ef          	jal	ra,80000e3a <myproc>
    80003294:	591c                	lw	a5,48(a0)
    80003296:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003298:	854a                	mv	a0,s2
    8000329a:	4d0020ef          	jal	ra,8000576a <release>
}
    8000329e:	60e2                	ld	ra,24(sp)
    800032a0:	6442                	ld	s0,16(sp)
    800032a2:	64a2                	ld	s1,8(sp)
    800032a4:	6902                	ld	s2,0(sp)
    800032a6:	6105                	addi	sp,sp,32
    800032a8:	8082                	ret

00000000800032aa <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800032aa:	1101                	addi	sp,sp,-32
    800032ac:	ec06                	sd	ra,24(sp)
    800032ae:	e822                	sd	s0,16(sp)
    800032b0:	e426                	sd	s1,8(sp)
    800032b2:	e04a                	sd	s2,0(sp)
    800032b4:	1000                	addi	s0,sp,32
    800032b6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800032b8:	00850913          	addi	s2,a0,8
    800032bc:	854a                	mv	a0,s2
    800032be:	414020ef          	jal	ra,800056d2 <acquire>
  lk->locked = 0;
    800032c2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800032c6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800032ca:	8526                	mv	a0,s1
    800032cc:	986fe0ef          	jal	ra,80001452 <wakeup>
  release(&lk->lk);
    800032d0:	854a                	mv	a0,s2
    800032d2:	498020ef          	jal	ra,8000576a <release>
}
    800032d6:	60e2                	ld	ra,24(sp)
    800032d8:	6442                	ld	s0,16(sp)
    800032da:	64a2                	ld	s1,8(sp)
    800032dc:	6902                	ld	s2,0(sp)
    800032de:	6105                	addi	sp,sp,32
    800032e0:	8082                	ret

00000000800032e2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800032e2:	7179                	addi	sp,sp,-48
    800032e4:	f406                	sd	ra,40(sp)
    800032e6:	f022                	sd	s0,32(sp)
    800032e8:	ec26                	sd	s1,24(sp)
    800032ea:	e84a                	sd	s2,16(sp)
    800032ec:	e44e                	sd	s3,8(sp)
    800032ee:	1800                	addi	s0,sp,48
    800032f0:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800032f2:	00850913          	addi	s2,a0,8
    800032f6:	854a                	mv	a0,s2
    800032f8:	3da020ef          	jal	ra,800056d2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800032fc:	409c                	lw	a5,0(s1)
    800032fe:	ef89                	bnez	a5,80003318 <holdingsleep+0x36>
    80003300:	4481                	li	s1,0
  release(&lk->lk);
    80003302:	854a                	mv	a0,s2
    80003304:	466020ef          	jal	ra,8000576a <release>
  return r;
}
    80003308:	8526                	mv	a0,s1
    8000330a:	70a2                	ld	ra,40(sp)
    8000330c:	7402                	ld	s0,32(sp)
    8000330e:	64e2                	ld	s1,24(sp)
    80003310:	6942                	ld	s2,16(sp)
    80003312:	69a2                	ld	s3,8(sp)
    80003314:	6145                	addi	sp,sp,48
    80003316:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003318:	0284a983          	lw	s3,40(s1)
    8000331c:	b1ffd0ef          	jal	ra,80000e3a <myproc>
    80003320:	5904                	lw	s1,48(a0)
    80003322:	413484b3          	sub	s1,s1,s3
    80003326:	0014b493          	seqz	s1,s1
    8000332a:	bfe1                	j	80003302 <holdingsleep+0x20>

000000008000332c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000332c:	1141                	addi	sp,sp,-16
    8000332e:	e406                	sd	ra,8(sp)
    80003330:	e022                	sd	s0,0(sp)
    80003332:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003334:	00004597          	auipc	a1,0x4
    80003338:	3cc58593          	addi	a1,a1,972 # 80007700 <syscalls+0x2a0>
    8000333c:	00014517          	auipc	a0,0x14
    80003340:	7cc50513          	addi	a0,a0,1996 # 80017b08 <ftable>
    80003344:	30e020ef          	jal	ra,80005652 <initlock>
}
    80003348:	60a2                	ld	ra,8(sp)
    8000334a:	6402                	ld	s0,0(sp)
    8000334c:	0141                	addi	sp,sp,16
    8000334e:	8082                	ret

0000000080003350 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003350:	1101                	addi	sp,sp,-32
    80003352:	ec06                	sd	ra,24(sp)
    80003354:	e822                	sd	s0,16(sp)
    80003356:	e426                	sd	s1,8(sp)
    80003358:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000335a:	00014517          	auipc	a0,0x14
    8000335e:	7ae50513          	addi	a0,a0,1966 # 80017b08 <ftable>
    80003362:	370020ef          	jal	ra,800056d2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003366:	00014497          	auipc	s1,0x14
    8000336a:	7ba48493          	addi	s1,s1,1978 # 80017b20 <ftable+0x18>
    8000336e:	00015717          	auipc	a4,0x15
    80003372:	75270713          	addi	a4,a4,1874 # 80018ac0 <disk>
    if(f->ref == 0){
    80003376:	40dc                	lw	a5,4(s1)
    80003378:	cf89                	beqz	a5,80003392 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000337a:	02848493          	addi	s1,s1,40
    8000337e:	fee49ce3          	bne	s1,a4,80003376 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003382:	00014517          	auipc	a0,0x14
    80003386:	78650513          	addi	a0,a0,1926 # 80017b08 <ftable>
    8000338a:	3e0020ef          	jal	ra,8000576a <release>
  return 0;
    8000338e:	4481                	li	s1,0
    80003390:	a809                	j	800033a2 <filealloc+0x52>
      f->ref = 1;
    80003392:	4785                	li	a5,1
    80003394:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003396:	00014517          	auipc	a0,0x14
    8000339a:	77250513          	addi	a0,a0,1906 # 80017b08 <ftable>
    8000339e:	3cc020ef          	jal	ra,8000576a <release>
}
    800033a2:	8526                	mv	a0,s1
    800033a4:	60e2                	ld	ra,24(sp)
    800033a6:	6442                	ld	s0,16(sp)
    800033a8:	64a2                	ld	s1,8(sp)
    800033aa:	6105                	addi	sp,sp,32
    800033ac:	8082                	ret

00000000800033ae <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800033ae:	1101                	addi	sp,sp,-32
    800033b0:	ec06                	sd	ra,24(sp)
    800033b2:	e822                	sd	s0,16(sp)
    800033b4:	e426                	sd	s1,8(sp)
    800033b6:	1000                	addi	s0,sp,32
    800033b8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800033ba:	00014517          	auipc	a0,0x14
    800033be:	74e50513          	addi	a0,a0,1870 # 80017b08 <ftable>
    800033c2:	310020ef          	jal	ra,800056d2 <acquire>
  if(f->ref < 1)
    800033c6:	40dc                	lw	a5,4(s1)
    800033c8:	02f05063          	blez	a5,800033e8 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800033cc:	2785                	addiw	a5,a5,1
    800033ce:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800033d0:	00014517          	auipc	a0,0x14
    800033d4:	73850513          	addi	a0,a0,1848 # 80017b08 <ftable>
    800033d8:	392020ef          	jal	ra,8000576a <release>
  return f;
}
    800033dc:	8526                	mv	a0,s1
    800033de:	60e2                	ld	ra,24(sp)
    800033e0:	6442                	ld	s0,16(sp)
    800033e2:	64a2                	ld	s1,8(sp)
    800033e4:	6105                	addi	sp,sp,32
    800033e6:	8082                	ret
    panic("filedup");
    800033e8:	00004517          	auipc	a0,0x4
    800033ec:	32050513          	addi	a0,a0,800 # 80007708 <syscalls+0x2a8>
    800033f0:	7d3010ef          	jal	ra,800053c2 <panic>

00000000800033f4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800033f4:	7139                	addi	sp,sp,-64
    800033f6:	fc06                	sd	ra,56(sp)
    800033f8:	f822                	sd	s0,48(sp)
    800033fa:	f426                	sd	s1,40(sp)
    800033fc:	f04a                	sd	s2,32(sp)
    800033fe:	ec4e                	sd	s3,24(sp)
    80003400:	e852                	sd	s4,16(sp)
    80003402:	e456                	sd	s5,8(sp)
    80003404:	0080                	addi	s0,sp,64
    80003406:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003408:	00014517          	auipc	a0,0x14
    8000340c:	70050513          	addi	a0,a0,1792 # 80017b08 <ftable>
    80003410:	2c2020ef          	jal	ra,800056d2 <acquire>
  if(f->ref < 1)
    80003414:	40dc                	lw	a5,4(s1)
    80003416:	04f05963          	blez	a5,80003468 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    8000341a:	37fd                	addiw	a5,a5,-1
    8000341c:	0007871b          	sext.w	a4,a5
    80003420:	c0dc                	sw	a5,4(s1)
    80003422:	04e04963          	bgtz	a4,80003474 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003426:	0004a903          	lw	s2,0(s1)
    8000342a:	0094ca83          	lbu	s5,9(s1)
    8000342e:	0104ba03          	ld	s4,16(s1)
    80003432:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003436:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000343a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000343e:	00014517          	auipc	a0,0x14
    80003442:	6ca50513          	addi	a0,a0,1738 # 80017b08 <ftable>
    80003446:	324020ef          	jal	ra,8000576a <release>

  if(ff.type == FD_PIPE){
    8000344a:	4785                	li	a5,1
    8000344c:	04f90363          	beq	s2,a5,80003492 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003450:	3979                	addiw	s2,s2,-2
    80003452:	4785                	li	a5,1
    80003454:	0327e663          	bltu	a5,s2,80003480 <fileclose+0x8c>
    begin_op();
    80003458:	b85ff0ef          	jal	ra,80002fdc <begin_op>
    iput(ff.ip);
    8000345c:	854e                	mv	a0,s3
    8000345e:	c68ff0ef          	jal	ra,800028c6 <iput>
    end_op();
    80003462:	be9ff0ef          	jal	ra,8000304a <end_op>
    80003466:	a829                	j	80003480 <fileclose+0x8c>
    panic("fileclose");
    80003468:	00004517          	auipc	a0,0x4
    8000346c:	2a850513          	addi	a0,a0,680 # 80007710 <syscalls+0x2b0>
    80003470:	753010ef          	jal	ra,800053c2 <panic>
    release(&ftable.lock);
    80003474:	00014517          	auipc	a0,0x14
    80003478:	69450513          	addi	a0,a0,1684 # 80017b08 <ftable>
    8000347c:	2ee020ef          	jal	ra,8000576a <release>
  }
}
    80003480:	70e2                	ld	ra,56(sp)
    80003482:	7442                	ld	s0,48(sp)
    80003484:	74a2                	ld	s1,40(sp)
    80003486:	7902                	ld	s2,32(sp)
    80003488:	69e2                	ld	s3,24(sp)
    8000348a:	6a42                	ld	s4,16(sp)
    8000348c:	6aa2                	ld	s5,8(sp)
    8000348e:	6121                	addi	sp,sp,64
    80003490:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003492:	85d6                	mv	a1,s5
    80003494:	8552                	mv	a0,s4
    80003496:	2ec000ef          	jal	ra,80003782 <pipeclose>
    8000349a:	b7dd                	j	80003480 <fileclose+0x8c>

000000008000349c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000349c:	715d                	addi	sp,sp,-80
    8000349e:	e486                	sd	ra,72(sp)
    800034a0:	e0a2                	sd	s0,64(sp)
    800034a2:	fc26                	sd	s1,56(sp)
    800034a4:	f84a                	sd	s2,48(sp)
    800034a6:	f44e                	sd	s3,40(sp)
    800034a8:	0880                	addi	s0,sp,80
    800034aa:	84aa                	mv	s1,a0
    800034ac:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800034ae:	98dfd0ef          	jal	ra,80000e3a <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800034b2:	409c                	lw	a5,0(s1)
    800034b4:	37f9                	addiw	a5,a5,-2
    800034b6:	4705                	li	a4,1
    800034b8:	02f76f63          	bltu	a4,a5,800034f6 <filestat+0x5a>
    800034bc:	892a                	mv	s2,a0
    ilock(f->ip);
    800034be:	6c88                	ld	a0,24(s1)
    800034c0:	a88ff0ef          	jal	ra,80002748 <ilock>
    stati(f->ip, &st);
    800034c4:	fb840593          	addi	a1,s0,-72
    800034c8:	6c88                	ld	a0,24(s1)
    800034ca:	ca4ff0ef          	jal	ra,8000296e <stati>
    iunlock(f->ip);
    800034ce:	6c88                	ld	a0,24(s1)
    800034d0:	b22ff0ef          	jal	ra,800027f2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800034d4:	46e1                	li	a3,24
    800034d6:	fb840613          	addi	a2,s0,-72
    800034da:	85ce                	mv	a1,s3
    800034dc:	05093503          	ld	a0,80(s2)
    800034e0:	cfefd0ef          	jal	ra,800009de <copyout>
    800034e4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800034e8:	60a6                	ld	ra,72(sp)
    800034ea:	6406                	ld	s0,64(sp)
    800034ec:	74e2                	ld	s1,56(sp)
    800034ee:	7942                	ld	s2,48(sp)
    800034f0:	79a2                	ld	s3,40(sp)
    800034f2:	6161                	addi	sp,sp,80
    800034f4:	8082                	ret
  return -1;
    800034f6:	557d                	li	a0,-1
    800034f8:	bfc5                	j	800034e8 <filestat+0x4c>

00000000800034fa <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800034fa:	7179                	addi	sp,sp,-48
    800034fc:	f406                	sd	ra,40(sp)
    800034fe:	f022                	sd	s0,32(sp)
    80003500:	ec26                	sd	s1,24(sp)
    80003502:	e84a                	sd	s2,16(sp)
    80003504:	e44e                	sd	s3,8(sp)
    80003506:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003508:	00854783          	lbu	a5,8(a0)
    8000350c:	cbc1                	beqz	a5,8000359c <fileread+0xa2>
    8000350e:	84aa                	mv	s1,a0
    80003510:	89ae                	mv	s3,a1
    80003512:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003514:	411c                	lw	a5,0(a0)
    80003516:	4705                	li	a4,1
    80003518:	04e78363          	beq	a5,a4,8000355e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000351c:	470d                	li	a4,3
    8000351e:	04e78563          	beq	a5,a4,80003568 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003522:	4709                	li	a4,2
    80003524:	06e79663          	bne	a5,a4,80003590 <fileread+0x96>
    ilock(f->ip);
    80003528:	6d08                	ld	a0,24(a0)
    8000352a:	a1eff0ef          	jal	ra,80002748 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000352e:	874a                	mv	a4,s2
    80003530:	5094                	lw	a3,32(s1)
    80003532:	864e                	mv	a2,s3
    80003534:	4585                	li	a1,1
    80003536:	6c88                	ld	a0,24(s1)
    80003538:	c60ff0ef          	jal	ra,80002998 <readi>
    8000353c:	892a                	mv	s2,a0
    8000353e:	00a05563          	blez	a0,80003548 <fileread+0x4e>
      f->off += r;
    80003542:	509c                	lw	a5,32(s1)
    80003544:	9fa9                	addw	a5,a5,a0
    80003546:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003548:	6c88                	ld	a0,24(s1)
    8000354a:	aa8ff0ef          	jal	ra,800027f2 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000354e:	854a                	mv	a0,s2
    80003550:	70a2                	ld	ra,40(sp)
    80003552:	7402                	ld	s0,32(sp)
    80003554:	64e2                	ld	s1,24(sp)
    80003556:	6942                	ld	s2,16(sp)
    80003558:	69a2                	ld	s3,8(sp)
    8000355a:	6145                	addi	sp,sp,48
    8000355c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000355e:	6908                	ld	a0,16(a0)
    80003560:	34e000ef          	jal	ra,800038ae <piperead>
    80003564:	892a                	mv	s2,a0
    80003566:	b7e5                	j	8000354e <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003568:	02451783          	lh	a5,36(a0)
    8000356c:	03079693          	slli	a3,a5,0x30
    80003570:	92c1                	srli	a3,a3,0x30
    80003572:	4725                	li	a4,9
    80003574:	02d76663          	bltu	a4,a3,800035a0 <fileread+0xa6>
    80003578:	0792                	slli	a5,a5,0x4
    8000357a:	00014717          	auipc	a4,0x14
    8000357e:	4ee70713          	addi	a4,a4,1262 # 80017a68 <devsw>
    80003582:	97ba                	add	a5,a5,a4
    80003584:	639c                	ld	a5,0(a5)
    80003586:	cf99                	beqz	a5,800035a4 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80003588:	4505                	li	a0,1
    8000358a:	9782                	jalr	a5
    8000358c:	892a                	mv	s2,a0
    8000358e:	b7c1                	j	8000354e <fileread+0x54>
    panic("fileread");
    80003590:	00004517          	auipc	a0,0x4
    80003594:	19050513          	addi	a0,a0,400 # 80007720 <syscalls+0x2c0>
    80003598:	62b010ef          	jal	ra,800053c2 <panic>
    return -1;
    8000359c:	597d                	li	s2,-1
    8000359e:	bf45                	j	8000354e <fileread+0x54>
      return -1;
    800035a0:	597d                	li	s2,-1
    800035a2:	b775                	j	8000354e <fileread+0x54>
    800035a4:	597d                	li	s2,-1
    800035a6:	b765                	j	8000354e <fileread+0x54>

00000000800035a8 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800035a8:	715d                	addi	sp,sp,-80
    800035aa:	e486                	sd	ra,72(sp)
    800035ac:	e0a2                	sd	s0,64(sp)
    800035ae:	fc26                	sd	s1,56(sp)
    800035b0:	f84a                	sd	s2,48(sp)
    800035b2:	f44e                	sd	s3,40(sp)
    800035b4:	f052                	sd	s4,32(sp)
    800035b6:	ec56                	sd	s5,24(sp)
    800035b8:	e85a                	sd	s6,16(sp)
    800035ba:	e45e                	sd	s7,8(sp)
    800035bc:	e062                	sd	s8,0(sp)
    800035be:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800035c0:	00954783          	lbu	a5,9(a0)
    800035c4:	0e078863          	beqz	a5,800036b4 <filewrite+0x10c>
    800035c8:	892a                	mv	s2,a0
    800035ca:	8b2e                	mv	s6,a1
    800035cc:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800035ce:	411c                	lw	a5,0(a0)
    800035d0:	4705                	li	a4,1
    800035d2:	02e78263          	beq	a5,a4,800035f6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800035d6:	470d                	li	a4,3
    800035d8:	02e78463          	beq	a5,a4,80003600 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800035dc:	4709                	li	a4,2
    800035de:	0ce79563          	bne	a5,a4,800036a8 <filewrite+0x100>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800035e2:	0ac05163          	blez	a2,80003684 <filewrite+0xdc>
    int i = 0;
    800035e6:	4981                	li	s3,0
    800035e8:	6b85                	lui	s7,0x1
    800035ea:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800035ee:	6c05                	lui	s8,0x1
    800035f0:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800035f4:	a041                	j	80003674 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800035f6:	6908                	ld	a0,16(a0)
    800035f8:	1e2000ef          	jal	ra,800037da <pipewrite>
    800035fc:	8a2a                	mv	s4,a0
    800035fe:	a071                	j	8000368a <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003600:	02451783          	lh	a5,36(a0)
    80003604:	03079693          	slli	a3,a5,0x30
    80003608:	92c1                	srli	a3,a3,0x30
    8000360a:	4725                	li	a4,9
    8000360c:	0ad76663          	bltu	a4,a3,800036b8 <filewrite+0x110>
    80003610:	0792                	slli	a5,a5,0x4
    80003612:	00014717          	auipc	a4,0x14
    80003616:	45670713          	addi	a4,a4,1110 # 80017a68 <devsw>
    8000361a:	97ba                	add	a5,a5,a4
    8000361c:	679c                	ld	a5,8(a5)
    8000361e:	cfd9                	beqz	a5,800036bc <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80003620:	4505                	li	a0,1
    80003622:	9782                	jalr	a5
    80003624:	8a2a                	mv	s4,a0
    80003626:	a095                	j	8000368a <filewrite+0xe2>
    80003628:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000362c:	9b1ff0ef          	jal	ra,80002fdc <begin_op>
      ilock(f->ip);
    80003630:	01893503          	ld	a0,24(s2)
    80003634:	914ff0ef          	jal	ra,80002748 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003638:	8756                	mv	a4,s5
    8000363a:	02092683          	lw	a3,32(s2)
    8000363e:	01698633          	add	a2,s3,s6
    80003642:	4585                	li	a1,1
    80003644:	01893503          	ld	a0,24(s2)
    80003648:	c34ff0ef          	jal	ra,80002a7c <writei>
    8000364c:	84aa                	mv	s1,a0
    8000364e:	00a05763          	blez	a0,8000365c <filewrite+0xb4>
        f->off += r;
    80003652:	02092783          	lw	a5,32(s2)
    80003656:	9fa9                	addw	a5,a5,a0
    80003658:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000365c:	01893503          	ld	a0,24(s2)
    80003660:	992ff0ef          	jal	ra,800027f2 <iunlock>
      end_op();
    80003664:	9e7ff0ef          	jal	ra,8000304a <end_op>

      if(r != n1){
    80003668:	009a9f63          	bne	s5,s1,80003686 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    8000366c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003670:	0149db63          	bge	s3,s4,80003686 <filewrite+0xde>
      int n1 = n - i;
    80003674:	413a04bb          	subw	s1,s4,s3
    80003678:	0004879b          	sext.w	a5,s1
    8000367c:	fafbd6e3          	bge	s7,a5,80003628 <filewrite+0x80>
    80003680:	84e2                	mv	s1,s8
    80003682:	b75d                	j	80003628 <filewrite+0x80>
    int i = 0;
    80003684:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003686:	013a1f63          	bne	s4,s3,800036a4 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000368a:	8552                	mv	a0,s4
    8000368c:	60a6                	ld	ra,72(sp)
    8000368e:	6406                	ld	s0,64(sp)
    80003690:	74e2                	ld	s1,56(sp)
    80003692:	7942                	ld	s2,48(sp)
    80003694:	79a2                	ld	s3,40(sp)
    80003696:	7a02                	ld	s4,32(sp)
    80003698:	6ae2                	ld	s5,24(sp)
    8000369a:	6b42                	ld	s6,16(sp)
    8000369c:	6ba2                	ld	s7,8(sp)
    8000369e:	6c02                	ld	s8,0(sp)
    800036a0:	6161                	addi	sp,sp,80
    800036a2:	8082                	ret
    ret = (i == n ? n : -1);
    800036a4:	5a7d                	li	s4,-1
    800036a6:	b7d5                	j	8000368a <filewrite+0xe2>
    panic("filewrite");
    800036a8:	00004517          	auipc	a0,0x4
    800036ac:	08850513          	addi	a0,a0,136 # 80007730 <syscalls+0x2d0>
    800036b0:	513010ef          	jal	ra,800053c2 <panic>
    return -1;
    800036b4:	5a7d                	li	s4,-1
    800036b6:	bfd1                	j	8000368a <filewrite+0xe2>
      return -1;
    800036b8:	5a7d                	li	s4,-1
    800036ba:	bfc1                	j	8000368a <filewrite+0xe2>
    800036bc:	5a7d                	li	s4,-1
    800036be:	b7f1                	j	8000368a <filewrite+0xe2>

00000000800036c0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800036c0:	7179                	addi	sp,sp,-48
    800036c2:	f406                	sd	ra,40(sp)
    800036c4:	f022                	sd	s0,32(sp)
    800036c6:	ec26                	sd	s1,24(sp)
    800036c8:	e84a                	sd	s2,16(sp)
    800036ca:	e44e                	sd	s3,8(sp)
    800036cc:	e052                	sd	s4,0(sp)
    800036ce:	1800                	addi	s0,sp,48
    800036d0:	84aa                	mv	s1,a0
    800036d2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800036d4:	0005b023          	sd	zero,0(a1)
    800036d8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800036dc:	c75ff0ef          	jal	ra,80003350 <filealloc>
    800036e0:	e088                	sd	a0,0(s1)
    800036e2:	cd35                	beqz	a0,8000375e <pipealloc+0x9e>
    800036e4:	c6dff0ef          	jal	ra,80003350 <filealloc>
    800036e8:	00aa3023          	sd	a0,0(s4)
    800036ec:	c52d                	beqz	a0,80003756 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800036ee:	a11fc0ef          	jal	ra,800000fe <kalloc>
    800036f2:	892a                	mv	s2,a0
    800036f4:	cd31                	beqz	a0,80003750 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    800036f6:	4985                	li	s3,1
    800036f8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800036fc:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003700:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003704:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003708:	00004597          	auipc	a1,0x4
    8000370c:	03858593          	addi	a1,a1,56 # 80007740 <syscalls+0x2e0>
    80003710:	743010ef          	jal	ra,80005652 <initlock>
  (*f0)->type = FD_PIPE;
    80003714:	609c                	ld	a5,0(s1)
    80003716:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000371a:	609c                	ld	a5,0(s1)
    8000371c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003720:	609c                	ld	a5,0(s1)
    80003722:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003726:	609c                	ld	a5,0(s1)
    80003728:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000372c:	000a3783          	ld	a5,0(s4)
    80003730:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003734:	000a3783          	ld	a5,0(s4)
    80003738:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000373c:	000a3783          	ld	a5,0(s4)
    80003740:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003744:	000a3783          	ld	a5,0(s4)
    80003748:	0127b823          	sd	s2,16(a5)
  return 0;
    8000374c:	4501                	li	a0,0
    8000374e:	a005                	j	8000376e <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003750:	6088                	ld	a0,0(s1)
    80003752:	e501                	bnez	a0,8000375a <pipealloc+0x9a>
    80003754:	a029                	j	8000375e <pipealloc+0x9e>
    80003756:	6088                	ld	a0,0(s1)
    80003758:	c11d                	beqz	a0,8000377e <pipealloc+0xbe>
    fileclose(*f0);
    8000375a:	c9bff0ef          	jal	ra,800033f4 <fileclose>
  if(*f1)
    8000375e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003762:	557d                	li	a0,-1
  if(*f1)
    80003764:	c789                	beqz	a5,8000376e <pipealloc+0xae>
    fileclose(*f1);
    80003766:	853e                	mv	a0,a5
    80003768:	c8dff0ef          	jal	ra,800033f4 <fileclose>
  return -1;
    8000376c:	557d                	li	a0,-1
}
    8000376e:	70a2                	ld	ra,40(sp)
    80003770:	7402                	ld	s0,32(sp)
    80003772:	64e2                	ld	s1,24(sp)
    80003774:	6942                	ld	s2,16(sp)
    80003776:	69a2                	ld	s3,8(sp)
    80003778:	6a02                	ld	s4,0(sp)
    8000377a:	6145                	addi	sp,sp,48
    8000377c:	8082                	ret
  return -1;
    8000377e:	557d                	li	a0,-1
    80003780:	b7fd                	j	8000376e <pipealloc+0xae>

0000000080003782 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003782:	1101                	addi	sp,sp,-32
    80003784:	ec06                	sd	ra,24(sp)
    80003786:	e822                	sd	s0,16(sp)
    80003788:	e426                	sd	s1,8(sp)
    8000378a:	e04a                	sd	s2,0(sp)
    8000378c:	1000                	addi	s0,sp,32
    8000378e:	84aa                	mv	s1,a0
    80003790:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003792:	741010ef          	jal	ra,800056d2 <acquire>
  if(writable){
    80003796:	02090763          	beqz	s2,800037c4 <pipeclose+0x42>
    pi->writeopen = 0;
    8000379a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000379e:	21848513          	addi	a0,s1,536
    800037a2:	cb1fd0ef          	jal	ra,80001452 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800037a6:	2204b783          	ld	a5,544(s1)
    800037aa:	e785                	bnez	a5,800037d2 <pipeclose+0x50>
    release(&pi->lock);
    800037ac:	8526                	mv	a0,s1
    800037ae:	7bd010ef          	jal	ra,8000576a <release>
    kfree((char*)pi);
    800037b2:	8526                	mv	a0,s1
    800037b4:	869fc0ef          	jal	ra,8000001c <kfree>
  } else
    release(&pi->lock);
}
    800037b8:	60e2                	ld	ra,24(sp)
    800037ba:	6442                	ld	s0,16(sp)
    800037bc:	64a2                	ld	s1,8(sp)
    800037be:	6902                	ld	s2,0(sp)
    800037c0:	6105                	addi	sp,sp,32
    800037c2:	8082                	ret
    pi->readopen = 0;
    800037c4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800037c8:	21c48513          	addi	a0,s1,540
    800037cc:	c87fd0ef          	jal	ra,80001452 <wakeup>
    800037d0:	bfd9                	j	800037a6 <pipeclose+0x24>
    release(&pi->lock);
    800037d2:	8526                	mv	a0,s1
    800037d4:	797010ef          	jal	ra,8000576a <release>
}
    800037d8:	b7c5                	j	800037b8 <pipeclose+0x36>

00000000800037da <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800037da:	711d                	addi	sp,sp,-96
    800037dc:	ec86                	sd	ra,88(sp)
    800037de:	e8a2                	sd	s0,80(sp)
    800037e0:	e4a6                	sd	s1,72(sp)
    800037e2:	e0ca                	sd	s2,64(sp)
    800037e4:	fc4e                	sd	s3,56(sp)
    800037e6:	f852                	sd	s4,48(sp)
    800037e8:	f456                	sd	s5,40(sp)
    800037ea:	f05a                	sd	s6,32(sp)
    800037ec:	ec5e                	sd	s7,24(sp)
    800037ee:	e862                	sd	s8,16(sp)
    800037f0:	1080                	addi	s0,sp,96
    800037f2:	84aa                	mv	s1,a0
    800037f4:	8aae                	mv	s5,a1
    800037f6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800037f8:	e42fd0ef          	jal	ra,80000e3a <myproc>
    800037fc:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800037fe:	8526                	mv	a0,s1
    80003800:	6d3010ef          	jal	ra,800056d2 <acquire>
  while(i < n){
    80003804:	09405c63          	blez	s4,8000389c <pipewrite+0xc2>
  int i = 0;
    80003808:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000380a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000380c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003810:	21c48b93          	addi	s7,s1,540
    80003814:	a81d                	j	8000384a <pipewrite+0x70>
      release(&pi->lock);
    80003816:	8526                	mv	a0,s1
    80003818:	753010ef          	jal	ra,8000576a <release>
      return -1;
    8000381c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000381e:	854a                	mv	a0,s2
    80003820:	60e6                	ld	ra,88(sp)
    80003822:	6446                	ld	s0,80(sp)
    80003824:	64a6                	ld	s1,72(sp)
    80003826:	6906                	ld	s2,64(sp)
    80003828:	79e2                	ld	s3,56(sp)
    8000382a:	7a42                	ld	s4,48(sp)
    8000382c:	7aa2                	ld	s5,40(sp)
    8000382e:	7b02                	ld	s6,32(sp)
    80003830:	6be2                	ld	s7,24(sp)
    80003832:	6c42                	ld	s8,16(sp)
    80003834:	6125                	addi	sp,sp,96
    80003836:	8082                	ret
      wakeup(&pi->nread);
    80003838:	8562                	mv	a0,s8
    8000383a:	c19fd0ef          	jal	ra,80001452 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000383e:	85a6                	mv	a1,s1
    80003840:	855e                	mv	a0,s7
    80003842:	bc5fd0ef          	jal	ra,80001406 <sleep>
  while(i < n){
    80003846:	05495c63          	bge	s2,s4,8000389e <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    8000384a:	2204a783          	lw	a5,544(s1)
    8000384e:	d7e1                	beqz	a5,80003816 <pipewrite+0x3c>
    80003850:	854e                	mv	a0,s3
    80003852:	dedfd0ef          	jal	ra,8000163e <killed>
    80003856:	f161                	bnez	a0,80003816 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003858:	2184a783          	lw	a5,536(s1)
    8000385c:	21c4a703          	lw	a4,540(s1)
    80003860:	2007879b          	addiw	a5,a5,512
    80003864:	fcf70ae3          	beq	a4,a5,80003838 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003868:	4685                	li	a3,1
    8000386a:	01590633          	add	a2,s2,s5
    8000386e:	faf40593          	addi	a1,s0,-81
    80003872:	0509b503          	ld	a0,80(s3)
    80003876:	a20fd0ef          	jal	ra,80000a96 <copyin>
    8000387a:	03650263          	beq	a0,s6,8000389e <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000387e:	21c4a783          	lw	a5,540(s1)
    80003882:	0017871b          	addiw	a4,a5,1
    80003886:	20e4ae23          	sw	a4,540(s1)
    8000388a:	1ff7f793          	andi	a5,a5,511
    8000388e:	97a6                	add	a5,a5,s1
    80003890:	faf44703          	lbu	a4,-81(s0)
    80003894:	00e78c23          	sb	a4,24(a5)
      i++;
    80003898:	2905                	addiw	s2,s2,1
    8000389a:	b775                	j	80003846 <pipewrite+0x6c>
  int i = 0;
    8000389c:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000389e:	21848513          	addi	a0,s1,536
    800038a2:	bb1fd0ef          	jal	ra,80001452 <wakeup>
  release(&pi->lock);
    800038a6:	8526                	mv	a0,s1
    800038a8:	6c3010ef          	jal	ra,8000576a <release>
  return i;
    800038ac:	bf8d                	j	8000381e <pipewrite+0x44>

00000000800038ae <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800038ae:	715d                	addi	sp,sp,-80
    800038b0:	e486                	sd	ra,72(sp)
    800038b2:	e0a2                	sd	s0,64(sp)
    800038b4:	fc26                	sd	s1,56(sp)
    800038b6:	f84a                	sd	s2,48(sp)
    800038b8:	f44e                	sd	s3,40(sp)
    800038ba:	f052                	sd	s4,32(sp)
    800038bc:	ec56                	sd	s5,24(sp)
    800038be:	e85a                	sd	s6,16(sp)
    800038c0:	0880                	addi	s0,sp,80
    800038c2:	84aa                	mv	s1,a0
    800038c4:	892e                	mv	s2,a1
    800038c6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800038c8:	d72fd0ef          	jal	ra,80000e3a <myproc>
    800038cc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800038ce:	8526                	mv	a0,s1
    800038d0:	603010ef          	jal	ra,800056d2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800038d4:	2184a703          	lw	a4,536(s1)
    800038d8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800038dc:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800038e0:	02f71363          	bne	a4,a5,80003906 <piperead+0x58>
    800038e4:	2244a783          	lw	a5,548(s1)
    800038e8:	cf99                	beqz	a5,80003906 <piperead+0x58>
    if(killed(pr)){
    800038ea:	8552                	mv	a0,s4
    800038ec:	d53fd0ef          	jal	ra,8000163e <killed>
    800038f0:	e149                	bnez	a0,80003972 <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800038f2:	85a6                	mv	a1,s1
    800038f4:	854e                	mv	a0,s3
    800038f6:	b11fd0ef          	jal	ra,80001406 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800038fa:	2184a703          	lw	a4,536(s1)
    800038fe:	21c4a783          	lw	a5,540(s1)
    80003902:	fef701e3          	beq	a4,a5,800038e4 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003906:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003908:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000390a:	05505263          	blez	s5,8000394e <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    8000390e:	2184a783          	lw	a5,536(s1)
    80003912:	21c4a703          	lw	a4,540(s1)
    80003916:	02f70c63          	beq	a4,a5,8000394e <piperead+0xa0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000391a:	0017871b          	addiw	a4,a5,1
    8000391e:	20e4ac23          	sw	a4,536(s1)
    80003922:	1ff7f793          	andi	a5,a5,511
    80003926:	97a6                	add	a5,a5,s1
    80003928:	0187c783          	lbu	a5,24(a5)
    8000392c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003930:	4685                	li	a3,1
    80003932:	fbf40613          	addi	a2,s0,-65
    80003936:	85ca                	mv	a1,s2
    80003938:	050a3503          	ld	a0,80(s4)
    8000393c:	8a2fd0ef          	jal	ra,800009de <copyout>
    80003940:	01650763          	beq	a0,s6,8000394e <piperead+0xa0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003944:	2985                	addiw	s3,s3,1
    80003946:	0905                	addi	s2,s2,1
    80003948:	fd3a93e3          	bne	s5,s3,8000390e <piperead+0x60>
    8000394c:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000394e:	21c48513          	addi	a0,s1,540
    80003952:	b01fd0ef          	jal	ra,80001452 <wakeup>
  release(&pi->lock);
    80003956:	8526                	mv	a0,s1
    80003958:	613010ef          	jal	ra,8000576a <release>
  return i;
}
    8000395c:	854e                	mv	a0,s3
    8000395e:	60a6                	ld	ra,72(sp)
    80003960:	6406                	ld	s0,64(sp)
    80003962:	74e2                	ld	s1,56(sp)
    80003964:	7942                	ld	s2,48(sp)
    80003966:	79a2                	ld	s3,40(sp)
    80003968:	7a02                	ld	s4,32(sp)
    8000396a:	6ae2                	ld	s5,24(sp)
    8000396c:	6b42                	ld	s6,16(sp)
    8000396e:	6161                	addi	sp,sp,80
    80003970:	8082                	ret
      release(&pi->lock);
    80003972:	8526                	mv	a0,s1
    80003974:	5f7010ef          	jal	ra,8000576a <release>
      return -1;
    80003978:	59fd                	li	s3,-1
    8000397a:	b7cd                	j	8000395c <piperead+0xae>

000000008000397c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000397c:	1141                	addi	sp,sp,-16
    8000397e:	e422                	sd	s0,8(sp)
    80003980:	0800                	addi	s0,sp,16
    80003982:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003984:	8905                	andi	a0,a0,1
    80003986:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003988:	8b89                	andi	a5,a5,2
    8000398a:	c399                	beqz	a5,80003990 <flags2perm+0x14>
      perm |= PTE_W;
    8000398c:	00456513          	ori	a0,a0,4
    return perm;
}
    80003990:	6422                	ld	s0,8(sp)
    80003992:	0141                	addi	sp,sp,16
    80003994:	8082                	ret

0000000080003996 <exec>:

int
exec(char *path, char **argv)
{
    80003996:	de010113          	addi	sp,sp,-544
    8000399a:	20113c23          	sd	ra,536(sp)
    8000399e:	20813823          	sd	s0,528(sp)
    800039a2:	20913423          	sd	s1,520(sp)
    800039a6:	21213023          	sd	s2,512(sp)
    800039aa:	ffce                	sd	s3,504(sp)
    800039ac:	fbd2                	sd	s4,496(sp)
    800039ae:	f7d6                	sd	s5,488(sp)
    800039b0:	f3da                	sd	s6,480(sp)
    800039b2:	efde                	sd	s7,472(sp)
    800039b4:	ebe2                	sd	s8,464(sp)
    800039b6:	e7e6                	sd	s9,456(sp)
    800039b8:	e3ea                	sd	s10,448(sp)
    800039ba:	ff6e                	sd	s11,440(sp)
    800039bc:	1400                	addi	s0,sp,544
    800039be:	892a                	mv	s2,a0
    800039c0:	dea43423          	sd	a0,-536(s0)
    800039c4:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800039c8:	c72fd0ef          	jal	ra,80000e3a <myproc>
    800039cc:	84aa                	mv	s1,a0

  begin_op();
    800039ce:	e0eff0ef          	jal	ra,80002fdc <begin_op>

  if((ip = namei(path)) == 0){
    800039d2:	854a                	mv	a0,s2
    800039d4:	c2cff0ef          	jal	ra,80002e00 <namei>
    800039d8:	c13d                	beqz	a0,80003a3e <exec+0xa8>
    800039da:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800039dc:	d6dfe0ef          	jal	ra,80002748 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800039e0:	04000713          	li	a4,64
    800039e4:	4681                	li	a3,0
    800039e6:	e5040613          	addi	a2,s0,-432
    800039ea:	4581                	li	a1,0
    800039ec:	8556                	mv	a0,s5
    800039ee:	fabfe0ef          	jal	ra,80002998 <readi>
    800039f2:	04000793          	li	a5,64
    800039f6:	00f51a63          	bne	a0,a5,80003a0a <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800039fa:	e5042703          	lw	a4,-432(s0)
    800039fe:	464c47b7          	lui	a5,0x464c4
    80003a02:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003a06:	04f70063          	beq	a4,a5,80003a46 <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003a0a:	8556                	mv	a0,s5
    80003a0c:	f43fe0ef          	jal	ra,8000294e <iunlockput>
    end_op();
    80003a10:	e3aff0ef          	jal	ra,8000304a <end_op>
  }
  return -1;
    80003a14:	557d                	li	a0,-1
}
    80003a16:	21813083          	ld	ra,536(sp)
    80003a1a:	21013403          	ld	s0,528(sp)
    80003a1e:	20813483          	ld	s1,520(sp)
    80003a22:	20013903          	ld	s2,512(sp)
    80003a26:	79fe                	ld	s3,504(sp)
    80003a28:	7a5e                	ld	s4,496(sp)
    80003a2a:	7abe                	ld	s5,488(sp)
    80003a2c:	7b1e                	ld	s6,480(sp)
    80003a2e:	6bfe                	ld	s7,472(sp)
    80003a30:	6c5e                	ld	s8,464(sp)
    80003a32:	6cbe                	ld	s9,456(sp)
    80003a34:	6d1e                	ld	s10,448(sp)
    80003a36:	7dfa                	ld	s11,440(sp)
    80003a38:	22010113          	addi	sp,sp,544
    80003a3c:	8082                	ret
    end_op();
    80003a3e:	e0cff0ef          	jal	ra,8000304a <end_op>
    return -1;
    80003a42:	557d                	li	a0,-1
    80003a44:	bfc9                	j	80003a16 <exec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    80003a46:	8526                	mv	a0,s1
    80003a48:	c9afd0ef          	jal	ra,80000ee2 <proc_pagetable>
    80003a4c:	8b2a                	mv	s6,a0
    80003a4e:	dd55                	beqz	a0,80003a0a <exec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003a50:	e7042783          	lw	a5,-400(s0)
    80003a54:	e8845703          	lhu	a4,-376(s0)
    80003a58:	c325                	beqz	a4,80003ab8 <exec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003a5a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003a5c:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80003a60:	6a05                	lui	s4,0x1
    80003a62:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80003a66:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80003a6a:	6d85                	lui	s11,0x1
    80003a6c:	7d7d                	lui	s10,0xfffff
    80003a6e:	a409                	j	80003c70 <exec+0x2da>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80003a70:	00004517          	auipc	a0,0x4
    80003a74:	cd850513          	addi	a0,a0,-808 # 80007748 <syscalls+0x2e8>
    80003a78:	14b010ef          	jal	ra,800053c2 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003a7c:	874a                	mv	a4,s2
    80003a7e:	009c86bb          	addw	a3,s9,s1
    80003a82:	4581                	li	a1,0
    80003a84:	8556                	mv	a0,s5
    80003a86:	f13fe0ef          	jal	ra,80002998 <readi>
    80003a8a:	2501                	sext.w	a0,a0
    80003a8c:	18a91163          	bne	s2,a0,80003c0e <exec+0x278>
  for(i = 0; i < sz; i += PGSIZE){
    80003a90:	009d84bb          	addw	s1,s11,s1
    80003a94:	013d09bb          	addw	s3,s10,s3
    80003a98:	1b74fc63          	bgeu	s1,s7,80003c50 <exec+0x2ba>
    pa = walkaddr(pagetable, va + i);
    80003a9c:	02049593          	slli	a1,s1,0x20
    80003aa0:	9181                	srli	a1,a1,0x20
    80003aa2:	95e2                	add	a1,a1,s8
    80003aa4:	855a                	mv	a0,s6
    80003aa6:	9c9fc0ef          	jal	ra,8000046e <walkaddr>
    80003aaa:	862a                	mv	a2,a0
    if(pa == 0)
    80003aac:	d171                	beqz	a0,80003a70 <exec+0xda>
      n = PGSIZE;
    80003aae:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80003ab0:	fd49f6e3          	bgeu	s3,s4,80003a7c <exec+0xe6>
      n = sz - i;
    80003ab4:	894e                	mv	s2,s3
    80003ab6:	b7d9                	j	80003a7c <exec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003ab8:	4901                	li	s2,0
  iunlockput(ip);
    80003aba:	8556                	mv	a0,s5
    80003abc:	e93fe0ef          	jal	ra,8000294e <iunlockput>
  end_op();
    80003ac0:	d8aff0ef          	jal	ra,8000304a <end_op>
  p = myproc();
    80003ac4:	b76fd0ef          	jal	ra,80000e3a <myproc>
    80003ac8:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80003aca:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80003ace:	6785                	lui	a5,0x1
    80003ad0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80003ad2:	97ca                	add	a5,a5,s2
    80003ad4:	777d                	lui	a4,0xfffff
    80003ad6:	8ff9                	and	a5,a5,a4
    80003ad8:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003adc:	4691                	li	a3,4
    80003ade:	6609                	lui	a2,0x2
    80003ae0:	963e                	add	a2,a2,a5
    80003ae2:	85be                	mv	a1,a5
    80003ae4:	855a                	mv	a0,s6
    80003ae6:	cf1fc0ef          	jal	ra,800007d6 <uvmalloc>
    80003aea:	8c2a                	mv	s8,a0
  ip = 0;
    80003aec:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003aee:	12050063          	beqz	a0,80003c0e <exec+0x278>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003af2:	75f9                	lui	a1,0xffffe
    80003af4:	95aa                	add	a1,a1,a0
    80003af6:	855a                	mv	a0,s6
    80003af8:	ebdfc0ef          	jal	ra,800009b4 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003afc:	7afd                	lui	s5,0xfffff
    80003afe:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80003b00:	df043783          	ld	a5,-528(s0)
    80003b04:	6388                	ld	a0,0(a5)
    80003b06:	c135                	beqz	a0,80003b6a <exec+0x1d4>
    80003b08:	e9040993          	addi	s3,s0,-368
    80003b0c:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80003b10:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003b12:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003b14:	fb2fc0ef          	jal	ra,800002c6 <strlen>
    80003b18:	0015079b          	addiw	a5,a0,1
    80003b1c:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003b20:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003b24:	11596a63          	bltu	s2,s5,80003c38 <exec+0x2a2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003b28:	df043d83          	ld	s11,-528(s0)
    80003b2c:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80003b30:	8552                	mv	a0,s4
    80003b32:	f94fc0ef          	jal	ra,800002c6 <strlen>
    80003b36:	0015069b          	addiw	a3,a0,1
    80003b3a:	8652                	mv	a2,s4
    80003b3c:	85ca                	mv	a1,s2
    80003b3e:	855a                	mv	a0,s6
    80003b40:	e9ffc0ef          	jal	ra,800009de <copyout>
    80003b44:	0e054e63          	bltz	a0,80003c40 <exec+0x2aa>
    ustack[argc] = sp;
    80003b48:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003b4c:	0485                	addi	s1,s1,1
    80003b4e:	008d8793          	addi	a5,s11,8
    80003b52:	def43823          	sd	a5,-528(s0)
    80003b56:	008db503          	ld	a0,8(s11)
    80003b5a:	c911                	beqz	a0,80003b6e <exec+0x1d8>
    if(argc >= MAXARG)
    80003b5c:	09a1                	addi	s3,s3,8
    80003b5e:	fb3c9be3          	bne	s9,s3,80003b14 <exec+0x17e>
  sz = sz1;
    80003b62:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003b66:	4a81                	li	s5,0
    80003b68:	a05d                	j	80003c0e <exec+0x278>
  sp = sz;
    80003b6a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003b6c:	4481                	li	s1,0
  ustack[argc] = 0;
    80003b6e:	00349793          	slli	a5,s1,0x3
    80003b72:	f9078793          	addi	a5,a5,-112
    80003b76:	97a2                	add	a5,a5,s0
    80003b78:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003b7c:	00148693          	addi	a3,s1,1
    80003b80:	068e                	slli	a3,a3,0x3
    80003b82:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003b86:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80003b8a:	01597663          	bgeu	s2,s5,80003b96 <exec+0x200>
  sz = sz1;
    80003b8e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003b92:	4a81                	li	s5,0
    80003b94:	a8ad                	j	80003c0e <exec+0x278>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003b96:	e9040613          	addi	a2,s0,-368
    80003b9a:	85ca                	mv	a1,s2
    80003b9c:	855a                	mv	a0,s6
    80003b9e:	e41fc0ef          	jal	ra,800009de <copyout>
    80003ba2:	0a054363          	bltz	a0,80003c48 <exec+0x2b2>
  p->trapframe->a1 = sp;
    80003ba6:	058bb783          	ld	a5,88(s7)
    80003baa:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003bae:	de843783          	ld	a5,-536(s0)
    80003bb2:	0007c703          	lbu	a4,0(a5)
    80003bb6:	cf11                	beqz	a4,80003bd2 <exec+0x23c>
    80003bb8:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003bba:	02f00693          	li	a3,47
    80003bbe:	a039                	j	80003bcc <exec+0x236>
      last = s+1;
    80003bc0:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80003bc4:	0785                	addi	a5,a5,1
    80003bc6:	fff7c703          	lbu	a4,-1(a5)
    80003bca:	c701                	beqz	a4,80003bd2 <exec+0x23c>
    if(*s == '/')
    80003bcc:	fed71ce3          	bne	a4,a3,80003bc4 <exec+0x22e>
    80003bd0:	bfc5                	j	80003bc0 <exec+0x22a>
  safestrcpy(p->name, last, sizeof(p->name));
    80003bd2:	4641                	li	a2,16
    80003bd4:	de843583          	ld	a1,-536(s0)
    80003bd8:	158b8513          	addi	a0,s7,344
    80003bdc:	eb8fc0ef          	jal	ra,80000294 <safestrcpy>
  oldpagetable = p->pagetable;
    80003be0:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80003be4:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80003be8:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003bec:	058bb783          	ld	a5,88(s7)
    80003bf0:	e6843703          	ld	a4,-408(s0)
    80003bf4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003bf6:	058bb783          	ld	a5,88(s7)
    80003bfa:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003bfe:	85ea                	mv	a1,s10
    80003c00:	b66fd0ef          	jal	ra,80000f66 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003c04:	0004851b          	sext.w	a0,s1
    80003c08:	b539                	j	80003a16 <exec+0x80>
    80003c0a:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80003c0e:	df843583          	ld	a1,-520(s0)
    80003c12:	855a                	mv	a0,s6
    80003c14:	b52fd0ef          	jal	ra,80000f66 <proc_freepagetable>
  if(ip){
    80003c18:	de0a99e3          	bnez	s5,80003a0a <exec+0x74>
  return -1;
    80003c1c:	557d                	li	a0,-1
    80003c1e:	bbe5                	j	80003a16 <exec+0x80>
    80003c20:	df243c23          	sd	s2,-520(s0)
    80003c24:	b7ed                	j	80003c0e <exec+0x278>
    80003c26:	df243c23          	sd	s2,-520(s0)
    80003c2a:	b7d5                	j	80003c0e <exec+0x278>
    80003c2c:	df243c23          	sd	s2,-520(s0)
    80003c30:	bff9                	j	80003c0e <exec+0x278>
    80003c32:	df243c23          	sd	s2,-520(s0)
    80003c36:	bfe1                	j	80003c0e <exec+0x278>
  sz = sz1;
    80003c38:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003c3c:	4a81                	li	s5,0
    80003c3e:	bfc1                	j	80003c0e <exec+0x278>
  sz = sz1;
    80003c40:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003c44:	4a81                	li	s5,0
    80003c46:	b7e1                	j	80003c0e <exec+0x278>
  sz = sz1;
    80003c48:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003c4c:	4a81                	li	s5,0
    80003c4e:	b7c1                	j	80003c0e <exec+0x278>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003c50:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c54:	e0843783          	ld	a5,-504(s0)
    80003c58:	0017869b          	addiw	a3,a5,1
    80003c5c:	e0d43423          	sd	a3,-504(s0)
    80003c60:	e0043783          	ld	a5,-512(s0)
    80003c64:	0387879b          	addiw	a5,a5,56
    80003c68:	e8845703          	lhu	a4,-376(s0)
    80003c6c:	e4e6d7e3          	bge	a3,a4,80003aba <exec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003c70:	2781                	sext.w	a5,a5
    80003c72:	e0f43023          	sd	a5,-512(s0)
    80003c76:	03800713          	li	a4,56
    80003c7a:	86be                	mv	a3,a5
    80003c7c:	e1840613          	addi	a2,s0,-488
    80003c80:	4581                	li	a1,0
    80003c82:	8556                	mv	a0,s5
    80003c84:	d15fe0ef          	jal	ra,80002998 <readi>
    80003c88:	03800793          	li	a5,56
    80003c8c:	f6f51fe3          	bne	a0,a5,80003c0a <exec+0x274>
    if(ph.type != ELF_PROG_LOAD)
    80003c90:	e1842783          	lw	a5,-488(s0)
    80003c94:	4705                	li	a4,1
    80003c96:	fae79fe3          	bne	a5,a4,80003c54 <exec+0x2be>
    if(ph.memsz < ph.filesz)
    80003c9a:	e4043483          	ld	s1,-448(s0)
    80003c9e:	e3843783          	ld	a5,-456(s0)
    80003ca2:	f6f4efe3          	bltu	s1,a5,80003c20 <exec+0x28a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003ca6:	e2843783          	ld	a5,-472(s0)
    80003caa:	94be                	add	s1,s1,a5
    80003cac:	f6f4ede3          	bltu	s1,a5,80003c26 <exec+0x290>
    if(ph.vaddr % PGSIZE != 0)
    80003cb0:	de043703          	ld	a4,-544(s0)
    80003cb4:	8ff9                	and	a5,a5,a4
    80003cb6:	fbbd                	bnez	a5,80003c2c <exec+0x296>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003cb8:	e1c42503          	lw	a0,-484(s0)
    80003cbc:	cc1ff0ef          	jal	ra,8000397c <flags2perm>
    80003cc0:	86aa                	mv	a3,a0
    80003cc2:	8626                	mv	a2,s1
    80003cc4:	85ca                	mv	a1,s2
    80003cc6:	855a                	mv	a0,s6
    80003cc8:	b0ffc0ef          	jal	ra,800007d6 <uvmalloc>
    80003ccc:	dea43c23          	sd	a0,-520(s0)
    80003cd0:	d12d                	beqz	a0,80003c32 <exec+0x29c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003cd2:	e2843c03          	ld	s8,-472(s0)
    80003cd6:	e2042c83          	lw	s9,-480(s0)
    80003cda:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003cde:	f60b89e3          	beqz	s7,80003c50 <exec+0x2ba>
    80003ce2:	89de                	mv	s3,s7
    80003ce4:	4481                	li	s1,0
    80003ce6:	bb5d                	j	80003a9c <exec+0x106>

0000000080003ce8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003ce8:	7179                	addi	sp,sp,-48
    80003cea:	f406                	sd	ra,40(sp)
    80003cec:	f022                	sd	s0,32(sp)
    80003cee:	ec26                	sd	s1,24(sp)
    80003cf0:	e84a                	sd	s2,16(sp)
    80003cf2:	1800                	addi	s0,sp,48
    80003cf4:	892e                	mv	s2,a1
    80003cf6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003cf8:	fdc40593          	addi	a1,s0,-36
    80003cfc:	fedfd0ef          	jal	ra,80001ce8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003d00:	fdc42703          	lw	a4,-36(s0)
    80003d04:	47bd                	li	a5,15
    80003d06:	02e7e963          	bltu	a5,a4,80003d38 <argfd+0x50>
    80003d0a:	930fd0ef          	jal	ra,80000e3a <myproc>
    80003d0e:	fdc42703          	lw	a4,-36(s0)
    80003d12:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffde31a>
    80003d16:	078e                	slli	a5,a5,0x3
    80003d18:	953e                	add	a0,a0,a5
    80003d1a:	611c                	ld	a5,0(a0)
    80003d1c:	c385                	beqz	a5,80003d3c <argfd+0x54>
    return -1;
  if(pfd)
    80003d1e:	00090463          	beqz	s2,80003d26 <argfd+0x3e>
    *pfd = fd;
    80003d22:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003d26:	4501                	li	a0,0
  if(pf)
    80003d28:	c091                	beqz	s1,80003d2c <argfd+0x44>
    *pf = f;
    80003d2a:	e09c                	sd	a5,0(s1)
}
    80003d2c:	70a2                	ld	ra,40(sp)
    80003d2e:	7402                	ld	s0,32(sp)
    80003d30:	64e2                	ld	s1,24(sp)
    80003d32:	6942                	ld	s2,16(sp)
    80003d34:	6145                	addi	sp,sp,48
    80003d36:	8082                	ret
    return -1;
    80003d38:	557d                	li	a0,-1
    80003d3a:	bfcd                	j	80003d2c <argfd+0x44>
    80003d3c:	557d                	li	a0,-1
    80003d3e:	b7fd                	j	80003d2c <argfd+0x44>

0000000080003d40 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003d40:	1101                	addi	sp,sp,-32
    80003d42:	ec06                	sd	ra,24(sp)
    80003d44:	e822                	sd	s0,16(sp)
    80003d46:	e426                	sd	s1,8(sp)
    80003d48:	1000                	addi	s0,sp,32
    80003d4a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003d4c:	8eefd0ef          	jal	ra,80000e3a <myproc>
    80003d50:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003d52:	0d050793          	addi	a5,a0,208
    80003d56:	4501                	li	a0,0
    80003d58:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003d5a:	6398                	ld	a4,0(a5)
    80003d5c:	cb19                	beqz	a4,80003d72 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003d5e:	2505                	addiw	a0,a0,1
    80003d60:	07a1                	addi	a5,a5,8
    80003d62:	fed51ce3          	bne	a0,a3,80003d5a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003d66:	557d                	li	a0,-1
}
    80003d68:	60e2                	ld	ra,24(sp)
    80003d6a:	6442                	ld	s0,16(sp)
    80003d6c:	64a2                	ld	s1,8(sp)
    80003d6e:	6105                	addi	sp,sp,32
    80003d70:	8082                	ret
      p->ofile[fd] = f;
    80003d72:	01a50793          	addi	a5,a0,26
    80003d76:	078e                	slli	a5,a5,0x3
    80003d78:	963e                	add	a2,a2,a5
    80003d7a:	e204                	sd	s1,0(a2)
      return fd;
    80003d7c:	b7f5                	j	80003d68 <fdalloc+0x28>

0000000080003d7e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003d7e:	715d                	addi	sp,sp,-80
    80003d80:	e486                	sd	ra,72(sp)
    80003d82:	e0a2                	sd	s0,64(sp)
    80003d84:	fc26                	sd	s1,56(sp)
    80003d86:	f84a                	sd	s2,48(sp)
    80003d88:	f44e                	sd	s3,40(sp)
    80003d8a:	f052                	sd	s4,32(sp)
    80003d8c:	ec56                	sd	s5,24(sp)
    80003d8e:	e85a                	sd	s6,16(sp)
    80003d90:	0880                	addi	s0,sp,80
    80003d92:	8b2e                	mv	s6,a1
    80003d94:	89b2                	mv	s3,a2
    80003d96:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003d98:	fb040593          	addi	a1,s0,-80
    80003d9c:	87eff0ef          	jal	ra,80002e1a <nameiparent>
    80003da0:	84aa                	mv	s1,a0
    80003da2:	10050b63          	beqz	a0,80003eb8 <create+0x13a>
    return 0;

  ilock(dp);
    80003da6:	9a3fe0ef          	jal	ra,80002748 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003daa:	4601                	li	a2,0
    80003dac:	fb040593          	addi	a1,s0,-80
    80003db0:	8526                	mv	a0,s1
    80003db2:	de3fe0ef          	jal	ra,80002b94 <dirlookup>
    80003db6:	8aaa                	mv	s5,a0
    80003db8:	c521                	beqz	a0,80003e00 <create+0x82>
    iunlockput(dp);
    80003dba:	8526                	mv	a0,s1
    80003dbc:	b93fe0ef          	jal	ra,8000294e <iunlockput>
    ilock(ip);
    80003dc0:	8556                	mv	a0,s5
    80003dc2:	987fe0ef          	jal	ra,80002748 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003dc6:	000b059b          	sext.w	a1,s6
    80003dca:	4789                	li	a5,2
    80003dcc:	02f59563          	bne	a1,a5,80003df6 <create+0x78>
    80003dd0:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffde344>
    80003dd4:	37f9                	addiw	a5,a5,-2
    80003dd6:	17c2                	slli	a5,a5,0x30
    80003dd8:	93c1                	srli	a5,a5,0x30
    80003dda:	4705                	li	a4,1
    80003ddc:	00f76d63          	bltu	a4,a5,80003df6 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003de0:	8556                	mv	a0,s5
    80003de2:	60a6                	ld	ra,72(sp)
    80003de4:	6406                	ld	s0,64(sp)
    80003de6:	74e2                	ld	s1,56(sp)
    80003de8:	7942                	ld	s2,48(sp)
    80003dea:	79a2                	ld	s3,40(sp)
    80003dec:	7a02                	ld	s4,32(sp)
    80003dee:	6ae2                	ld	s5,24(sp)
    80003df0:	6b42                	ld	s6,16(sp)
    80003df2:	6161                	addi	sp,sp,80
    80003df4:	8082                	ret
    iunlockput(ip);
    80003df6:	8556                	mv	a0,s5
    80003df8:	b57fe0ef          	jal	ra,8000294e <iunlockput>
    return 0;
    80003dfc:	4a81                	li	s5,0
    80003dfe:	b7cd                	j	80003de0 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80003e00:	85da                	mv	a1,s6
    80003e02:	4088                	lw	a0,0(s1)
    80003e04:	fdafe0ef          	jal	ra,800025de <ialloc>
    80003e08:	8a2a                	mv	s4,a0
    80003e0a:	cd1d                	beqz	a0,80003e48 <create+0xca>
  ilock(ip);
    80003e0c:	93dfe0ef          	jal	ra,80002748 <ilock>
  ip->major = major;
    80003e10:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80003e14:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80003e18:	4905                	li	s2,1
    80003e1a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80003e1e:	8552                	mv	a0,s4
    80003e20:	875fe0ef          	jal	ra,80002694 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80003e24:	000b059b          	sext.w	a1,s6
    80003e28:	03258563          	beq	a1,s2,80003e52 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80003e2c:	004a2603          	lw	a2,4(s4)
    80003e30:	fb040593          	addi	a1,s0,-80
    80003e34:	8526                	mv	a0,s1
    80003e36:	f31fe0ef          	jal	ra,80002d66 <dirlink>
    80003e3a:	06054363          	bltz	a0,80003ea0 <create+0x122>
  iunlockput(dp);
    80003e3e:	8526                	mv	a0,s1
    80003e40:	b0ffe0ef          	jal	ra,8000294e <iunlockput>
  return ip;
    80003e44:	8ad2                	mv	s5,s4
    80003e46:	bf69                	j	80003de0 <create+0x62>
    iunlockput(dp);
    80003e48:	8526                	mv	a0,s1
    80003e4a:	b05fe0ef          	jal	ra,8000294e <iunlockput>
    return 0;
    80003e4e:	8ad2                	mv	s5,s4
    80003e50:	bf41                	j	80003de0 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80003e52:	004a2603          	lw	a2,4(s4)
    80003e56:	00004597          	auipc	a1,0x4
    80003e5a:	91258593          	addi	a1,a1,-1774 # 80007768 <syscalls+0x308>
    80003e5e:	8552                	mv	a0,s4
    80003e60:	f07fe0ef          	jal	ra,80002d66 <dirlink>
    80003e64:	02054e63          	bltz	a0,80003ea0 <create+0x122>
    80003e68:	40d0                	lw	a2,4(s1)
    80003e6a:	00004597          	auipc	a1,0x4
    80003e6e:	90658593          	addi	a1,a1,-1786 # 80007770 <syscalls+0x310>
    80003e72:	8552                	mv	a0,s4
    80003e74:	ef3fe0ef          	jal	ra,80002d66 <dirlink>
    80003e78:	02054463          	bltz	a0,80003ea0 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80003e7c:	004a2603          	lw	a2,4(s4)
    80003e80:	fb040593          	addi	a1,s0,-80
    80003e84:	8526                	mv	a0,s1
    80003e86:	ee1fe0ef          	jal	ra,80002d66 <dirlink>
    80003e8a:	00054b63          	bltz	a0,80003ea0 <create+0x122>
    dp->nlink++;  // for ".."
    80003e8e:	04a4d783          	lhu	a5,74(s1)
    80003e92:	2785                	addiw	a5,a5,1
    80003e94:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80003e98:	8526                	mv	a0,s1
    80003e9a:	ffafe0ef          	jal	ra,80002694 <iupdate>
    80003e9e:	b745                	j	80003e3e <create+0xc0>
  ip->nlink = 0;
    80003ea0:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80003ea4:	8552                	mv	a0,s4
    80003ea6:	feefe0ef          	jal	ra,80002694 <iupdate>
  iunlockput(ip);
    80003eaa:	8552                	mv	a0,s4
    80003eac:	aa3fe0ef          	jal	ra,8000294e <iunlockput>
  iunlockput(dp);
    80003eb0:	8526                	mv	a0,s1
    80003eb2:	a9dfe0ef          	jal	ra,8000294e <iunlockput>
  return 0;
    80003eb6:	b72d                	j	80003de0 <create+0x62>
    return 0;
    80003eb8:	8aaa                	mv	s5,a0
    80003eba:	b71d                	j	80003de0 <create+0x62>

0000000080003ebc <sys_dup>:
{
    80003ebc:	7179                	addi	sp,sp,-48
    80003ebe:	f406                	sd	ra,40(sp)
    80003ec0:	f022                	sd	s0,32(sp)
    80003ec2:	ec26                	sd	s1,24(sp)
    80003ec4:	e84a                	sd	s2,16(sp)
    80003ec6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80003ec8:	fd840613          	addi	a2,s0,-40
    80003ecc:	4581                	li	a1,0
    80003ece:	4501                	li	a0,0
    80003ed0:	e19ff0ef          	jal	ra,80003ce8 <argfd>
    return -1;
    80003ed4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80003ed6:	00054f63          	bltz	a0,80003ef4 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    80003eda:	fd843903          	ld	s2,-40(s0)
    80003ede:	854a                	mv	a0,s2
    80003ee0:	e61ff0ef          	jal	ra,80003d40 <fdalloc>
    80003ee4:	84aa                	mv	s1,a0
    return -1;
    80003ee6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80003ee8:	00054663          	bltz	a0,80003ef4 <sys_dup+0x38>
  filedup(f);
    80003eec:	854a                	mv	a0,s2
    80003eee:	cc0ff0ef          	jal	ra,800033ae <filedup>
  return fd;
    80003ef2:	87a6                	mv	a5,s1
}
    80003ef4:	853e                	mv	a0,a5
    80003ef6:	70a2                	ld	ra,40(sp)
    80003ef8:	7402                	ld	s0,32(sp)
    80003efa:	64e2                	ld	s1,24(sp)
    80003efc:	6942                	ld	s2,16(sp)
    80003efe:	6145                	addi	sp,sp,48
    80003f00:	8082                	ret

0000000080003f02 <sys_read>:
{
    80003f02:	7179                	addi	sp,sp,-48
    80003f04:	f406                	sd	ra,40(sp)
    80003f06:	f022                	sd	s0,32(sp)
    80003f08:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003f0a:	fd840593          	addi	a1,s0,-40
    80003f0e:	4505                	li	a0,1
    80003f10:	df5fd0ef          	jal	ra,80001d04 <argaddr>
  argint(2, &n);
    80003f14:	fe440593          	addi	a1,s0,-28
    80003f18:	4509                	li	a0,2
    80003f1a:	dcffd0ef          	jal	ra,80001ce8 <argint>
  if(argfd(0, 0, &f) < 0)
    80003f1e:	fe840613          	addi	a2,s0,-24
    80003f22:	4581                	li	a1,0
    80003f24:	4501                	li	a0,0
    80003f26:	dc3ff0ef          	jal	ra,80003ce8 <argfd>
    80003f2a:	87aa                	mv	a5,a0
    return -1;
    80003f2c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003f2e:	0007ca63          	bltz	a5,80003f42 <sys_read+0x40>
  return fileread(f, p, n);
    80003f32:	fe442603          	lw	a2,-28(s0)
    80003f36:	fd843583          	ld	a1,-40(s0)
    80003f3a:	fe843503          	ld	a0,-24(s0)
    80003f3e:	dbcff0ef          	jal	ra,800034fa <fileread>
}
    80003f42:	70a2                	ld	ra,40(sp)
    80003f44:	7402                	ld	s0,32(sp)
    80003f46:	6145                	addi	sp,sp,48
    80003f48:	8082                	ret

0000000080003f4a <sys_write>:
{
    80003f4a:	7179                	addi	sp,sp,-48
    80003f4c:	f406                	sd	ra,40(sp)
    80003f4e:	f022                	sd	s0,32(sp)
    80003f50:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003f52:	fd840593          	addi	a1,s0,-40
    80003f56:	4505                	li	a0,1
    80003f58:	dadfd0ef          	jal	ra,80001d04 <argaddr>
  argint(2, &n);
    80003f5c:	fe440593          	addi	a1,s0,-28
    80003f60:	4509                	li	a0,2
    80003f62:	d87fd0ef          	jal	ra,80001ce8 <argint>
  if(argfd(0, 0, &f) < 0)
    80003f66:	fe840613          	addi	a2,s0,-24
    80003f6a:	4581                	li	a1,0
    80003f6c:	4501                	li	a0,0
    80003f6e:	d7bff0ef          	jal	ra,80003ce8 <argfd>
    80003f72:	87aa                	mv	a5,a0
    return -1;
    80003f74:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003f76:	0007ca63          	bltz	a5,80003f8a <sys_write+0x40>
  return filewrite(f, p, n);
    80003f7a:	fe442603          	lw	a2,-28(s0)
    80003f7e:	fd843583          	ld	a1,-40(s0)
    80003f82:	fe843503          	ld	a0,-24(s0)
    80003f86:	e22ff0ef          	jal	ra,800035a8 <filewrite>
}
    80003f8a:	70a2                	ld	ra,40(sp)
    80003f8c:	7402                	ld	s0,32(sp)
    80003f8e:	6145                	addi	sp,sp,48
    80003f90:	8082                	ret

0000000080003f92 <sys_close>:
{
    80003f92:	1101                	addi	sp,sp,-32
    80003f94:	ec06                	sd	ra,24(sp)
    80003f96:	e822                	sd	s0,16(sp)
    80003f98:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80003f9a:	fe040613          	addi	a2,s0,-32
    80003f9e:	fec40593          	addi	a1,s0,-20
    80003fa2:	4501                	li	a0,0
    80003fa4:	d45ff0ef          	jal	ra,80003ce8 <argfd>
    return -1;
    80003fa8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80003faa:	02054063          	bltz	a0,80003fca <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80003fae:	e8dfc0ef          	jal	ra,80000e3a <myproc>
    80003fb2:	fec42783          	lw	a5,-20(s0)
    80003fb6:	07e9                	addi	a5,a5,26
    80003fb8:	078e                	slli	a5,a5,0x3
    80003fba:	953e                	add	a0,a0,a5
    80003fbc:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80003fc0:	fe043503          	ld	a0,-32(s0)
    80003fc4:	c30ff0ef          	jal	ra,800033f4 <fileclose>
  return 0;
    80003fc8:	4781                	li	a5,0
}
    80003fca:	853e                	mv	a0,a5
    80003fcc:	60e2                	ld	ra,24(sp)
    80003fce:	6442                	ld	s0,16(sp)
    80003fd0:	6105                	addi	sp,sp,32
    80003fd2:	8082                	ret

0000000080003fd4 <sys_fstat>:
{
    80003fd4:	1101                	addi	sp,sp,-32
    80003fd6:	ec06                	sd	ra,24(sp)
    80003fd8:	e822                	sd	s0,16(sp)
    80003fda:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80003fdc:	fe040593          	addi	a1,s0,-32
    80003fe0:	4505                	li	a0,1
    80003fe2:	d23fd0ef          	jal	ra,80001d04 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80003fe6:	fe840613          	addi	a2,s0,-24
    80003fea:	4581                	li	a1,0
    80003fec:	4501                	li	a0,0
    80003fee:	cfbff0ef          	jal	ra,80003ce8 <argfd>
    80003ff2:	87aa                	mv	a5,a0
    return -1;
    80003ff4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003ff6:	0007c863          	bltz	a5,80004006 <sys_fstat+0x32>
  return filestat(f, st);
    80003ffa:	fe043583          	ld	a1,-32(s0)
    80003ffe:	fe843503          	ld	a0,-24(s0)
    80004002:	c9aff0ef          	jal	ra,8000349c <filestat>
}
    80004006:	60e2                	ld	ra,24(sp)
    80004008:	6442                	ld	s0,16(sp)
    8000400a:	6105                	addi	sp,sp,32
    8000400c:	8082                	ret

000000008000400e <sys_link>:
{
    8000400e:	7169                	addi	sp,sp,-304
    80004010:	f606                	sd	ra,296(sp)
    80004012:	f222                	sd	s0,288(sp)
    80004014:	ee26                	sd	s1,280(sp)
    80004016:	ea4a                	sd	s2,272(sp)
    80004018:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000401a:	08000613          	li	a2,128
    8000401e:	ed040593          	addi	a1,s0,-304
    80004022:	4501                	li	a0,0
    80004024:	cfdfd0ef          	jal	ra,80001d20 <argstr>
    return -1;
    80004028:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000402a:	0c054663          	bltz	a0,800040f6 <sys_link+0xe8>
    8000402e:	08000613          	li	a2,128
    80004032:	f5040593          	addi	a1,s0,-176
    80004036:	4505                	li	a0,1
    80004038:	ce9fd0ef          	jal	ra,80001d20 <argstr>
    return -1;
    8000403c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000403e:	0a054c63          	bltz	a0,800040f6 <sys_link+0xe8>
  begin_op();
    80004042:	f9bfe0ef          	jal	ra,80002fdc <begin_op>
  if((ip = namei(old)) == 0){
    80004046:	ed040513          	addi	a0,s0,-304
    8000404a:	db7fe0ef          	jal	ra,80002e00 <namei>
    8000404e:	84aa                	mv	s1,a0
    80004050:	c525                	beqz	a0,800040b8 <sys_link+0xaa>
  ilock(ip);
    80004052:	ef6fe0ef          	jal	ra,80002748 <ilock>
  if(ip->type == T_DIR){
    80004056:	04449703          	lh	a4,68(s1)
    8000405a:	4785                	li	a5,1
    8000405c:	06f70263          	beq	a4,a5,800040c0 <sys_link+0xb2>
  ip->nlink++;
    80004060:	04a4d783          	lhu	a5,74(s1)
    80004064:	2785                	addiw	a5,a5,1
    80004066:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000406a:	8526                	mv	a0,s1
    8000406c:	e28fe0ef          	jal	ra,80002694 <iupdate>
  iunlock(ip);
    80004070:	8526                	mv	a0,s1
    80004072:	f80fe0ef          	jal	ra,800027f2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004076:	fd040593          	addi	a1,s0,-48
    8000407a:	f5040513          	addi	a0,s0,-176
    8000407e:	d9dfe0ef          	jal	ra,80002e1a <nameiparent>
    80004082:	892a                	mv	s2,a0
    80004084:	c921                	beqz	a0,800040d4 <sys_link+0xc6>
  ilock(dp);
    80004086:	ec2fe0ef          	jal	ra,80002748 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000408a:	00092703          	lw	a4,0(s2)
    8000408e:	409c                	lw	a5,0(s1)
    80004090:	02f71f63          	bne	a4,a5,800040ce <sys_link+0xc0>
    80004094:	40d0                	lw	a2,4(s1)
    80004096:	fd040593          	addi	a1,s0,-48
    8000409a:	854a                	mv	a0,s2
    8000409c:	ccbfe0ef          	jal	ra,80002d66 <dirlink>
    800040a0:	02054763          	bltz	a0,800040ce <sys_link+0xc0>
  iunlockput(dp);
    800040a4:	854a                	mv	a0,s2
    800040a6:	8a9fe0ef          	jal	ra,8000294e <iunlockput>
  iput(ip);
    800040aa:	8526                	mv	a0,s1
    800040ac:	81bfe0ef          	jal	ra,800028c6 <iput>
  end_op();
    800040b0:	f9bfe0ef          	jal	ra,8000304a <end_op>
  return 0;
    800040b4:	4781                	li	a5,0
    800040b6:	a081                	j	800040f6 <sys_link+0xe8>
    end_op();
    800040b8:	f93fe0ef          	jal	ra,8000304a <end_op>
    return -1;
    800040bc:	57fd                	li	a5,-1
    800040be:	a825                	j	800040f6 <sys_link+0xe8>
    iunlockput(ip);
    800040c0:	8526                	mv	a0,s1
    800040c2:	88dfe0ef          	jal	ra,8000294e <iunlockput>
    end_op();
    800040c6:	f85fe0ef          	jal	ra,8000304a <end_op>
    return -1;
    800040ca:	57fd                	li	a5,-1
    800040cc:	a02d                	j	800040f6 <sys_link+0xe8>
    iunlockput(dp);
    800040ce:	854a                	mv	a0,s2
    800040d0:	87ffe0ef          	jal	ra,8000294e <iunlockput>
  ilock(ip);
    800040d4:	8526                	mv	a0,s1
    800040d6:	e72fe0ef          	jal	ra,80002748 <ilock>
  ip->nlink--;
    800040da:	04a4d783          	lhu	a5,74(s1)
    800040de:	37fd                	addiw	a5,a5,-1
    800040e0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800040e4:	8526                	mv	a0,s1
    800040e6:	daefe0ef          	jal	ra,80002694 <iupdate>
  iunlockput(ip);
    800040ea:	8526                	mv	a0,s1
    800040ec:	863fe0ef          	jal	ra,8000294e <iunlockput>
  end_op();
    800040f0:	f5bfe0ef          	jal	ra,8000304a <end_op>
  return -1;
    800040f4:	57fd                	li	a5,-1
}
    800040f6:	853e                	mv	a0,a5
    800040f8:	70b2                	ld	ra,296(sp)
    800040fa:	7412                	ld	s0,288(sp)
    800040fc:	64f2                	ld	s1,280(sp)
    800040fe:	6952                	ld	s2,272(sp)
    80004100:	6155                	addi	sp,sp,304
    80004102:	8082                	ret

0000000080004104 <sys_unlink>:
{
    80004104:	7151                	addi	sp,sp,-240
    80004106:	f586                	sd	ra,232(sp)
    80004108:	f1a2                	sd	s0,224(sp)
    8000410a:	eda6                	sd	s1,216(sp)
    8000410c:	e9ca                	sd	s2,208(sp)
    8000410e:	e5ce                	sd	s3,200(sp)
    80004110:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004112:	08000613          	li	a2,128
    80004116:	f3040593          	addi	a1,s0,-208
    8000411a:	4501                	li	a0,0
    8000411c:	c05fd0ef          	jal	ra,80001d20 <argstr>
    80004120:	12054b63          	bltz	a0,80004256 <sys_unlink+0x152>
  begin_op();
    80004124:	eb9fe0ef          	jal	ra,80002fdc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004128:	fb040593          	addi	a1,s0,-80
    8000412c:	f3040513          	addi	a0,s0,-208
    80004130:	cebfe0ef          	jal	ra,80002e1a <nameiparent>
    80004134:	84aa                	mv	s1,a0
    80004136:	c54d                	beqz	a0,800041e0 <sys_unlink+0xdc>
  ilock(dp);
    80004138:	e10fe0ef          	jal	ra,80002748 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000413c:	00003597          	auipc	a1,0x3
    80004140:	62c58593          	addi	a1,a1,1580 # 80007768 <syscalls+0x308>
    80004144:	fb040513          	addi	a0,s0,-80
    80004148:	a37fe0ef          	jal	ra,80002b7e <namecmp>
    8000414c:	10050a63          	beqz	a0,80004260 <sys_unlink+0x15c>
    80004150:	00003597          	auipc	a1,0x3
    80004154:	62058593          	addi	a1,a1,1568 # 80007770 <syscalls+0x310>
    80004158:	fb040513          	addi	a0,s0,-80
    8000415c:	a23fe0ef          	jal	ra,80002b7e <namecmp>
    80004160:	10050063          	beqz	a0,80004260 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004164:	f2c40613          	addi	a2,s0,-212
    80004168:	fb040593          	addi	a1,s0,-80
    8000416c:	8526                	mv	a0,s1
    8000416e:	a27fe0ef          	jal	ra,80002b94 <dirlookup>
    80004172:	892a                	mv	s2,a0
    80004174:	0e050663          	beqz	a0,80004260 <sys_unlink+0x15c>
  ilock(ip);
    80004178:	dd0fe0ef          	jal	ra,80002748 <ilock>
  if(ip->nlink < 1)
    8000417c:	04a91783          	lh	a5,74(s2)
    80004180:	06f05463          	blez	a5,800041e8 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004184:	04491703          	lh	a4,68(s2)
    80004188:	4785                	li	a5,1
    8000418a:	06f70563          	beq	a4,a5,800041f4 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    8000418e:	4641                	li	a2,16
    80004190:	4581                	li	a1,0
    80004192:	fc040513          	addi	a0,s0,-64
    80004196:	fb9fb0ef          	jal	ra,8000014e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000419a:	4741                	li	a4,16
    8000419c:	f2c42683          	lw	a3,-212(s0)
    800041a0:	fc040613          	addi	a2,s0,-64
    800041a4:	4581                	li	a1,0
    800041a6:	8526                	mv	a0,s1
    800041a8:	8d5fe0ef          	jal	ra,80002a7c <writei>
    800041ac:	47c1                	li	a5,16
    800041ae:	08f51563          	bne	a0,a5,80004238 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    800041b2:	04491703          	lh	a4,68(s2)
    800041b6:	4785                	li	a5,1
    800041b8:	08f70663          	beq	a4,a5,80004244 <sys_unlink+0x140>
  iunlockput(dp);
    800041bc:	8526                	mv	a0,s1
    800041be:	f90fe0ef          	jal	ra,8000294e <iunlockput>
  ip->nlink--;
    800041c2:	04a95783          	lhu	a5,74(s2)
    800041c6:	37fd                	addiw	a5,a5,-1
    800041c8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800041cc:	854a                	mv	a0,s2
    800041ce:	cc6fe0ef          	jal	ra,80002694 <iupdate>
  iunlockput(ip);
    800041d2:	854a                	mv	a0,s2
    800041d4:	f7afe0ef          	jal	ra,8000294e <iunlockput>
  end_op();
    800041d8:	e73fe0ef          	jal	ra,8000304a <end_op>
  return 0;
    800041dc:	4501                	li	a0,0
    800041de:	a079                	j	8000426c <sys_unlink+0x168>
    end_op();
    800041e0:	e6bfe0ef          	jal	ra,8000304a <end_op>
    return -1;
    800041e4:	557d                	li	a0,-1
    800041e6:	a059                	j	8000426c <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800041e8:	00003517          	auipc	a0,0x3
    800041ec:	59050513          	addi	a0,a0,1424 # 80007778 <syscalls+0x318>
    800041f0:	1d2010ef          	jal	ra,800053c2 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800041f4:	04c92703          	lw	a4,76(s2)
    800041f8:	02000793          	li	a5,32
    800041fc:	f8e7f9e3          	bgeu	a5,a4,8000418e <sys_unlink+0x8a>
    80004200:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004204:	4741                	li	a4,16
    80004206:	86ce                	mv	a3,s3
    80004208:	f1840613          	addi	a2,s0,-232
    8000420c:	4581                	li	a1,0
    8000420e:	854a                	mv	a0,s2
    80004210:	f88fe0ef          	jal	ra,80002998 <readi>
    80004214:	47c1                	li	a5,16
    80004216:	00f51b63          	bne	a0,a5,8000422c <sys_unlink+0x128>
    if(de.inum != 0)
    8000421a:	f1845783          	lhu	a5,-232(s0)
    8000421e:	ef95                	bnez	a5,8000425a <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004220:	29c1                	addiw	s3,s3,16
    80004222:	04c92783          	lw	a5,76(s2)
    80004226:	fcf9efe3          	bltu	s3,a5,80004204 <sys_unlink+0x100>
    8000422a:	b795                	j	8000418e <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000422c:	00003517          	auipc	a0,0x3
    80004230:	56450513          	addi	a0,a0,1380 # 80007790 <syscalls+0x330>
    80004234:	18e010ef          	jal	ra,800053c2 <panic>
    panic("unlink: writei");
    80004238:	00003517          	auipc	a0,0x3
    8000423c:	57050513          	addi	a0,a0,1392 # 800077a8 <syscalls+0x348>
    80004240:	182010ef          	jal	ra,800053c2 <panic>
    dp->nlink--;
    80004244:	04a4d783          	lhu	a5,74(s1)
    80004248:	37fd                	addiw	a5,a5,-1
    8000424a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000424e:	8526                	mv	a0,s1
    80004250:	c44fe0ef          	jal	ra,80002694 <iupdate>
    80004254:	b7a5                	j	800041bc <sys_unlink+0xb8>
    return -1;
    80004256:	557d                	li	a0,-1
    80004258:	a811                	j	8000426c <sys_unlink+0x168>
    iunlockput(ip);
    8000425a:	854a                	mv	a0,s2
    8000425c:	ef2fe0ef          	jal	ra,8000294e <iunlockput>
  iunlockput(dp);
    80004260:	8526                	mv	a0,s1
    80004262:	eecfe0ef          	jal	ra,8000294e <iunlockput>
  end_op();
    80004266:	de5fe0ef          	jal	ra,8000304a <end_op>
  return -1;
    8000426a:	557d                	li	a0,-1
}
    8000426c:	70ae                	ld	ra,232(sp)
    8000426e:	740e                	ld	s0,224(sp)
    80004270:	64ee                	ld	s1,216(sp)
    80004272:	694e                	ld	s2,208(sp)
    80004274:	69ae                	ld	s3,200(sp)
    80004276:	616d                	addi	sp,sp,240
    80004278:	8082                	ret

000000008000427a <sys_open>:

uint64
sys_open(void)
{
    8000427a:	7131                	addi	sp,sp,-192
    8000427c:	fd06                	sd	ra,184(sp)
    8000427e:	f922                	sd	s0,176(sp)
    80004280:	f526                	sd	s1,168(sp)
    80004282:	f14a                	sd	s2,160(sp)
    80004284:	ed4e                	sd	s3,152(sp)
    80004286:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004288:	f4c40593          	addi	a1,s0,-180
    8000428c:	4505                	li	a0,1
    8000428e:	a5bfd0ef          	jal	ra,80001ce8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004292:	08000613          	li	a2,128
    80004296:	f5040593          	addi	a1,s0,-176
    8000429a:	4501                	li	a0,0
    8000429c:	a85fd0ef          	jal	ra,80001d20 <argstr>
    800042a0:	87aa                	mv	a5,a0
    return -1;
    800042a2:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800042a4:	0807cd63          	bltz	a5,8000433e <sys_open+0xc4>

  begin_op();
    800042a8:	d35fe0ef          	jal	ra,80002fdc <begin_op>

  if(omode & O_CREATE){
    800042ac:	f4c42783          	lw	a5,-180(s0)
    800042b0:	2007f793          	andi	a5,a5,512
    800042b4:	c3c5                	beqz	a5,80004354 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800042b6:	4681                	li	a3,0
    800042b8:	4601                	li	a2,0
    800042ba:	4589                	li	a1,2
    800042bc:	f5040513          	addi	a0,s0,-176
    800042c0:	abfff0ef          	jal	ra,80003d7e <create>
    800042c4:	84aa                	mv	s1,a0
    if(ip == 0){
    800042c6:	c159                	beqz	a0,8000434c <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800042c8:	04449703          	lh	a4,68(s1)
    800042cc:	478d                	li	a5,3
    800042ce:	00f71763          	bne	a4,a5,800042dc <sys_open+0x62>
    800042d2:	0464d703          	lhu	a4,70(s1)
    800042d6:	47a5                	li	a5,9
    800042d8:	0ae7e963          	bltu	a5,a4,8000438a <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800042dc:	874ff0ef          	jal	ra,80003350 <filealloc>
    800042e0:	89aa                	mv	s3,a0
    800042e2:	0c050963          	beqz	a0,800043b4 <sys_open+0x13a>
    800042e6:	a5bff0ef          	jal	ra,80003d40 <fdalloc>
    800042ea:	892a                	mv	s2,a0
    800042ec:	0c054163          	bltz	a0,800043ae <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800042f0:	04449703          	lh	a4,68(s1)
    800042f4:	478d                	li	a5,3
    800042f6:	0af70163          	beq	a4,a5,80004398 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800042fa:	4789                	li	a5,2
    800042fc:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004300:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004304:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004308:	f4c42783          	lw	a5,-180(s0)
    8000430c:	0017c713          	xori	a4,a5,1
    80004310:	8b05                	andi	a4,a4,1
    80004312:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004316:	0037f713          	andi	a4,a5,3
    8000431a:	00e03733          	snez	a4,a4
    8000431e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004322:	4007f793          	andi	a5,a5,1024
    80004326:	c791                	beqz	a5,80004332 <sys_open+0xb8>
    80004328:	04449703          	lh	a4,68(s1)
    8000432c:	4789                	li	a5,2
    8000432e:	06f70c63          	beq	a4,a5,800043a6 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80004332:	8526                	mv	a0,s1
    80004334:	cbefe0ef          	jal	ra,800027f2 <iunlock>
  end_op();
    80004338:	d13fe0ef          	jal	ra,8000304a <end_op>

  return fd;
    8000433c:	854a                	mv	a0,s2
}
    8000433e:	70ea                	ld	ra,184(sp)
    80004340:	744a                	ld	s0,176(sp)
    80004342:	74aa                	ld	s1,168(sp)
    80004344:	790a                	ld	s2,160(sp)
    80004346:	69ea                	ld	s3,152(sp)
    80004348:	6129                	addi	sp,sp,192
    8000434a:	8082                	ret
      end_op();
    8000434c:	cfffe0ef          	jal	ra,8000304a <end_op>
      return -1;
    80004350:	557d                	li	a0,-1
    80004352:	b7f5                	j	8000433e <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80004354:	f5040513          	addi	a0,s0,-176
    80004358:	aa9fe0ef          	jal	ra,80002e00 <namei>
    8000435c:	84aa                	mv	s1,a0
    8000435e:	c115                	beqz	a0,80004382 <sys_open+0x108>
    ilock(ip);
    80004360:	be8fe0ef          	jal	ra,80002748 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004364:	04449703          	lh	a4,68(s1)
    80004368:	4785                	li	a5,1
    8000436a:	f4f71fe3          	bne	a4,a5,800042c8 <sys_open+0x4e>
    8000436e:	f4c42783          	lw	a5,-180(s0)
    80004372:	d7ad                	beqz	a5,800042dc <sys_open+0x62>
      iunlockput(ip);
    80004374:	8526                	mv	a0,s1
    80004376:	dd8fe0ef          	jal	ra,8000294e <iunlockput>
      end_op();
    8000437a:	cd1fe0ef          	jal	ra,8000304a <end_op>
      return -1;
    8000437e:	557d                	li	a0,-1
    80004380:	bf7d                	j	8000433e <sys_open+0xc4>
      end_op();
    80004382:	cc9fe0ef          	jal	ra,8000304a <end_op>
      return -1;
    80004386:	557d                	li	a0,-1
    80004388:	bf5d                	j	8000433e <sys_open+0xc4>
    iunlockput(ip);
    8000438a:	8526                	mv	a0,s1
    8000438c:	dc2fe0ef          	jal	ra,8000294e <iunlockput>
    end_op();
    80004390:	cbbfe0ef          	jal	ra,8000304a <end_op>
    return -1;
    80004394:	557d                	li	a0,-1
    80004396:	b765                	j	8000433e <sys_open+0xc4>
    f->type = FD_DEVICE;
    80004398:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000439c:	04649783          	lh	a5,70(s1)
    800043a0:	02f99223          	sh	a5,36(s3)
    800043a4:	b785                	j	80004304 <sys_open+0x8a>
    itrunc(ip);
    800043a6:	8526                	mv	a0,s1
    800043a8:	c8afe0ef          	jal	ra,80002832 <itrunc>
    800043ac:	b759                	j	80004332 <sys_open+0xb8>
      fileclose(f);
    800043ae:	854e                	mv	a0,s3
    800043b0:	844ff0ef          	jal	ra,800033f4 <fileclose>
    iunlockput(ip);
    800043b4:	8526                	mv	a0,s1
    800043b6:	d98fe0ef          	jal	ra,8000294e <iunlockput>
    end_op();
    800043ba:	c91fe0ef          	jal	ra,8000304a <end_op>
    return -1;
    800043be:	557d                	li	a0,-1
    800043c0:	bfbd                	j	8000433e <sys_open+0xc4>

00000000800043c2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800043c2:	7175                	addi	sp,sp,-144
    800043c4:	e506                	sd	ra,136(sp)
    800043c6:	e122                	sd	s0,128(sp)
    800043c8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800043ca:	c13fe0ef          	jal	ra,80002fdc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800043ce:	08000613          	li	a2,128
    800043d2:	f7040593          	addi	a1,s0,-144
    800043d6:	4501                	li	a0,0
    800043d8:	949fd0ef          	jal	ra,80001d20 <argstr>
    800043dc:	02054363          	bltz	a0,80004402 <sys_mkdir+0x40>
    800043e0:	4681                	li	a3,0
    800043e2:	4601                	li	a2,0
    800043e4:	4585                	li	a1,1
    800043e6:	f7040513          	addi	a0,s0,-144
    800043ea:	995ff0ef          	jal	ra,80003d7e <create>
    800043ee:	c911                	beqz	a0,80004402 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800043f0:	d5efe0ef          	jal	ra,8000294e <iunlockput>
  end_op();
    800043f4:	c57fe0ef          	jal	ra,8000304a <end_op>
  return 0;
    800043f8:	4501                	li	a0,0
}
    800043fa:	60aa                	ld	ra,136(sp)
    800043fc:	640a                	ld	s0,128(sp)
    800043fe:	6149                	addi	sp,sp,144
    80004400:	8082                	ret
    end_op();
    80004402:	c49fe0ef          	jal	ra,8000304a <end_op>
    return -1;
    80004406:	557d                	li	a0,-1
    80004408:	bfcd                	j	800043fa <sys_mkdir+0x38>

000000008000440a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000440a:	7135                	addi	sp,sp,-160
    8000440c:	ed06                	sd	ra,152(sp)
    8000440e:	e922                	sd	s0,144(sp)
    80004410:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004412:	bcbfe0ef          	jal	ra,80002fdc <begin_op>
  argint(1, &major);
    80004416:	f6c40593          	addi	a1,s0,-148
    8000441a:	4505                	li	a0,1
    8000441c:	8cdfd0ef          	jal	ra,80001ce8 <argint>
  argint(2, &minor);
    80004420:	f6840593          	addi	a1,s0,-152
    80004424:	4509                	li	a0,2
    80004426:	8c3fd0ef          	jal	ra,80001ce8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000442a:	08000613          	li	a2,128
    8000442e:	f7040593          	addi	a1,s0,-144
    80004432:	4501                	li	a0,0
    80004434:	8edfd0ef          	jal	ra,80001d20 <argstr>
    80004438:	02054563          	bltz	a0,80004462 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000443c:	f6841683          	lh	a3,-152(s0)
    80004440:	f6c41603          	lh	a2,-148(s0)
    80004444:	458d                	li	a1,3
    80004446:	f7040513          	addi	a0,s0,-144
    8000444a:	935ff0ef          	jal	ra,80003d7e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000444e:	c911                	beqz	a0,80004462 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004450:	cfefe0ef          	jal	ra,8000294e <iunlockput>
  end_op();
    80004454:	bf7fe0ef          	jal	ra,8000304a <end_op>
  return 0;
    80004458:	4501                	li	a0,0
}
    8000445a:	60ea                	ld	ra,152(sp)
    8000445c:	644a                	ld	s0,144(sp)
    8000445e:	610d                	addi	sp,sp,160
    80004460:	8082                	ret
    end_op();
    80004462:	be9fe0ef          	jal	ra,8000304a <end_op>
    return -1;
    80004466:	557d                	li	a0,-1
    80004468:	bfcd                	j	8000445a <sys_mknod+0x50>

000000008000446a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000446a:	7135                	addi	sp,sp,-160
    8000446c:	ed06                	sd	ra,152(sp)
    8000446e:	e922                	sd	s0,144(sp)
    80004470:	e526                	sd	s1,136(sp)
    80004472:	e14a                	sd	s2,128(sp)
    80004474:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004476:	9c5fc0ef          	jal	ra,80000e3a <myproc>
    8000447a:	892a                	mv	s2,a0

  begin_op();
    8000447c:	b61fe0ef          	jal	ra,80002fdc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004480:	08000613          	li	a2,128
    80004484:	f6040593          	addi	a1,s0,-160
    80004488:	4501                	li	a0,0
    8000448a:	897fd0ef          	jal	ra,80001d20 <argstr>
    8000448e:	04054163          	bltz	a0,800044d0 <sys_chdir+0x66>
    80004492:	f6040513          	addi	a0,s0,-160
    80004496:	96bfe0ef          	jal	ra,80002e00 <namei>
    8000449a:	84aa                	mv	s1,a0
    8000449c:	c915                	beqz	a0,800044d0 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000449e:	aaafe0ef          	jal	ra,80002748 <ilock>
  if(ip->type != T_DIR){
    800044a2:	04449703          	lh	a4,68(s1)
    800044a6:	4785                	li	a5,1
    800044a8:	02f71863          	bne	a4,a5,800044d8 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800044ac:	8526                	mv	a0,s1
    800044ae:	b44fe0ef          	jal	ra,800027f2 <iunlock>
  iput(p->cwd);
    800044b2:	15093503          	ld	a0,336(s2)
    800044b6:	c10fe0ef          	jal	ra,800028c6 <iput>
  end_op();
    800044ba:	b91fe0ef          	jal	ra,8000304a <end_op>
  p->cwd = ip;
    800044be:	14993823          	sd	s1,336(s2)
  return 0;
    800044c2:	4501                	li	a0,0
}
    800044c4:	60ea                	ld	ra,152(sp)
    800044c6:	644a                	ld	s0,144(sp)
    800044c8:	64aa                	ld	s1,136(sp)
    800044ca:	690a                	ld	s2,128(sp)
    800044cc:	610d                	addi	sp,sp,160
    800044ce:	8082                	ret
    end_op();
    800044d0:	b7bfe0ef          	jal	ra,8000304a <end_op>
    return -1;
    800044d4:	557d                	li	a0,-1
    800044d6:	b7fd                	j	800044c4 <sys_chdir+0x5a>
    iunlockput(ip);
    800044d8:	8526                	mv	a0,s1
    800044da:	c74fe0ef          	jal	ra,8000294e <iunlockput>
    end_op();
    800044de:	b6dfe0ef          	jal	ra,8000304a <end_op>
    return -1;
    800044e2:	557d                	li	a0,-1
    800044e4:	b7c5                	j	800044c4 <sys_chdir+0x5a>

00000000800044e6 <sys_exec>:

uint64
sys_exec(void)
{
    800044e6:	7145                	addi	sp,sp,-464
    800044e8:	e786                	sd	ra,456(sp)
    800044ea:	e3a2                	sd	s0,448(sp)
    800044ec:	ff26                	sd	s1,440(sp)
    800044ee:	fb4a                	sd	s2,432(sp)
    800044f0:	f74e                	sd	s3,424(sp)
    800044f2:	f352                	sd	s4,416(sp)
    800044f4:	ef56                	sd	s5,408(sp)
    800044f6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800044f8:	e3840593          	addi	a1,s0,-456
    800044fc:	4505                	li	a0,1
    800044fe:	807fd0ef          	jal	ra,80001d04 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004502:	08000613          	li	a2,128
    80004506:	f4040593          	addi	a1,s0,-192
    8000450a:	4501                	li	a0,0
    8000450c:	815fd0ef          	jal	ra,80001d20 <argstr>
    80004510:	87aa                	mv	a5,a0
    return -1;
    80004512:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004514:	0a07c563          	bltz	a5,800045be <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    80004518:	10000613          	li	a2,256
    8000451c:	4581                	li	a1,0
    8000451e:	e4040513          	addi	a0,s0,-448
    80004522:	c2dfb0ef          	jal	ra,8000014e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004526:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000452a:	89a6                	mv	s3,s1
    8000452c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000452e:	02000a13          	li	s4,32
    80004532:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004536:	00391513          	slli	a0,s2,0x3
    8000453a:	e3040593          	addi	a1,s0,-464
    8000453e:	e3843783          	ld	a5,-456(s0)
    80004542:	953e                	add	a0,a0,a5
    80004544:	f1afd0ef          	jal	ra,80001c5e <fetchaddr>
    80004548:	02054663          	bltz	a0,80004574 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    8000454c:	e3043783          	ld	a5,-464(s0)
    80004550:	cf8d                	beqz	a5,8000458a <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004552:	badfb0ef          	jal	ra,800000fe <kalloc>
    80004556:	85aa                	mv	a1,a0
    80004558:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000455c:	cd01                	beqz	a0,80004574 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000455e:	6605                	lui	a2,0x1
    80004560:	e3043503          	ld	a0,-464(s0)
    80004564:	f44fd0ef          	jal	ra,80001ca8 <fetchstr>
    80004568:	00054663          	bltz	a0,80004574 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    8000456c:	0905                	addi	s2,s2,1
    8000456e:	09a1                	addi	s3,s3,8
    80004570:	fd4911e3          	bne	s2,s4,80004532 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004574:	f4040913          	addi	s2,s0,-192
    80004578:	6088                	ld	a0,0(s1)
    8000457a:	c129                	beqz	a0,800045bc <sys_exec+0xd6>
    kfree(argv[i]);
    8000457c:	aa1fb0ef          	jal	ra,8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004580:	04a1                	addi	s1,s1,8
    80004582:	ff249be3          	bne	s1,s2,80004578 <sys_exec+0x92>
  return -1;
    80004586:	557d                	li	a0,-1
    80004588:	a81d                	j	800045be <sys_exec+0xd8>
      argv[i] = 0;
    8000458a:	0a8e                	slli	s5,s5,0x3
    8000458c:	fc0a8793          	addi	a5,s5,-64
    80004590:	00878ab3          	add	s5,a5,s0
    80004594:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80004598:	e4040593          	addi	a1,s0,-448
    8000459c:	f4040513          	addi	a0,s0,-192
    800045a0:	bf6ff0ef          	jal	ra,80003996 <exec>
    800045a4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800045a6:	f4040993          	addi	s3,s0,-192
    800045aa:	6088                	ld	a0,0(s1)
    800045ac:	c511                	beqz	a0,800045b8 <sys_exec+0xd2>
    kfree(argv[i]);
    800045ae:	a6ffb0ef          	jal	ra,8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800045b2:	04a1                	addi	s1,s1,8
    800045b4:	ff349be3          	bne	s1,s3,800045aa <sys_exec+0xc4>
  return ret;
    800045b8:	854a                	mv	a0,s2
    800045ba:	a011                	j	800045be <sys_exec+0xd8>
  return -1;
    800045bc:	557d                	li	a0,-1
}
    800045be:	60be                	ld	ra,456(sp)
    800045c0:	641e                	ld	s0,448(sp)
    800045c2:	74fa                	ld	s1,440(sp)
    800045c4:	795a                	ld	s2,432(sp)
    800045c6:	79ba                	ld	s3,424(sp)
    800045c8:	7a1a                	ld	s4,416(sp)
    800045ca:	6afa                	ld	s5,408(sp)
    800045cc:	6179                	addi	sp,sp,464
    800045ce:	8082                	ret

00000000800045d0 <sys_pipe>:

uint64
sys_pipe(void)
{
    800045d0:	7139                	addi	sp,sp,-64
    800045d2:	fc06                	sd	ra,56(sp)
    800045d4:	f822                	sd	s0,48(sp)
    800045d6:	f426                	sd	s1,40(sp)
    800045d8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800045da:	861fc0ef          	jal	ra,80000e3a <myproc>
    800045de:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800045e0:	fd840593          	addi	a1,s0,-40
    800045e4:	4501                	li	a0,0
    800045e6:	f1efd0ef          	jal	ra,80001d04 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800045ea:	fc840593          	addi	a1,s0,-56
    800045ee:	fd040513          	addi	a0,s0,-48
    800045f2:	8ceff0ef          	jal	ra,800036c0 <pipealloc>
    return -1;
    800045f6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800045f8:	0a054463          	bltz	a0,800046a0 <sys_pipe+0xd0>
  fd0 = -1;
    800045fc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004600:	fd043503          	ld	a0,-48(s0)
    80004604:	f3cff0ef          	jal	ra,80003d40 <fdalloc>
    80004608:	fca42223          	sw	a0,-60(s0)
    8000460c:	08054163          	bltz	a0,8000468e <sys_pipe+0xbe>
    80004610:	fc843503          	ld	a0,-56(s0)
    80004614:	f2cff0ef          	jal	ra,80003d40 <fdalloc>
    80004618:	fca42023          	sw	a0,-64(s0)
    8000461c:	06054063          	bltz	a0,8000467c <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004620:	4691                	li	a3,4
    80004622:	fc440613          	addi	a2,s0,-60
    80004626:	fd843583          	ld	a1,-40(s0)
    8000462a:	68a8                	ld	a0,80(s1)
    8000462c:	bb2fc0ef          	jal	ra,800009de <copyout>
    80004630:	00054e63          	bltz	a0,8000464c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004634:	4691                	li	a3,4
    80004636:	fc040613          	addi	a2,s0,-64
    8000463a:	fd843583          	ld	a1,-40(s0)
    8000463e:	0591                	addi	a1,a1,4
    80004640:	68a8                	ld	a0,80(s1)
    80004642:	b9cfc0ef          	jal	ra,800009de <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004646:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004648:	04055c63          	bgez	a0,800046a0 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000464c:	fc442783          	lw	a5,-60(s0)
    80004650:	07e9                	addi	a5,a5,26
    80004652:	078e                	slli	a5,a5,0x3
    80004654:	97a6                	add	a5,a5,s1
    80004656:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000465a:	fc042783          	lw	a5,-64(s0)
    8000465e:	07e9                	addi	a5,a5,26
    80004660:	078e                	slli	a5,a5,0x3
    80004662:	94be                	add	s1,s1,a5
    80004664:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80004668:	fd043503          	ld	a0,-48(s0)
    8000466c:	d89fe0ef          	jal	ra,800033f4 <fileclose>
    fileclose(wf);
    80004670:	fc843503          	ld	a0,-56(s0)
    80004674:	d81fe0ef          	jal	ra,800033f4 <fileclose>
    return -1;
    80004678:	57fd                	li	a5,-1
    8000467a:	a01d                	j	800046a0 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000467c:	fc442783          	lw	a5,-60(s0)
    80004680:	0007c763          	bltz	a5,8000468e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80004684:	07e9                	addi	a5,a5,26
    80004686:	078e                	slli	a5,a5,0x3
    80004688:	97a6                	add	a5,a5,s1
    8000468a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000468e:	fd043503          	ld	a0,-48(s0)
    80004692:	d63fe0ef          	jal	ra,800033f4 <fileclose>
    fileclose(wf);
    80004696:	fc843503          	ld	a0,-56(s0)
    8000469a:	d5bfe0ef          	jal	ra,800033f4 <fileclose>
    return -1;
    8000469e:	57fd                	li	a5,-1
}
    800046a0:	853e                	mv	a0,a5
    800046a2:	70e2                	ld	ra,56(sp)
    800046a4:	7442                	ld	s0,48(sp)
    800046a6:	74a2                	ld	s1,40(sp)
    800046a8:	6121                	addi	sp,sp,64
    800046aa:	8082                	ret
    800046ac:	0000                	unimp
	...

00000000800046b0 <kernelvec>:
    800046b0:	7111                	addi	sp,sp,-256
    800046b2:	e006                	sd	ra,0(sp)
    800046b4:	e40a                	sd	sp,8(sp)
    800046b6:	e80e                	sd	gp,16(sp)
    800046b8:	ec12                	sd	tp,24(sp)
    800046ba:	f016                	sd	t0,32(sp)
    800046bc:	f41a                	sd	t1,40(sp)
    800046be:	f81e                	sd	t2,48(sp)
    800046c0:	e4aa                	sd	a0,72(sp)
    800046c2:	e8ae                	sd	a1,80(sp)
    800046c4:	ecb2                	sd	a2,88(sp)
    800046c6:	f0b6                	sd	a3,96(sp)
    800046c8:	f4ba                	sd	a4,104(sp)
    800046ca:	f8be                	sd	a5,112(sp)
    800046cc:	fcc2                	sd	a6,120(sp)
    800046ce:	e146                	sd	a7,128(sp)
    800046d0:	edf2                	sd	t3,216(sp)
    800046d2:	f1f6                	sd	t4,224(sp)
    800046d4:	f5fa                	sd	t5,232(sp)
    800046d6:	f9fe                	sd	t6,240(sp)
    800046d8:	c96fd0ef          	jal	ra,80001b6e <kerneltrap>
    800046dc:	6082                	ld	ra,0(sp)
    800046de:	6122                	ld	sp,8(sp)
    800046e0:	61c2                	ld	gp,16(sp)
    800046e2:	7282                	ld	t0,32(sp)
    800046e4:	7322                	ld	t1,40(sp)
    800046e6:	73c2                	ld	t2,48(sp)
    800046e8:	6526                	ld	a0,72(sp)
    800046ea:	65c6                	ld	a1,80(sp)
    800046ec:	6666                	ld	a2,88(sp)
    800046ee:	7686                	ld	a3,96(sp)
    800046f0:	7726                	ld	a4,104(sp)
    800046f2:	77c6                	ld	a5,112(sp)
    800046f4:	7866                	ld	a6,120(sp)
    800046f6:	688a                	ld	a7,128(sp)
    800046f8:	6e6e                	ld	t3,216(sp)
    800046fa:	7e8e                	ld	t4,224(sp)
    800046fc:	7f2e                	ld	t5,232(sp)
    800046fe:	7fce                	ld	t6,240(sp)
    80004700:	6111                	addi	sp,sp,256
    80004702:	10200073          	sret
	...

000000008000470e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000470e:	1141                	addi	sp,sp,-16
    80004710:	e422                	sd	s0,8(sp)
    80004712:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004714:	0c0007b7          	lui	a5,0xc000
    80004718:	4705                	li	a4,1
    8000471a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000471c:	c3d8                	sw	a4,4(a5)
}
    8000471e:	6422                	ld	s0,8(sp)
    80004720:	0141                	addi	sp,sp,16
    80004722:	8082                	ret

0000000080004724 <plicinithart>:

void
plicinithart(void)
{
    80004724:	1141                	addi	sp,sp,-16
    80004726:	e406                	sd	ra,8(sp)
    80004728:	e022                	sd	s0,0(sp)
    8000472a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000472c:	ee2fc0ef          	jal	ra,80000e0e <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004730:	0085171b          	slliw	a4,a0,0x8
    80004734:	0c0027b7          	lui	a5,0xc002
    80004738:	97ba                	add	a5,a5,a4
    8000473a:	40200713          	li	a4,1026
    8000473e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004742:	00d5151b          	slliw	a0,a0,0xd
    80004746:	0c2017b7          	lui	a5,0xc201
    8000474a:	97aa                	add	a5,a5,a0
    8000474c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80004750:	60a2                	ld	ra,8(sp)
    80004752:	6402                	ld	s0,0(sp)
    80004754:	0141                	addi	sp,sp,16
    80004756:	8082                	ret

0000000080004758 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80004758:	1141                	addi	sp,sp,-16
    8000475a:	e406                	sd	ra,8(sp)
    8000475c:	e022                	sd	s0,0(sp)
    8000475e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004760:	eaefc0ef          	jal	ra,80000e0e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80004764:	00d5151b          	slliw	a0,a0,0xd
    80004768:	0c2017b7          	lui	a5,0xc201
    8000476c:	97aa                	add	a5,a5,a0
  return irq;
}
    8000476e:	43c8                	lw	a0,4(a5)
    80004770:	60a2                	ld	ra,8(sp)
    80004772:	6402                	ld	s0,0(sp)
    80004774:	0141                	addi	sp,sp,16
    80004776:	8082                	ret

0000000080004778 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80004778:	1101                	addi	sp,sp,-32
    8000477a:	ec06                	sd	ra,24(sp)
    8000477c:	e822                	sd	s0,16(sp)
    8000477e:	e426                	sd	s1,8(sp)
    80004780:	1000                	addi	s0,sp,32
    80004782:	84aa                	mv	s1,a0
  int hart = cpuid();
    80004784:	e8afc0ef          	jal	ra,80000e0e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80004788:	00d5151b          	slliw	a0,a0,0xd
    8000478c:	0c2017b7          	lui	a5,0xc201
    80004790:	97aa                	add	a5,a5,a0
    80004792:	c3c4                	sw	s1,4(a5)
}
    80004794:	60e2                	ld	ra,24(sp)
    80004796:	6442                	ld	s0,16(sp)
    80004798:	64a2                	ld	s1,8(sp)
    8000479a:	6105                	addi	sp,sp,32
    8000479c:	8082                	ret

000000008000479e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000479e:	1141                	addi	sp,sp,-16
    800047a0:	e406                	sd	ra,8(sp)
    800047a2:	e022                	sd	s0,0(sp)
    800047a4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800047a6:	479d                	li	a5,7
    800047a8:	04a7ca63          	blt	a5,a0,800047fc <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800047ac:	00014797          	auipc	a5,0x14
    800047b0:	31478793          	addi	a5,a5,788 # 80018ac0 <disk>
    800047b4:	97aa                	add	a5,a5,a0
    800047b6:	0187c783          	lbu	a5,24(a5)
    800047ba:	e7b9                	bnez	a5,80004808 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800047bc:	00451693          	slli	a3,a0,0x4
    800047c0:	00014797          	auipc	a5,0x14
    800047c4:	30078793          	addi	a5,a5,768 # 80018ac0 <disk>
    800047c8:	6398                	ld	a4,0(a5)
    800047ca:	9736                	add	a4,a4,a3
    800047cc:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800047d0:	6398                	ld	a4,0(a5)
    800047d2:	9736                	add	a4,a4,a3
    800047d4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800047d8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800047dc:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800047e0:	97aa                	add	a5,a5,a0
    800047e2:	4705                	li	a4,1
    800047e4:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800047e8:	00014517          	auipc	a0,0x14
    800047ec:	2f050513          	addi	a0,a0,752 # 80018ad8 <disk+0x18>
    800047f0:	c63fc0ef          	jal	ra,80001452 <wakeup>
}
    800047f4:	60a2                	ld	ra,8(sp)
    800047f6:	6402                	ld	s0,0(sp)
    800047f8:	0141                	addi	sp,sp,16
    800047fa:	8082                	ret
    panic("free_desc 1");
    800047fc:	00003517          	auipc	a0,0x3
    80004800:	fbc50513          	addi	a0,a0,-68 # 800077b8 <syscalls+0x358>
    80004804:	3bf000ef          	jal	ra,800053c2 <panic>
    panic("free_desc 2");
    80004808:	00003517          	auipc	a0,0x3
    8000480c:	fc050513          	addi	a0,a0,-64 # 800077c8 <syscalls+0x368>
    80004810:	3b3000ef          	jal	ra,800053c2 <panic>

0000000080004814 <virtio_disk_init>:
{
    80004814:	1101                	addi	sp,sp,-32
    80004816:	ec06                	sd	ra,24(sp)
    80004818:	e822                	sd	s0,16(sp)
    8000481a:	e426                	sd	s1,8(sp)
    8000481c:	e04a                	sd	s2,0(sp)
    8000481e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004820:	00003597          	auipc	a1,0x3
    80004824:	fb858593          	addi	a1,a1,-72 # 800077d8 <syscalls+0x378>
    80004828:	00014517          	auipc	a0,0x14
    8000482c:	3c050513          	addi	a0,a0,960 # 80018be8 <disk+0x128>
    80004830:	623000ef          	jal	ra,80005652 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004834:	100017b7          	lui	a5,0x10001
    80004838:	4398                	lw	a4,0(a5)
    8000483a:	2701                	sext.w	a4,a4
    8000483c:	747277b7          	lui	a5,0x74727
    80004840:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004844:	12f71f63          	bne	a4,a5,80004982 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004848:	100017b7          	lui	a5,0x10001
    8000484c:	43dc                	lw	a5,4(a5)
    8000484e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004850:	4709                	li	a4,2
    80004852:	12e79863          	bne	a5,a4,80004982 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004856:	100017b7          	lui	a5,0x10001
    8000485a:	479c                	lw	a5,8(a5)
    8000485c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000485e:	12e79263          	bne	a5,a4,80004982 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80004862:	100017b7          	lui	a5,0x10001
    80004866:	47d8                	lw	a4,12(a5)
    80004868:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000486a:	554d47b7          	lui	a5,0x554d4
    8000486e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004872:	10f71863          	bne	a4,a5,80004982 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004876:	100017b7          	lui	a5,0x10001
    8000487a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000487e:	4705                	li	a4,1
    80004880:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004882:	470d                	li	a4,3
    80004884:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004886:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004888:	c7ffe6b7          	lui	a3,0xc7ffe
    8000488c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdda5f>
    80004890:	8f75                	and	a4,a4,a3
    80004892:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004894:	472d                	li	a4,11
    80004896:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80004898:	5bbc                	lw	a5,112(a5)
    8000489a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000489e:	8ba1                	andi	a5,a5,8
    800048a0:	0e078763          	beqz	a5,8000498e <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800048a4:	100017b7          	lui	a5,0x10001
    800048a8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800048ac:	43fc                	lw	a5,68(a5)
    800048ae:	2781                	sext.w	a5,a5
    800048b0:	0e079563          	bnez	a5,8000499a <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800048b4:	100017b7          	lui	a5,0x10001
    800048b8:	5bdc                	lw	a5,52(a5)
    800048ba:	2781                	sext.w	a5,a5
  if(max == 0)
    800048bc:	0e078563          	beqz	a5,800049a6 <virtio_disk_init+0x192>
  if(max < NUM)
    800048c0:	471d                	li	a4,7
    800048c2:	0ef77863          	bgeu	a4,a5,800049b2 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    800048c6:	839fb0ef          	jal	ra,800000fe <kalloc>
    800048ca:	00014497          	auipc	s1,0x14
    800048ce:	1f648493          	addi	s1,s1,502 # 80018ac0 <disk>
    800048d2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800048d4:	82bfb0ef          	jal	ra,800000fe <kalloc>
    800048d8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800048da:	825fb0ef          	jal	ra,800000fe <kalloc>
    800048de:	87aa                	mv	a5,a0
    800048e0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800048e2:	6088                	ld	a0,0(s1)
    800048e4:	cd69                	beqz	a0,800049be <virtio_disk_init+0x1aa>
    800048e6:	00014717          	auipc	a4,0x14
    800048ea:	1e273703          	ld	a4,482(a4) # 80018ac8 <disk+0x8>
    800048ee:	cb61                	beqz	a4,800049be <virtio_disk_init+0x1aa>
    800048f0:	c7f9                	beqz	a5,800049be <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    800048f2:	6605                	lui	a2,0x1
    800048f4:	4581                	li	a1,0
    800048f6:	859fb0ef          	jal	ra,8000014e <memset>
  memset(disk.avail, 0, PGSIZE);
    800048fa:	00014497          	auipc	s1,0x14
    800048fe:	1c648493          	addi	s1,s1,454 # 80018ac0 <disk>
    80004902:	6605                	lui	a2,0x1
    80004904:	4581                	li	a1,0
    80004906:	6488                	ld	a0,8(s1)
    80004908:	847fb0ef          	jal	ra,8000014e <memset>
  memset(disk.used, 0, PGSIZE);
    8000490c:	6605                	lui	a2,0x1
    8000490e:	4581                	li	a1,0
    80004910:	6888                	ld	a0,16(s1)
    80004912:	83dfb0ef          	jal	ra,8000014e <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004916:	100017b7          	lui	a5,0x10001
    8000491a:	4721                	li	a4,8
    8000491c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000491e:	4098                	lw	a4,0(s1)
    80004920:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004924:	40d8                	lw	a4,4(s1)
    80004926:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000492a:	6498                	ld	a4,8(s1)
    8000492c:	0007069b          	sext.w	a3,a4
    80004930:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004934:	9701                	srai	a4,a4,0x20
    80004936:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000493a:	6898                	ld	a4,16(s1)
    8000493c:	0007069b          	sext.w	a3,a4
    80004940:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004944:	9701                	srai	a4,a4,0x20
    80004946:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000494a:	4705                	li	a4,1
    8000494c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000494e:	00e48c23          	sb	a4,24(s1)
    80004952:	00e48ca3          	sb	a4,25(s1)
    80004956:	00e48d23          	sb	a4,26(s1)
    8000495a:	00e48da3          	sb	a4,27(s1)
    8000495e:	00e48e23          	sb	a4,28(s1)
    80004962:	00e48ea3          	sb	a4,29(s1)
    80004966:	00e48f23          	sb	a4,30(s1)
    8000496a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000496e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004972:	0727a823          	sw	s2,112(a5)
}
    80004976:	60e2                	ld	ra,24(sp)
    80004978:	6442                	ld	s0,16(sp)
    8000497a:	64a2                	ld	s1,8(sp)
    8000497c:	6902                	ld	s2,0(sp)
    8000497e:	6105                	addi	sp,sp,32
    80004980:	8082                	ret
    panic("could not find virtio disk");
    80004982:	00003517          	auipc	a0,0x3
    80004986:	e6650513          	addi	a0,a0,-410 # 800077e8 <syscalls+0x388>
    8000498a:	239000ef          	jal	ra,800053c2 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000498e:	00003517          	auipc	a0,0x3
    80004992:	e7a50513          	addi	a0,a0,-390 # 80007808 <syscalls+0x3a8>
    80004996:	22d000ef          	jal	ra,800053c2 <panic>
    panic("virtio disk should not be ready");
    8000499a:	00003517          	auipc	a0,0x3
    8000499e:	e8e50513          	addi	a0,a0,-370 # 80007828 <syscalls+0x3c8>
    800049a2:	221000ef          	jal	ra,800053c2 <panic>
    panic("virtio disk has no queue 0");
    800049a6:	00003517          	auipc	a0,0x3
    800049aa:	ea250513          	addi	a0,a0,-350 # 80007848 <syscalls+0x3e8>
    800049ae:	215000ef          	jal	ra,800053c2 <panic>
    panic("virtio disk max queue too short");
    800049b2:	00003517          	auipc	a0,0x3
    800049b6:	eb650513          	addi	a0,a0,-330 # 80007868 <syscalls+0x408>
    800049ba:	209000ef          	jal	ra,800053c2 <panic>
    panic("virtio disk kalloc");
    800049be:	00003517          	auipc	a0,0x3
    800049c2:	eca50513          	addi	a0,a0,-310 # 80007888 <syscalls+0x428>
    800049c6:	1fd000ef          	jal	ra,800053c2 <panic>

00000000800049ca <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800049ca:	7119                	addi	sp,sp,-128
    800049cc:	fc86                	sd	ra,120(sp)
    800049ce:	f8a2                	sd	s0,112(sp)
    800049d0:	f4a6                	sd	s1,104(sp)
    800049d2:	f0ca                	sd	s2,96(sp)
    800049d4:	ecce                	sd	s3,88(sp)
    800049d6:	e8d2                	sd	s4,80(sp)
    800049d8:	e4d6                	sd	s5,72(sp)
    800049da:	e0da                	sd	s6,64(sp)
    800049dc:	fc5e                	sd	s7,56(sp)
    800049de:	f862                	sd	s8,48(sp)
    800049e0:	f466                	sd	s9,40(sp)
    800049e2:	f06a                	sd	s10,32(sp)
    800049e4:	ec6e                	sd	s11,24(sp)
    800049e6:	0100                	addi	s0,sp,128
    800049e8:	8aaa                	mv	s5,a0
    800049ea:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800049ec:	00c52d03          	lw	s10,12(a0)
    800049f0:	001d1d1b          	slliw	s10,s10,0x1
    800049f4:	1d02                	slli	s10,s10,0x20
    800049f6:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800049fa:	00014517          	auipc	a0,0x14
    800049fe:	1ee50513          	addi	a0,a0,494 # 80018be8 <disk+0x128>
    80004a02:	4d1000ef          	jal	ra,800056d2 <acquire>
  for(int i = 0; i < 3; i++){
    80004a06:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004a08:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004a0a:	00014b97          	auipc	s7,0x14
    80004a0e:	0b6b8b93          	addi	s7,s7,182 # 80018ac0 <disk>
  for(int i = 0; i < 3; i++){
    80004a12:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004a14:	00014c97          	auipc	s9,0x14
    80004a18:	1d4c8c93          	addi	s9,s9,468 # 80018be8 <disk+0x128>
    80004a1c:	a8a9                	j	80004a76 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004a1e:	00fb8733          	add	a4,s7,a5
    80004a22:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80004a26:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004a28:	0207c563          	bltz	a5,80004a52 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80004a2c:	2905                	addiw	s2,s2,1
    80004a2e:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004a30:	05690863          	beq	s2,s6,80004a80 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80004a34:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004a36:	00014717          	auipc	a4,0x14
    80004a3a:	08a70713          	addi	a4,a4,138 # 80018ac0 <disk>
    80004a3e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004a40:	01874683          	lbu	a3,24(a4)
    80004a44:	fee9                	bnez	a3,80004a1e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80004a46:	2785                	addiw	a5,a5,1
    80004a48:	0705                	addi	a4,a4,1
    80004a4a:	fe979be3          	bne	a5,s1,80004a40 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80004a4e:	57fd                	li	a5,-1
    80004a50:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004a52:	01205b63          	blez	s2,80004a68 <virtio_disk_rw+0x9e>
    80004a56:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80004a58:	000a2503          	lw	a0,0(s4)
    80004a5c:	d43ff0ef          	jal	ra,8000479e <free_desc>
      for(int j = 0; j < i; j++)
    80004a60:	2d85                	addiw	s11,s11,1
    80004a62:	0a11                	addi	s4,s4,4
    80004a64:	ff2d9ae3          	bne	s11,s2,80004a58 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004a68:	85e6                	mv	a1,s9
    80004a6a:	00014517          	auipc	a0,0x14
    80004a6e:	06e50513          	addi	a0,a0,110 # 80018ad8 <disk+0x18>
    80004a72:	995fc0ef          	jal	ra,80001406 <sleep>
  for(int i = 0; i < 3; i++){
    80004a76:	f8040a13          	addi	s4,s0,-128
{
    80004a7a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80004a7c:	894e                	mv	s2,s3
    80004a7e:	bf5d                	j	80004a34 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004a80:	f8042503          	lw	a0,-128(s0)
    80004a84:	00a50713          	addi	a4,a0,10
    80004a88:	0712                	slli	a4,a4,0x4

  if(write)
    80004a8a:	00014797          	auipc	a5,0x14
    80004a8e:	03678793          	addi	a5,a5,54 # 80018ac0 <disk>
    80004a92:	00e786b3          	add	a3,a5,a4
    80004a96:	01803633          	snez	a2,s8
    80004a9a:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004a9c:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80004aa0:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004aa4:	f6070613          	addi	a2,a4,-160
    80004aa8:	6394                	ld	a3,0(a5)
    80004aaa:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004aac:	00870593          	addi	a1,a4,8
    80004ab0:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004ab2:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004ab4:	0007b803          	ld	a6,0(a5)
    80004ab8:	9642                	add	a2,a2,a6
    80004aba:	46c1                	li	a3,16
    80004abc:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004abe:	4585                	li	a1,1
    80004ac0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80004ac4:	f8442683          	lw	a3,-124(s0)
    80004ac8:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004acc:	0692                	slli	a3,a3,0x4
    80004ace:	9836                	add	a6,a6,a3
    80004ad0:	058a8613          	addi	a2,s5,88
    80004ad4:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80004ad8:	0007b803          	ld	a6,0(a5)
    80004adc:	96c2                	add	a3,a3,a6
    80004ade:	40000613          	li	a2,1024
    80004ae2:	c690                	sw	a2,8(a3)
  if(write)
    80004ae4:	001c3613          	seqz	a2,s8
    80004ae8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004aec:	00166613          	ori	a2,a2,1
    80004af0:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80004af4:	f8842603          	lw	a2,-120(s0)
    80004af8:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004afc:	00250693          	addi	a3,a0,2
    80004b00:	0692                	slli	a3,a3,0x4
    80004b02:	96be                	add	a3,a3,a5
    80004b04:	58fd                	li	a7,-1
    80004b06:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004b0a:	0612                	slli	a2,a2,0x4
    80004b0c:	9832                	add	a6,a6,a2
    80004b0e:	f9070713          	addi	a4,a4,-112
    80004b12:	973e                	add	a4,a4,a5
    80004b14:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80004b18:	6398                	ld	a4,0(a5)
    80004b1a:	9732                	add	a4,a4,a2
    80004b1c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004b1e:	4609                	li	a2,2
    80004b20:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80004b24:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004b28:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80004b2c:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004b30:	6794                	ld	a3,8(a5)
    80004b32:	0026d703          	lhu	a4,2(a3)
    80004b36:	8b1d                	andi	a4,a4,7
    80004b38:	0706                	slli	a4,a4,0x1
    80004b3a:	96ba                	add	a3,a3,a4
    80004b3c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004b40:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004b44:	6798                	ld	a4,8(a5)
    80004b46:	00275783          	lhu	a5,2(a4)
    80004b4a:	2785                	addiw	a5,a5,1
    80004b4c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004b50:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004b54:	100017b7          	lui	a5,0x10001
    80004b58:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004b5c:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80004b60:	00014917          	auipc	s2,0x14
    80004b64:	08890913          	addi	s2,s2,136 # 80018be8 <disk+0x128>
  while(b->disk == 1) {
    80004b68:	4485                	li	s1,1
    80004b6a:	00b79a63          	bne	a5,a1,80004b7e <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80004b6e:	85ca                	mv	a1,s2
    80004b70:	8556                	mv	a0,s5
    80004b72:	895fc0ef          	jal	ra,80001406 <sleep>
  while(b->disk == 1) {
    80004b76:	004aa783          	lw	a5,4(s5)
    80004b7a:	fe978ae3          	beq	a5,s1,80004b6e <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80004b7e:	f8042903          	lw	s2,-128(s0)
    80004b82:	00290713          	addi	a4,s2,2
    80004b86:	0712                	slli	a4,a4,0x4
    80004b88:	00014797          	auipc	a5,0x14
    80004b8c:	f3878793          	addi	a5,a5,-200 # 80018ac0 <disk>
    80004b90:	97ba                	add	a5,a5,a4
    80004b92:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004b96:	00014997          	auipc	s3,0x14
    80004b9a:	f2a98993          	addi	s3,s3,-214 # 80018ac0 <disk>
    80004b9e:	00491713          	slli	a4,s2,0x4
    80004ba2:	0009b783          	ld	a5,0(s3)
    80004ba6:	97ba                	add	a5,a5,a4
    80004ba8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004bac:	854a                	mv	a0,s2
    80004bae:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004bb2:	bedff0ef          	jal	ra,8000479e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004bb6:	8885                	andi	s1,s1,1
    80004bb8:	f0fd                	bnez	s1,80004b9e <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004bba:	00014517          	auipc	a0,0x14
    80004bbe:	02e50513          	addi	a0,a0,46 # 80018be8 <disk+0x128>
    80004bc2:	3a9000ef          	jal	ra,8000576a <release>
}
    80004bc6:	70e6                	ld	ra,120(sp)
    80004bc8:	7446                	ld	s0,112(sp)
    80004bca:	74a6                	ld	s1,104(sp)
    80004bcc:	7906                	ld	s2,96(sp)
    80004bce:	69e6                	ld	s3,88(sp)
    80004bd0:	6a46                	ld	s4,80(sp)
    80004bd2:	6aa6                	ld	s5,72(sp)
    80004bd4:	6b06                	ld	s6,64(sp)
    80004bd6:	7be2                	ld	s7,56(sp)
    80004bd8:	7c42                	ld	s8,48(sp)
    80004bda:	7ca2                	ld	s9,40(sp)
    80004bdc:	7d02                	ld	s10,32(sp)
    80004bde:	6de2                	ld	s11,24(sp)
    80004be0:	6109                	addi	sp,sp,128
    80004be2:	8082                	ret

0000000080004be4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004be4:	1101                	addi	sp,sp,-32
    80004be6:	ec06                	sd	ra,24(sp)
    80004be8:	e822                	sd	s0,16(sp)
    80004bea:	e426                	sd	s1,8(sp)
    80004bec:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004bee:	00014497          	auipc	s1,0x14
    80004bf2:	ed248493          	addi	s1,s1,-302 # 80018ac0 <disk>
    80004bf6:	00014517          	auipc	a0,0x14
    80004bfa:	ff250513          	addi	a0,a0,-14 # 80018be8 <disk+0x128>
    80004bfe:	2d5000ef          	jal	ra,800056d2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004c02:	10001737          	lui	a4,0x10001
    80004c06:	533c                	lw	a5,96(a4)
    80004c08:	8b8d                	andi	a5,a5,3
    80004c0a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80004c0c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004c10:	689c                	ld	a5,16(s1)
    80004c12:	0204d703          	lhu	a4,32(s1)
    80004c16:	0027d783          	lhu	a5,2(a5)
    80004c1a:	04f70663          	beq	a4,a5,80004c66 <virtio_disk_intr+0x82>
    __sync_synchronize();
    80004c1e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004c22:	6898                	ld	a4,16(s1)
    80004c24:	0204d783          	lhu	a5,32(s1)
    80004c28:	8b9d                	andi	a5,a5,7
    80004c2a:	078e                	slli	a5,a5,0x3
    80004c2c:	97ba                	add	a5,a5,a4
    80004c2e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004c30:	00278713          	addi	a4,a5,2
    80004c34:	0712                	slli	a4,a4,0x4
    80004c36:	9726                	add	a4,a4,s1
    80004c38:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80004c3c:	e321                	bnez	a4,80004c7c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004c3e:	0789                	addi	a5,a5,2
    80004c40:	0792                	slli	a5,a5,0x4
    80004c42:	97a6                	add	a5,a5,s1
    80004c44:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004c46:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004c4a:	809fc0ef          	jal	ra,80001452 <wakeup>

    disk.used_idx += 1;
    80004c4e:	0204d783          	lhu	a5,32(s1)
    80004c52:	2785                	addiw	a5,a5,1
    80004c54:	17c2                	slli	a5,a5,0x30
    80004c56:	93c1                	srli	a5,a5,0x30
    80004c58:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004c5c:	6898                	ld	a4,16(s1)
    80004c5e:	00275703          	lhu	a4,2(a4)
    80004c62:	faf71ee3          	bne	a4,a5,80004c1e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80004c66:	00014517          	auipc	a0,0x14
    80004c6a:	f8250513          	addi	a0,a0,-126 # 80018be8 <disk+0x128>
    80004c6e:	2fd000ef          	jal	ra,8000576a <release>
}
    80004c72:	60e2                	ld	ra,24(sp)
    80004c74:	6442                	ld	s0,16(sp)
    80004c76:	64a2                	ld	s1,8(sp)
    80004c78:	6105                	addi	sp,sp,32
    80004c7a:	8082                	ret
      panic("virtio_disk_intr status");
    80004c7c:	00003517          	auipc	a0,0x3
    80004c80:	c2450513          	addi	a0,a0,-988 # 800078a0 <syscalls+0x440>
    80004c84:	73e000ef          	jal	ra,800053c2 <panic>

0000000080004c88 <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004c88:	1141                	addi	sp,sp,-16
    80004c8a:	e422                	sd	s0,8(sp)
    80004c8c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004c8e:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004c92:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004c96:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004c9a:	30a027f3          	csrr	a5,0x30a

  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63));
    80004c9e:	577d                	li	a4,-1
    80004ca0:	177e                	slli	a4,a4,0x3f
    80004ca2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004ca4:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004ca8:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004cac:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004cb0:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004cb4:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004cb8:	000f4737          	lui	a4,0xf4
    80004cbc:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004cc0:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004cc2:	14d79073          	csrw	0x14d,a5
}
    80004cc6:	6422                	ld	s0,8(sp)
    80004cc8:	0141                	addi	sp,sp,16
    80004cca:	8082                	ret

0000000080004ccc <start>:
{
    80004ccc:	1141                	addi	sp,sp,-16
    80004cce:	e406                	sd	ra,8(sp)
    80004cd0:	e022                	sd	s0,0(sp)
    80004cd2:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004cd4:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004cd8:	7779                	lui	a4,0xffffe
    80004cda:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddaff>
    80004cde:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004ce0:	6705                	lui	a4,0x1
    80004ce2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004ce6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004ce8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004cec:	ffffb797          	auipc	a5,0xffffb
    80004cf0:	60478793          	addi	a5,a5,1540 # 800002f0 <main>
    80004cf4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004cf8:	4781                	li	a5,0
    80004cfa:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004cfe:	67c1                	lui	a5,0x10
    80004d00:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004d02:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004d06:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004d0a:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004d0e:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004d12:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004d16:	57fd                	li	a5,-1
    80004d18:	83a9                	srli	a5,a5,0xa
    80004d1a:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004d1e:	47bd                	li	a5,15
    80004d20:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004d24:	f65ff0ef          	jal	ra,80004c88 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004d28:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004d2c:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004d2e:	823e                	mv	tp,a5
  asm volatile("mret");
    80004d30:	30200073          	mret
}
    80004d34:	60a2                	ld	ra,8(sp)
    80004d36:	6402                	ld	s0,0(sp)
    80004d38:	0141                	addi	sp,sp,16
    80004d3a:	8082                	ret

0000000080004d3c <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004d3c:	715d                	addi	sp,sp,-80
    80004d3e:	e486                	sd	ra,72(sp)
    80004d40:	e0a2                	sd	s0,64(sp)
    80004d42:	fc26                	sd	s1,56(sp)
    80004d44:	f84a                	sd	s2,48(sp)
    80004d46:	f44e                	sd	s3,40(sp)
    80004d48:	f052                	sd	s4,32(sp)
    80004d4a:	ec56                	sd	s5,24(sp)
    80004d4c:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004d4e:	04c05363          	blez	a2,80004d94 <consolewrite+0x58>
    80004d52:	8a2a                	mv	s4,a0
    80004d54:	84ae                	mv	s1,a1
    80004d56:	89b2                	mv	s3,a2
    80004d58:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80004d5a:	5afd                	li	s5,-1
    80004d5c:	4685                	li	a3,1
    80004d5e:	8626                	mv	a2,s1
    80004d60:	85d2                	mv	a1,s4
    80004d62:	fbf40513          	addi	a0,s0,-65
    80004d66:	a47fc0ef          	jal	ra,800017ac <either_copyin>
    80004d6a:	01550b63          	beq	a0,s5,80004d80 <consolewrite+0x44>
      break;
    uartputc(c);
    80004d6e:	fbf44503          	lbu	a0,-65(s0)
    80004d72:	7da000ef          	jal	ra,8000554c <uartputc>
  for(i = 0; i < n; i++){
    80004d76:	2905                	addiw	s2,s2,1
    80004d78:	0485                	addi	s1,s1,1
    80004d7a:	ff2991e3          	bne	s3,s2,80004d5c <consolewrite+0x20>
    80004d7e:	894e                	mv	s2,s3
  }

  return i;
}
    80004d80:	854a                	mv	a0,s2
    80004d82:	60a6                	ld	ra,72(sp)
    80004d84:	6406                	ld	s0,64(sp)
    80004d86:	74e2                	ld	s1,56(sp)
    80004d88:	7942                	ld	s2,48(sp)
    80004d8a:	79a2                	ld	s3,40(sp)
    80004d8c:	7a02                	ld	s4,32(sp)
    80004d8e:	6ae2                	ld	s5,24(sp)
    80004d90:	6161                	addi	sp,sp,80
    80004d92:	8082                	ret
  for(i = 0; i < n; i++){
    80004d94:	4901                	li	s2,0
    80004d96:	b7ed                	j	80004d80 <consolewrite+0x44>

0000000080004d98 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80004d98:	7159                	addi	sp,sp,-112
    80004d9a:	f486                	sd	ra,104(sp)
    80004d9c:	f0a2                	sd	s0,96(sp)
    80004d9e:	eca6                	sd	s1,88(sp)
    80004da0:	e8ca                	sd	s2,80(sp)
    80004da2:	e4ce                	sd	s3,72(sp)
    80004da4:	e0d2                	sd	s4,64(sp)
    80004da6:	fc56                	sd	s5,56(sp)
    80004da8:	f85a                	sd	s6,48(sp)
    80004daa:	f45e                	sd	s7,40(sp)
    80004dac:	f062                	sd	s8,32(sp)
    80004dae:	ec66                	sd	s9,24(sp)
    80004db0:	e86a                	sd	s10,16(sp)
    80004db2:	1880                	addi	s0,sp,112
    80004db4:	8aaa                	mv	s5,a0
    80004db6:	8a2e                	mv	s4,a1
    80004db8:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80004dba:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80004dbe:	0001c517          	auipc	a0,0x1c
    80004dc2:	e4250513          	addi	a0,a0,-446 # 80020c00 <cons>
    80004dc6:	10d000ef          	jal	ra,800056d2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80004dca:	0001c497          	auipc	s1,0x1c
    80004dce:	e3648493          	addi	s1,s1,-458 # 80020c00 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80004dd2:	0001c917          	auipc	s2,0x1c
    80004dd6:	ec690913          	addi	s2,s2,-314 # 80020c98 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80004dda:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004ddc:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80004dde:	4ca9                	li	s9,10
  while(n > 0){
    80004de0:	07305363          	blez	s3,80004e46 <consoleread+0xae>
    while(cons.r == cons.w){
    80004de4:	0984a783          	lw	a5,152(s1)
    80004de8:	09c4a703          	lw	a4,156(s1)
    80004dec:	02f71163          	bne	a4,a5,80004e0e <consoleread+0x76>
      if(killed(myproc())){
    80004df0:	84afc0ef          	jal	ra,80000e3a <myproc>
    80004df4:	84bfc0ef          	jal	ra,8000163e <killed>
    80004df8:	e125                	bnez	a0,80004e58 <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    80004dfa:	85a6                	mv	a1,s1
    80004dfc:	854a                	mv	a0,s2
    80004dfe:	e08fc0ef          	jal	ra,80001406 <sleep>
    while(cons.r == cons.w){
    80004e02:	0984a783          	lw	a5,152(s1)
    80004e06:	09c4a703          	lw	a4,156(s1)
    80004e0a:	fef703e3          	beq	a4,a5,80004df0 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80004e0e:	0017871b          	addiw	a4,a5,1
    80004e12:	08e4ac23          	sw	a4,152(s1)
    80004e16:	07f7f713          	andi	a4,a5,127
    80004e1a:	9726                	add	a4,a4,s1
    80004e1c:	01874703          	lbu	a4,24(a4)
    80004e20:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80004e24:	057d0f63          	beq	s10,s7,80004e82 <consoleread+0xea>
    cbuf = c;
    80004e28:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004e2c:	4685                	li	a3,1
    80004e2e:	f9f40613          	addi	a2,s0,-97
    80004e32:	85d2                	mv	a1,s4
    80004e34:	8556                	mv	a0,s5
    80004e36:	92dfc0ef          	jal	ra,80001762 <either_copyout>
    80004e3a:	01850663          	beq	a0,s8,80004e46 <consoleread+0xae>
    dst++;
    80004e3e:	0a05                	addi	s4,s4,1
    --n;
    80004e40:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80004e42:	f99d1fe3          	bne	s10,s9,80004de0 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80004e46:	0001c517          	auipc	a0,0x1c
    80004e4a:	dba50513          	addi	a0,a0,-582 # 80020c00 <cons>
    80004e4e:	11d000ef          	jal	ra,8000576a <release>

  return target - n;
    80004e52:	413b053b          	subw	a0,s6,s3
    80004e56:	a801                	j	80004e66 <consoleread+0xce>
        release(&cons.lock);
    80004e58:	0001c517          	auipc	a0,0x1c
    80004e5c:	da850513          	addi	a0,a0,-600 # 80020c00 <cons>
    80004e60:	10b000ef          	jal	ra,8000576a <release>
        return -1;
    80004e64:	557d                	li	a0,-1
}
    80004e66:	70a6                	ld	ra,104(sp)
    80004e68:	7406                	ld	s0,96(sp)
    80004e6a:	64e6                	ld	s1,88(sp)
    80004e6c:	6946                	ld	s2,80(sp)
    80004e6e:	69a6                	ld	s3,72(sp)
    80004e70:	6a06                	ld	s4,64(sp)
    80004e72:	7ae2                	ld	s5,56(sp)
    80004e74:	7b42                	ld	s6,48(sp)
    80004e76:	7ba2                	ld	s7,40(sp)
    80004e78:	7c02                	ld	s8,32(sp)
    80004e7a:	6ce2                	ld	s9,24(sp)
    80004e7c:	6d42                	ld	s10,16(sp)
    80004e7e:	6165                	addi	sp,sp,112
    80004e80:	8082                	ret
      if(n < target){
    80004e82:	0009871b          	sext.w	a4,s3
    80004e86:	fd6770e3          	bgeu	a4,s6,80004e46 <consoleread+0xae>
        cons.r--;
    80004e8a:	0001c717          	auipc	a4,0x1c
    80004e8e:	e0f72723          	sw	a5,-498(a4) # 80020c98 <cons+0x98>
    80004e92:	bf55                	j	80004e46 <consoleread+0xae>

0000000080004e94 <consputc>:
{
    80004e94:	1141                	addi	sp,sp,-16
    80004e96:	e406                	sd	ra,8(sp)
    80004e98:	e022                	sd	s0,0(sp)
    80004e9a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80004e9c:	10000793          	li	a5,256
    80004ea0:	00f50863          	beq	a0,a5,80004eb0 <consputc+0x1c>
    uartputc_sync(c);
    80004ea4:	5d2000ef          	jal	ra,80005476 <uartputc_sync>
}
    80004ea8:	60a2                	ld	ra,8(sp)
    80004eaa:	6402                	ld	s0,0(sp)
    80004eac:	0141                	addi	sp,sp,16
    80004eae:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80004eb0:	4521                	li	a0,8
    80004eb2:	5c4000ef          	jal	ra,80005476 <uartputc_sync>
    80004eb6:	02000513          	li	a0,32
    80004eba:	5bc000ef          	jal	ra,80005476 <uartputc_sync>
    80004ebe:	4521                	li	a0,8
    80004ec0:	5b6000ef          	jal	ra,80005476 <uartputc_sync>
    80004ec4:	b7d5                	j	80004ea8 <consputc+0x14>

0000000080004ec6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80004ec6:	1101                	addi	sp,sp,-32
    80004ec8:	ec06                	sd	ra,24(sp)
    80004eca:	e822                	sd	s0,16(sp)
    80004ecc:	e426                	sd	s1,8(sp)
    80004ece:	e04a                	sd	s2,0(sp)
    80004ed0:	1000                	addi	s0,sp,32
    80004ed2:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80004ed4:	0001c517          	auipc	a0,0x1c
    80004ed8:	d2c50513          	addi	a0,a0,-724 # 80020c00 <cons>
    80004edc:	7f6000ef          	jal	ra,800056d2 <acquire>

  switch(c){
    80004ee0:	47d5                	li	a5,21
    80004ee2:	0af48063          	beq	s1,a5,80004f82 <consoleintr+0xbc>
    80004ee6:	0297c663          	blt	a5,s1,80004f12 <consoleintr+0x4c>
    80004eea:	47a1                	li	a5,8
    80004eec:	0cf48f63          	beq	s1,a5,80004fca <consoleintr+0x104>
    80004ef0:	47c1                	li	a5,16
    80004ef2:	10f49063          	bne	s1,a5,80004ff2 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    80004ef6:	901fc0ef          	jal	ra,800017f6 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    80004efa:	0001c517          	auipc	a0,0x1c
    80004efe:	d0650513          	addi	a0,a0,-762 # 80020c00 <cons>
    80004f02:	069000ef          	jal	ra,8000576a <release>
}
    80004f06:	60e2                	ld	ra,24(sp)
    80004f08:	6442                	ld	s0,16(sp)
    80004f0a:	64a2                	ld	s1,8(sp)
    80004f0c:	6902                	ld	s2,0(sp)
    80004f0e:	6105                	addi	sp,sp,32
    80004f10:	8082                	ret
  switch(c){
    80004f12:	07f00793          	li	a5,127
    80004f16:	0af48a63          	beq	s1,a5,80004fca <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80004f1a:	0001c717          	auipc	a4,0x1c
    80004f1e:	ce670713          	addi	a4,a4,-794 # 80020c00 <cons>
    80004f22:	0a072783          	lw	a5,160(a4)
    80004f26:	09872703          	lw	a4,152(a4)
    80004f2a:	9f99                	subw	a5,a5,a4
    80004f2c:	07f00713          	li	a4,127
    80004f30:	fcf765e3          	bltu	a4,a5,80004efa <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    80004f34:	47b5                	li	a5,13
    80004f36:	0cf48163          	beq	s1,a5,80004ff8 <consoleintr+0x132>
      consputc(c);
    80004f3a:	8526                	mv	a0,s1
    80004f3c:	f59ff0ef          	jal	ra,80004e94 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80004f40:	0001c797          	auipc	a5,0x1c
    80004f44:	cc078793          	addi	a5,a5,-832 # 80020c00 <cons>
    80004f48:	0a07a683          	lw	a3,160(a5)
    80004f4c:	0016871b          	addiw	a4,a3,1
    80004f50:	0007061b          	sext.w	a2,a4
    80004f54:	0ae7a023          	sw	a4,160(a5)
    80004f58:	07f6f693          	andi	a3,a3,127
    80004f5c:	97b6                	add	a5,a5,a3
    80004f5e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80004f62:	47a9                	li	a5,10
    80004f64:	0af48f63          	beq	s1,a5,80005022 <consoleintr+0x15c>
    80004f68:	4791                	li	a5,4
    80004f6a:	0af48c63          	beq	s1,a5,80005022 <consoleintr+0x15c>
    80004f6e:	0001c797          	auipc	a5,0x1c
    80004f72:	d2a7a783          	lw	a5,-726(a5) # 80020c98 <cons+0x98>
    80004f76:	9f1d                	subw	a4,a4,a5
    80004f78:	08000793          	li	a5,128
    80004f7c:	f6f71fe3          	bne	a4,a5,80004efa <consoleintr+0x34>
    80004f80:	a04d                	j	80005022 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80004f82:	0001c717          	auipc	a4,0x1c
    80004f86:	c7e70713          	addi	a4,a4,-898 # 80020c00 <cons>
    80004f8a:	0a072783          	lw	a5,160(a4)
    80004f8e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80004f92:	0001c497          	auipc	s1,0x1c
    80004f96:	c6e48493          	addi	s1,s1,-914 # 80020c00 <cons>
    while(cons.e != cons.w &&
    80004f9a:	4929                	li	s2,10
    80004f9c:	f4f70fe3          	beq	a4,a5,80004efa <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80004fa0:	37fd                	addiw	a5,a5,-1
    80004fa2:	07f7f713          	andi	a4,a5,127
    80004fa6:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80004fa8:	01874703          	lbu	a4,24(a4)
    80004fac:	f52707e3          	beq	a4,s2,80004efa <consoleintr+0x34>
      cons.e--;
    80004fb0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80004fb4:	10000513          	li	a0,256
    80004fb8:	eddff0ef          	jal	ra,80004e94 <consputc>
    while(cons.e != cons.w &&
    80004fbc:	0a04a783          	lw	a5,160(s1)
    80004fc0:	09c4a703          	lw	a4,156(s1)
    80004fc4:	fcf71ee3          	bne	a4,a5,80004fa0 <consoleintr+0xda>
    80004fc8:	bf0d                	j	80004efa <consoleintr+0x34>
    if(cons.e != cons.w){
    80004fca:	0001c717          	auipc	a4,0x1c
    80004fce:	c3670713          	addi	a4,a4,-970 # 80020c00 <cons>
    80004fd2:	0a072783          	lw	a5,160(a4)
    80004fd6:	09c72703          	lw	a4,156(a4)
    80004fda:	f2f700e3          	beq	a4,a5,80004efa <consoleintr+0x34>
      cons.e--;
    80004fde:	37fd                	addiw	a5,a5,-1
    80004fe0:	0001c717          	auipc	a4,0x1c
    80004fe4:	ccf72023          	sw	a5,-832(a4) # 80020ca0 <cons+0xa0>
      consputc(BACKSPACE);
    80004fe8:	10000513          	li	a0,256
    80004fec:	ea9ff0ef          	jal	ra,80004e94 <consputc>
    80004ff0:	b729                	j	80004efa <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80004ff2:	f00484e3          	beqz	s1,80004efa <consoleintr+0x34>
    80004ff6:	b715                	j	80004f1a <consoleintr+0x54>
      consputc(c);
    80004ff8:	4529                	li	a0,10
    80004ffa:	e9bff0ef          	jal	ra,80004e94 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80004ffe:	0001c797          	auipc	a5,0x1c
    80005002:	c0278793          	addi	a5,a5,-1022 # 80020c00 <cons>
    80005006:	0a07a703          	lw	a4,160(a5)
    8000500a:	0017069b          	addiw	a3,a4,1
    8000500e:	0006861b          	sext.w	a2,a3
    80005012:	0ad7a023          	sw	a3,160(a5)
    80005016:	07f77713          	andi	a4,a4,127
    8000501a:	97ba                	add	a5,a5,a4
    8000501c:	4729                	li	a4,10
    8000501e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005022:	0001c797          	auipc	a5,0x1c
    80005026:	c6c7ad23          	sw	a2,-902(a5) # 80020c9c <cons+0x9c>
        wakeup(&cons.r);
    8000502a:	0001c517          	auipc	a0,0x1c
    8000502e:	c6e50513          	addi	a0,a0,-914 # 80020c98 <cons+0x98>
    80005032:	c20fc0ef          	jal	ra,80001452 <wakeup>
    80005036:	b5d1                	j	80004efa <consoleintr+0x34>

0000000080005038 <consoleinit>:

void
consoleinit(void)
{
    80005038:	1141                	addi	sp,sp,-16
    8000503a:	e406                	sd	ra,8(sp)
    8000503c:	e022                	sd	s0,0(sp)
    8000503e:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005040:	00003597          	auipc	a1,0x3
    80005044:	87858593          	addi	a1,a1,-1928 # 800078b8 <syscalls+0x458>
    80005048:	0001c517          	auipc	a0,0x1c
    8000504c:	bb850513          	addi	a0,a0,-1096 # 80020c00 <cons>
    80005050:	602000ef          	jal	ra,80005652 <initlock>

  uartinit();
    80005054:	3d6000ef          	jal	ra,8000542a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005058:	00013797          	auipc	a5,0x13
    8000505c:	a1078793          	addi	a5,a5,-1520 # 80017a68 <devsw>
    80005060:	00000717          	auipc	a4,0x0
    80005064:	d3870713          	addi	a4,a4,-712 # 80004d98 <consoleread>
    80005068:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000506a:	00000717          	auipc	a4,0x0
    8000506e:	cd270713          	addi	a4,a4,-814 # 80004d3c <consolewrite>
    80005072:	ef98                	sd	a4,24(a5)
}
    80005074:	60a2                	ld	ra,8(sp)
    80005076:	6402                	ld	s0,0(sp)
    80005078:	0141                	addi	sp,sp,16
    8000507a:	8082                	ret

000000008000507c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000507c:	7179                	addi	sp,sp,-48
    8000507e:	f406                	sd	ra,40(sp)
    80005080:	f022                	sd	s0,32(sp)
    80005082:	ec26                	sd	s1,24(sp)
    80005084:	e84a                	sd	s2,16(sp)
    80005086:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80005088:	c219                	beqz	a2,8000508e <printint+0x12>
    8000508a:	06054e63          	bltz	a0,80005106 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000508e:	4881                	li	a7,0
    80005090:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005094:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80005096:	00003617          	auipc	a2,0x3
    8000509a:	84a60613          	addi	a2,a2,-1974 # 800078e0 <digits>
    8000509e:	883e                	mv	a6,a5
    800050a0:	2785                	addiw	a5,a5,1
    800050a2:	02b57733          	remu	a4,a0,a1
    800050a6:	9732                	add	a4,a4,a2
    800050a8:	00074703          	lbu	a4,0(a4)
    800050ac:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    800050b0:	872a                	mv	a4,a0
    800050b2:	02b55533          	divu	a0,a0,a1
    800050b6:	0685                	addi	a3,a3,1
    800050b8:	feb773e3          	bgeu	a4,a1,8000509e <printint+0x22>

  if(sign)
    800050bc:	00088a63          	beqz	a7,800050d0 <printint+0x54>
    buf[i++] = '-';
    800050c0:	1781                	addi	a5,a5,-32
    800050c2:	97a2                	add	a5,a5,s0
    800050c4:	02d00713          	li	a4,45
    800050c8:	fee78823          	sb	a4,-16(a5)
    800050cc:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800050d0:	02f05563          	blez	a5,800050fa <printint+0x7e>
    800050d4:	fd040713          	addi	a4,s0,-48
    800050d8:	00f704b3          	add	s1,a4,a5
    800050dc:	fff70913          	addi	s2,a4,-1
    800050e0:	993e                	add	s2,s2,a5
    800050e2:	37fd                	addiw	a5,a5,-1
    800050e4:	1782                	slli	a5,a5,0x20
    800050e6:	9381                	srli	a5,a5,0x20
    800050e8:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800050ec:	fff4c503          	lbu	a0,-1(s1)
    800050f0:	da5ff0ef          	jal	ra,80004e94 <consputc>
  while(--i >= 0)
    800050f4:	14fd                	addi	s1,s1,-1
    800050f6:	ff249be3          	bne	s1,s2,800050ec <printint+0x70>
}
    800050fa:	70a2                	ld	ra,40(sp)
    800050fc:	7402                	ld	s0,32(sp)
    800050fe:	64e2                	ld	s1,24(sp)
    80005100:	6942                	ld	s2,16(sp)
    80005102:	6145                	addi	sp,sp,48
    80005104:	8082                	ret
    x = -xx;
    80005106:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    8000510a:	4885                	li	a7,1
    x = -xx;
    8000510c:	b751                	j	80005090 <printint+0x14>

000000008000510e <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    8000510e:	7155                	addi	sp,sp,-208
    80005110:	e506                	sd	ra,136(sp)
    80005112:	e122                	sd	s0,128(sp)
    80005114:	fca6                	sd	s1,120(sp)
    80005116:	f8ca                	sd	s2,112(sp)
    80005118:	f4ce                	sd	s3,104(sp)
    8000511a:	f0d2                	sd	s4,96(sp)
    8000511c:	ecd6                	sd	s5,88(sp)
    8000511e:	e8da                	sd	s6,80(sp)
    80005120:	e4de                	sd	s7,72(sp)
    80005122:	e0e2                	sd	s8,64(sp)
    80005124:	fc66                	sd	s9,56(sp)
    80005126:	f86a                	sd	s10,48(sp)
    80005128:	f46e                	sd	s11,40(sp)
    8000512a:	0900                	addi	s0,sp,144
    8000512c:	8a2a                	mv	s4,a0
    8000512e:	e40c                	sd	a1,8(s0)
    80005130:	e810                	sd	a2,16(s0)
    80005132:	ec14                	sd	a3,24(s0)
    80005134:	f018                	sd	a4,32(s0)
    80005136:	f41c                	sd	a5,40(s0)
    80005138:	03043823          	sd	a6,48(s0)
    8000513c:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    80005140:	0001c797          	auipc	a5,0x1c
    80005144:	b807a783          	lw	a5,-1152(a5) # 80020cc0 <pr+0x18>
    80005148:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    8000514c:	eb9d                	bnez	a5,80005182 <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    8000514e:	00840793          	addi	a5,s0,8
    80005152:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005156:	00054503          	lbu	a0,0(a0)
    8000515a:	24050463          	beqz	a0,800053a2 <printf+0x294>
    8000515e:	4981                	li	s3,0
    if(cx != '%'){
    80005160:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005164:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80005168:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000516c:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005170:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005174:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005178:	00002b97          	auipc	s7,0x2
    8000517c:	768b8b93          	addi	s7,s7,1896 # 800078e0 <digits>
    80005180:	a081                	j	800051c0 <printf+0xb2>
    acquire(&pr.lock);
    80005182:	0001c517          	auipc	a0,0x1c
    80005186:	b2650513          	addi	a0,a0,-1242 # 80020ca8 <pr>
    8000518a:	548000ef          	jal	ra,800056d2 <acquire>
  va_start(ap, fmt);
    8000518e:	00840793          	addi	a5,s0,8
    80005192:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005196:	000a4503          	lbu	a0,0(s4)
    8000519a:	f171                	bnez	a0,8000515e <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    8000519c:	0001c517          	auipc	a0,0x1c
    800051a0:	b0c50513          	addi	a0,a0,-1268 # 80020ca8 <pr>
    800051a4:	5c6000ef          	jal	ra,8000576a <release>
    800051a8:	aaed                	j	800053a2 <printf+0x294>
      consputc(cx);
    800051aa:	cebff0ef          	jal	ra,80004e94 <consputc>
      continue;
    800051ae:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800051b0:	0014899b          	addiw	s3,s1,1
    800051b4:	013a07b3          	add	a5,s4,s3
    800051b8:	0007c503          	lbu	a0,0(a5)
    800051bc:	1c050f63          	beqz	a0,8000539a <printf+0x28c>
    if(cx != '%'){
    800051c0:	ff5515e3          	bne	a0,s5,800051aa <printf+0x9c>
    i++;
    800051c4:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    800051c8:	009a07b3          	add	a5,s4,s1
    800051cc:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    800051d0:	1c090563          	beqz	s2,8000539a <printf+0x28c>
    800051d4:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800051d8:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    800051da:	c789                	beqz	a5,800051e4 <printf+0xd6>
    800051dc:	009a0733          	add	a4,s4,s1
    800051e0:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800051e4:	03690463          	beq	s2,s6,8000520c <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    800051e8:	03890e63          	beq	s2,s8,80005224 <printf+0x116>
    } else if(c0 == 'u'){
    800051ec:	0b990d63          	beq	s2,s9,800052a6 <printf+0x198>
    } else if(c0 == 'x'){
    800051f0:	11a90363          	beq	s2,s10,800052f6 <printf+0x1e8>
    } else if(c0 == 'p'){
    800051f4:	13b90b63          	beq	s2,s11,8000532a <printf+0x21c>
    } else if(c0 == 's'){
    800051f8:	07300793          	li	a5,115
    800051fc:	16f90363          	beq	s2,a5,80005362 <printf+0x254>
    } else if(c0 == '%'){
    80005200:	03591c63          	bne	s2,s5,80005238 <printf+0x12a>
      consputc('%');
    80005204:	8556                	mv	a0,s5
    80005206:	c8fff0ef          	jal	ra,80004e94 <consputc>
    8000520a:	b75d                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    8000520c:	f8843783          	ld	a5,-120(s0)
    80005210:	00878713          	addi	a4,a5,8
    80005214:	f8e43423          	sd	a4,-120(s0)
    80005218:	4605                	li	a2,1
    8000521a:	45a9                	li	a1,10
    8000521c:	4388                	lw	a0,0(a5)
    8000521e:	e5fff0ef          	jal	ra,8000507c <printint>
    80005222:	b779                	j	800051b0 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    80005224:	03678163          	beq	a5,s6,80005246 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80005228:	03878d63          	beq	a5,s8,80005262 <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    8000522c:	09978963          	beq	a5,s9,800052be <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005230:	03878b63          	beq	a5,s8,80005266 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    80005234:	0da78d63          	beq	a5,s10,8000530e <printf+0x200>
      consputc('%');
    80005238:	8556                	mv	a0,s5
    8000523a:	c5bff0ef          	jal	ra,80004e94 <consputc>
      consputc(c0);
    8000523e:	854a                	mv	a0,s2
    80005240:	c55ff0ef          	jal	ra,80004e94 <consputc>
    80005244:	b7b5                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    80005246:	f8843783          	ld	a5,-120(s0)
    8000524a:	00878713          	addi	a4,a5,8
    8000524e:	f8e43423          	sd	a4,-120(s0)
    80005252:	4605                	li	a2,1
    80005254:	45a9                	li	a1,10
    80005256:	6388                	ld	a0,0(a5)
    80005258:	e25ff0ef          	jal	ra,8000507c <printint>
      i += 1;
    8000525c:	0029849b          	addiw	s1,s3,2
    80005260:	bf81                	j	800051b0 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80005262:	03668463          	beq	a3,s6,8000528a <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005266:	07968a63          	beq	a3,s9,800052da <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000526a:	fda697e3          	bne	a3,s10,80005238 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    8000526e:	f8843783          	ld	a5,-120(s0)
    80005272:	00878713          	addi	a4,a5,8
    80005276:	f8e43423          	sd	a4,-120(s0)
    8000527a:	4601                	li	a2,0
    8000527c:	45c1                	li	a1,16
    8000527e:	6388                	ld	a0,0(a5)
    80005280:	dfdff0ef          	jal	ra,8000507c <printint>
      i += 2;
    80005284:	0039849b          	addiw	s1,s3,3
    80005288:	b725                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    8000528a:	f8843783          	ld	a5,-120(s0)
    8000528e:	00878713          	addi	a4,a5,8
    80005292:	f8e43423          	sd	a4,-120(s0)
    80005296:	4605                	li	a2,1
    80005298:	45a9                	li	a1,10
    8000529a:	6388                	ld	a0,0(a5)
    8000529c:	de1ff0ef          	jal	ra,8000507c <printint>
      i += 2;
    800052a0:	0039849b          	addiw	s1,s3,3
    800052a4:	b731                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    800052a6:	f8843783          	ld	a5,-120(s0)
    800052aa:	00878713          	addi	a4,a5,8
    800052ae:	f8e43423          	sd	a4,-120(s0)
    800052b2:	4601                	li	a2,0
    800052b4:	45a9                	li	a1,10
    800052b6:	4388                	lw	a0,0(a5)
    800052b8:	dc5ff0ef          	jal	ra,8000507c <printint>
    800052bc:	bdd5                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    800052be:	f8843783          	ld	a5,-120(s0)
    800052c2:	00878713          	addi	a4,a5,8
    800052c6:	f8e43423          	sd	a4,-120(s0)
    800052ca:	4601                	li	a2,0
    800052cc:	45a9                	li	a1,10
    800052ce:	6388                	ld	a0,0(a5)
    800052d0:	dadff0ef          	jal	ra,8000507c <printint>
      i += 1;
    800052d4:	0029849b          	addiw	s1,s3,2
    800052d8:	bde1                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    800052da:	f8843783          	ld	a5,-120(s0)
    800052de:	00878713          	addi	a4,a5,8
    800052e2:	f8e43423          	sd	a4,-120(s0)
    800052e6:	4601                	li	a2,0
    800052e8:	45a9                	li	a1,10
    800052ea:	6388                	ld	a0,0(a5)
    800052ec:	d91ff0ef          	jal	ra,8000507c <printint>
      i += 2;
    800052f0:	0039849b          	addiw	s1,s3,3
    800052f4:	bd75                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    800052f6:	f8843783          	ld	a5,-120(s0)
    800052fa:	00878713          	addi	a4,a5,8
    800052fe:	f8e43423          	sd	a4,-120(s0)
    80005302:	4601                	li	a2,0
    80005304:	45c1                	li	a1,16
    80005306:	4388                	lw	a0,0(a5)
    80005308:	d75ff0ef          	jal	ra,8000507c <printint>
    8000530c:	b555                	j	800051b0 <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    8000530e:	f8843783          	ld	a5,-120(s0)
    80005312:	00878713          	addi	a4,a5,8
    80005316:	f8e43423          	sd	a4,-120(s0)
    8000531a:	4601                	li	a2,0
    8000531c:	45c1                	li	a1,16
    8000531e:	6388                	ld	a0,0(a5)
    80005320:	d5dff0ef          	jal	ra,8000507c <printint>
      i += 1;
    80005324:	0029849b          	addiw	s1,s3,2
    80005328:	b561                	j	800051b0 <printf+0xa2>
      printptr(va_arg(ap, uint64));
    8000532a:	f8843783          	ld	a5,-120(s0)
    8000532e:	00878713          	addi	a4,a5,8
    80005332:	f8e43423          	sd	a4,-120(s0)
    80005336:	0007b983          	ld	s3,0(a5)
  consputc('0');
    8000533a:	03000513          	li	a0,48
    8000533e:	b57ff0ef          	jal	ra,80004e94 <consputc>
  consputc('x');
    80005342:	856a                	mv	a0,s10
    80005344:	b51ff0ef          	jal	ra,80004e94 <consputc>
    80005348:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000534a:	03c9d793          	srli	a5,s3,0x3c
    8000534e:	97de                	add	a5,a5,s7
    80005350:	0007c503          	lbu	a0,0(a5)
    80005354:	b41ff0ef          	jal	ra,80004e94 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005358:	0992                	slli	s3,s3,0x4
    8000535a:	397d                	addiw	s2,s2,-1
    8000535c:	fe0917e3          	bnez	s2,8000534a <printf+0x23c>
    80005360:	bd81                	j	800051b0 <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    80005362:	f8843783          	ld	a5,-120(s0)
    80005366:	00878713          	addi	a4,a5,8
    8000536a:	f8e43423          	sd	a4,-120(s0)
    8000536e:	0007b903          	ld	s2,0(a5)
    80005372:	00090d63          	beqz	s2,8000538c <printf+0x27e>
      for(; *s; s++)
    80005376:	00094503          	lbu	a0,0(s2)
    8000537a:	e2050be3          	beqz	a0,800051b0 <printf+0xa2>
        consputc(*s);
    8000537e:	b17ff0ef          	jal	ra,80004e94 <consputc>
      for(; *s; s++)
    80005382:	0905                	addi	s2,s2,1
    80005384:	00094503          	lbu	a0,0(s2)
    80005388:	f97d                	bnez	a0,8000537e <printf+0x270>
    8000538a:	b51d                	j	800051b0 <printf+0xa2>
        s = "(null)";
    8000538c:	00002917          	auipc	s2,0x2
    80005390:	53490913          	addi	s2,s2,1332 # 800078c0 <syscalls+0x460>
      for(; *s; s++)
    80005394:	02800513          	li	a0,40
    80005398:	b7dd                	j	8000537e <printf+0x270>
  if(locking)
    8000539a:	f7843783          	ld	a5,-136(s0)
    8000539e:	de079fe3          	bnez	a5,8000519c <printf+0x8e>

  return 0;
}
    800053a2:	4501                	li	a0,0
    800053a4:	60aa                	ld	ra,136(sp)
    800053a6:	640a                	ld	s0,128(sp)
    800053a8:	74e6                	ld	s1,120(sp)
    800053aa:	7946                	ld	s2,112(sp)
    800053ac:	79a6                	ld	s3,104(sp)
    800053ae:	7a06                	ld	s4,96(sp)
    800053b0:	6ae6                	ld	s5,88(sp)
    800053b2:	6b46                	ld	s6,80(sp)
    800053b4:	6ba6                	ld	s7,72(sp)
    800053b6:	6c06                	ld	s8,64(sp)
    800053b8:	7ce2                	ld	s9,56(sp)
    800053ba:	7d42                	ld	s10,48(sp)
    800053bc:	7da2                	ld	s11,40(sp)
    800053be:	6169                	addi	sp,sp,208
    800053c0:	8082                	ret

00000000800053c2 <panic>:

void
panic(char *s)
{
    800053c2:	1101                	addi	sp,sp,-32
    800053c4:	ec06                	sd	ra,24(sp)
    800053c6:	e822                	sd	s0,16(sp)
    800053c8:	e426                	sd	s1,8(sp)
    800053ca:	1000                	addi	s0,sp,32
    800053cc:	84aa                	mv	s1,a0
  pr.locking = 0;
    800053ce:	0001c797          	auipc	a5,0x1c
    800053d2:	8e07a923          	sw	zero,-1806(a5) # 80020cc0 <pr+0x18>
  printf("panic: ");
    800053d6:	00002517          	auipc	a0,0x2
    800053da:	4f250513          	addi	a0,a0,1266 # 800078c8 <syscalls+0x468>
    800053de:	d31ff0ef          	jal	ra,8000510e <printf>
  printf("%s\n", s);
    800053e2:	85a6                	mv	a1,s1
    800053e4:	00002517          	auipc	a0,0x2
    800053e8:	4ec50513          	addi	a0,a0,1260 # 800078d0 <syscalls+0x470>
    800053ec:	d23ff0ef          	jal	ra,8000510e <printf>
  panicked = 1; // freeze uart output from other CPUs
    800053f0:	4785                	li	a5,1
    800053f2:	00002717          	auipc	a4,0x2
    800053f6:	5cf72523          	sw	a5,1482(a4) # 800079bc <panicked>
  for(;;)
    800053fa:	a001                	j	800053fa <panic+0x38>

00000000800053fc <printfinit>:
    ;
}

void
printfinit(void)
{
    800053fc:	1101                	addi	sp,sp,-32
    800053fe:	ec06                	sd	ra,24(sp)
    80005400:	e822                	sd	s0,16(sp)
    80005402:	e426                	sd	s1,8(sp)
    80005404:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005406:	0001c497          	auipc	s1,0x1c
    8000540a:	8a248493          	addi	s1,s1,-1886 # 80020ca8 <pr>
    8000540e:	00002597          	auipc	a1,0x2
    80005412:	4ca58593          	addi	a1,a1,1226 # 800078d8 <syscalls+0x478>
    80005416:	8526                	mv	a0,s1
    80005418:	23a000ef          	jal	ra,80005652 <initlock>
  pr.locking = 1;
    8000541c:	4785                	li	a5,1
    8000541e:	cc9c                	sw	a5,24(s1)
}
    80005420:	60e2                	ld	ra,24(sp)
    80005422:	6442                	ld	s0,16(sp)
    80005424:	64a2                	ld	s1,8(sp)
    80005426:	6105                	addi	sp,sp,32
    80005428:	8082                	ret

000000008000542a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000542a:	1141                	addi	sp,sp,-16
    8000542c:	e406                	sd	ra,8(sp)
    8000542e:	e022                	sd	s0,0(sp)
    80005430:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005432:	100007b7          	lui	a5,0x10000
    80005436:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000543a:	f8000713          	li	a4,-128
    8000543e:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005442:	470d                	li	a4,3
    80005444:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005448:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000544c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005450:	469d                	li	a3,7
    80005452:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005456:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000545a:	00002597          	auipc	a1,0x2
    8000545e:	49e58593          	addi	a1,a1,1182 # 800078f8 <digits+0x18>
    80005462:	0001c517          	auipc	a0,0x1c
    80005466:	86650513          	addi	a0,a0,-1946 # 80020cc8 <uart_tx_lock>
    8000546a:	1e8000ef          	jal	ra,80005652 <initlock>
}
    8000546e:	60a2                	ld	ra,8(sp)
    80005470:	6402                	ld	s0,0(sp)
    80005472:	0141                	addi	sp,sp,16
    80005474:	8082                	ret

0000000080005476 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005476:	1101                	addi	sp,sp,-32
    80005478:	ec06                	sd	ra,24(sp)
    8000547a:	e822                	sd	s0,16(sp)
    8000547c:	e426                	sd	s1,8(sp)
    8000547e:	1000                	addi	s0,sp,32
    80005480:	84aa                	mv	s1,a0
  push_off();
    80005482:	210000ef          	jal	ra,80005692 <push_off>

  if(panicked){
    80005486:	00002797          	auipc	a5,0x2
    8000548a:	5367a783          	lw	a5,1334(a5) # 800079bc <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000548e:	10000737          	lui	a4,0x10000
  if(panicked){
    80005492:	c391                	beqz	a5,80005496 <uartputc_sync+0x20>
    for(;;)
    80005494:	a001                	j	80005494 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005496:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000549a:	0207f793          	andi	a5,a5,32
    8000549e:	dfe5                	beqz	a5,80005496 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    800054a0:	0ff4f513          	zext.b	a0,s1
    800054a4:	100007b7          	lui	a5,0x10000
    800054a8:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    800054ac:	26a000ef          	jal	ra,80005716 <pop_off>
}
    800054b0:	60e2                	ld	ra,24(sp)
    800054b2:	6442                	ld	s0,16(sp)
    800054b4:	64a2                	ld	s1,8(sp)
    800054b6:	6105                	addi	sp,sp,32
    800054b8:	8082                	ret

00000000800054ba <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800054ba:	00002797          	auipc	a5,0x2
    800054be:	5067b783          	ld	a5,1286(a5) # 800079c0 <uart_tx_r>
    800054c2:	00002717          	auipc	a4,0x2
    800054c6:	50673703          	ld	a4,1286(a4) # 800079c8 <uart_tx_w>
    800054ca:	06f70c63          	beq	a4,a5,80005542 <uartstart+0x88>
{
    800054ce:	7139                	addi	sp,sp,-64
    800054d0:	fc06                	sd	ra,56(sp)
    800054d2:	f822                	sd	s0,48(sp)
    800054d4:	f426                	sd	s1,40(sp)
    800054d6:	f04a                	sd	s2,32(sp)
    800054d8:	ec4e                	sd	s3,24(sp)
    800054da:	e852                	sd	s4,16(sp)
    800054dc:	e456                	sd	s5,8(sp)
    800054de:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }

    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800054e0:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }

    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800054e4:	0001ba17          	auipc	s4,0x1b
    800054e8:	7e4a0a13          	addi	s4,s4,2020 # 80020cc8 <uart_tx_lock>
    uart_tx_r += 1;
    800054ec:	00002497          	auipc	s1,0x2
    800054f0:	4d448493          	addi	s1,s1,1236 # 800079c0 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800054f4:	00002997          	auipc	s3,0x2
    800054f8:	4d498993          	addi	s3,s3,1236 # 800079c8 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800054fc:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80005500:	02077713          	andi	a4,a4,32
    80005504:	c715                	beqz	a4,80005530 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005506:	01f7f713          	andi	a4,a5,31
    8000550a:	9752                	add	a4,a4,s4
    8000550c:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80005510:	0785                	addi	a5,a5,1
    80005512:	e09c                	sd	a5,0(s1)

    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80005514:	8526                	mv	a0,s1
    80005516:	f3dfb0ef          	jal	ra,80001452 <wakeup>

    WriteReg(THR, c);
    8000551a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000551e:	609c                	ld	a5,0(s1)
    80005520:	0009b703          	ld	a4,0(s3)
    80005524:	fcf71ce3          	bne	a4,a5,800054fc <uartstart+0x42>
      ReadReg(ISR);
    80005528:	100007b7          	lui	a5,0x10000
    8000552c:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    80005530:	70e2                	ld	ra,56(sp)
    80005532:	7442                	ld	s0,48(sp)
    80005534:	74a2                	ld	s1,40(sp)
    80005536:	7902                	ld	s2,32(sp)
    80005538:	69e2                	ld	s3,24(sp)
    8000553a:	6a42                	ld	s4,16(sp)
    8000553c:	6aa2                	ld	s5,8(sp)
    8000553e:	6121                	addi	sp,sp,64
    80005540:	8082                	ret
      ReadReg(ISR);
    80005542:	100007b7          	lui	a5,0x10000
    80005546:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    8000554a:	8082                	ret

000000008000554c <uartputc>:
{
    8000554c:	7179                	addi	sp,sp,-48
    8000554e:	f406                	sd	ra,40(sp)
    80005550:	f022                	sd	s0,32(sp)
    80005552:	ec26                	sd	s1,24(sp)
    80005554:	e84a                	sd	s2,16(sp)
    80005556:	e44e                	sd	s3,8(sp)
    80005558:	e052                	sd	s4,0(sp)
    8000555a:	1800                	addi	s0,sp,48
    8000555c:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000555e:	0001b517          	auipc	a0,0x1b
    80005562:	76a50513          	addi	a0,a0,1898 # 80020cc8 <uart_tx_lock>
    80005566:	16c000ef          	jal	ra,800056d2 <acquire>
  if(panicked){
    8000556a:	00002797          	auipc	a5,0x2
    8000556e:	4527a783          	lw	a5,1106(a5) # 800079bc <panicked>
    80005572:	efbd                	bnez	a5,800055f0 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005574:	00002717          	auipc	a4,0x2
    80005578:	45473703          	ld	a4,1108(a4) # 800079c8 <uart_tx_w>
    8000557c:	00002797          	auipc	a5,0x2
    80005580:	4447b783          	ld	a5,1092(a5) # 800079c0 <uart_tx_r>
    80005584:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80005588:	0001b997          	auipc	s3,0x1b
    8000558c:	74098993          	addi	s3,s3,1856 # 80020cc8 <uart_tx_lock>
    80005590:	00002497          	auipc	s1,0x2
    80005594:	43048493          	addi	s1,s1,1072 # 800079c0 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005598:	00002917          	auipc	s2,0x2
    8000559c:	43090913          	addi	s2,s2,1072 # 800079c8 <uart_tx_w>
    800055a0:	00e79d63          	bne	a5,a4,800055ba <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    800055a4:	85ce                	mv	a1,s3
    800055a6:	8526                	mv	a0,s1
    800055a8:	e5ffb0ef          	jal	ra,80001406 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800055ac:	00093703          	ld	a4,0(s2)
    800055b0:	609c                	ld	a5,0(s1)
    800055b2:	02078793          	addi	a5,a5,32
    800055b6:	fee787e3          	beq	a5,a4,800055a4 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800055ba:	0001b497          	auipc	s1,0x1b
    800055be:	70e48493          	addi	s1,s1,1806 # 80020cc8 <uart_tx_lock>
    800055c2:	01f77793          	andi	a5,a4,31
    800055c6:	97a6                	add	a5,a5,s1
    800055c8:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800055cc:	0705                	addi	a4,a4,1
    800055ce:	00002797          	auipc	a5,0x2
    800055d2:	3ee7bd23          	sd	a4,1018(a5) # 800079c8 <uart_tx_w>
  uartstart();
    800055d6:	ee5ff0ef          	jal	ra,800054ba <uartstart>
  release(&uart_tx_lock);
    800055da:	8526                	mv	a0,s1
    800055dc:	18e000ef          	jal	ra,8000576a <release>
}
    800055e0:	70a2                	ld	ra,40(sp)
    800055e2:	7402                	ld	s0,32(sp)
    800055e4:	64e2                	ld	s1,24(sp)
    800055e6:	6942                	ld	s2,16(sp)
    800055e8:	69a2                	ld	s3,8(sp)
    800055ea:	6a02                	ld	s4,0(sp)
    800055ec:	6145                	addi	sp,sp,48
    800055ee:	8082                	ret
    for(;;)
    800055f0:	a001                	j	800055f0 <uartputc+0xa4>

00000000800055f2 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800055f2:	1141                	addi	sp,sp,-16
    800055f4:	e422                	sd	s0,8(sp)
    800055f6:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800055f8:	100007b7          	lui	a5,0x10000
    800055fc:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80005600:	8b85                	andi	a5,a5,1
    80005602:	cb81                	beqz	a5,80005612 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80005604:	100007b7          	lui	a5,0x10000
    80005608:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000560c:	6422                	ld	s0,8(sp)
    8000560e:	0141                	addi	sp,sp,16
    80005610:	8082                	ret
    return -1;
    80005612:	557d                	li	a0,-1
    80005614:	bfe5                	j	8000560c <uartgetc+0x1a>

0000000080005616 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80005616:	1101                	addi	sp,sp,-32
    80005618:	ec06                	sd	ra,24(sp)
    8000561a:	e822                	sd	s0,16(sp)
    8000561c:	e426                	sd	s1,8(sp)
    8000561e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80005620:	54fd                	li	s1,-1
    80005622:	a019                	j	80005628 <uartintr+0x12>
      break;
    consoleintr(c);
    80005624:	8a3ff0ef          	jal	ra,80004ec6 <consoleintr>
    int c = uartgetc();
    80005628:	fcbff0ef          	jal	ra,800055f2 <uartgetc>
    if(c == -1)
    8000562c:	fe951ce3          	bne	a0,s1,80005624 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80005630:	0001b497          	auipc	s1,0x1b
    80005634:	69848493          	addi	s1,s1,1688 # 80020cc8 <uart_tx_lock>
    80005638:	8526                	mv	a0,s1
    8000563a:	098000ef          	jal	ra,800056d2 <acquire>
  uartstart();
    8000563e:	e7dff0ef          	jal	ra,800054ba <uartstart>
  release(&uart_tx_lock);
    80005642:	8526                	mv	a0,s1
    80005644:	126000ef          	jal	ra,8000576a <release>
}
    80005648:	60e2                	ld	ra,24(sp)
    8000564a:	6442                	ld	s0,16(sp)
    8000564c:	64a2                	ld	s1,8(sp)
    8000564e:	6105                	addi	sp,sp,32
    80005650:	8082                	ret

0000000080005652 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005652:	1141                	addi	sp,sp,-16
    80005654:	e422                	sd	s0,8(sp)
    80005656:	0800                	addi	s0,sp,16
  lk->name = name;
    80005658:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    8000565a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000565e:	00053823          	sd	zero,16(a0)
}
    80005662:	6422                	ld	s0,8(sp)
    80005664:	0141                	addi	sp,sp,16
    80005666:	8082                	ret

0000000080005668 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005668:	411c                	lw	a5,0(a0)
    8000566a:	e399                	bnez	a5,80005670 <holding+0x8>
    8000566c:	4501                	li	a0,0
  return r;
}
    8000566e:	8082                	ret
{
    80005670:	1101                	addi	sp,sp,-32
    80005672:	ec06                	sd	ra,24(sp)
    80005674:	e822                	sd	s0,16(sp)
    80005676:	e426                	sd	s1,8(sp)
    80005678:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    8000567a:	6904                	ld	s1,16(a0)
    8000567c:	fa2fb0ef          	jal	ra,80000e1e <mycpu>
    80005680:	40a48533          	sub	a0,s1,a0
    80005684:	00153513          	seqz	a0,a0
}
    80005688:	60e2                	ld	ra,24(sp)
    8000568a:	6442                	ld	s0,16(sp)
    8000568c:	64a2                	ld	s1,8(sp)
    8000568e:	6105                	addi	sp,sp,32
    80005690:	8082                	ret

0000000080005692 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80005692:	1101                	addi	sp,sp,-32
    80005694:	ec06                	sd	ra,24(sp)
    80005696:	e822                	sd	s0,16(sp)
    80005698:	e426                	sd	s1,8(sp)
    8000569a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000569c:	100024f3          	csrr	s1,sstatus
    800056a0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800056a4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800056a6:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800056aa:	f74fb0ef          	jal	ra,80000e1e <mycpu>
    800056ae:	5d3c                	lw	a5,120(a0)
    800056b0:	cb99                	beqz	a5,800056c6 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800056b2:	f6cfb0ef          	jal	ra,80000e1e <mycpu>
    800056b6:	5d3c                	lw	a5,120(a0)
    800056b8:	2785                	addiw	a5,a5,1
    800056ba:	dd3c                	sw	a5,120(a0)
}
    800056bc:	60e2                	ld	ra,24(sp)
    800056be:	6442                	ld	s0,16(sp)
    800056c0:	64a2                	ld	s1,8(sp)
    800056c2:	6105                	addi	sp,sp,32
    800056c4:	8082                	ret
    mycpu()->intena = old;
    800056c6:	f58fb0ef          	jal	ra,80000e1e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800056ca:	8085                	srli	s1,s1,0x1
    800056cc:	8885                	andi	s1,s1,1
    800056ce:	dd64                	sw	s1,124(a0)
    800056d0:	b7cd                	j	800056b2 <push_off+0x20>

00000000800056d2 <acquire>:
{
    800056d2:	1101                	addi	sp,sp,-32
    800056d4:	ec06                	sd	ra,24(sp)
    800056d6:	e822                	sd	s0,16(sp)
    800056d8:	e426                	sd	s1,8(sp)
    800056da:	1000                	addi	s0,sp,32
    800056dc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800056de:	fb5ff0ef          	jal	ra,80005692 <push_off>
  if(holding(lk))
    800056e2:	8526                	mv	a0,s1
    800056e4:	f85ff0ef          	jal	ra,80005668 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800056e8:	4705                	li	a4,1
  if(holding(lk))
    800056ea:	e105                	bnez	a0,8000570a <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800056ec:	87ba                	mv	a5,a4
    800056ee:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800056f2:	2781                	sext.w	a5,a5
    800056f4:	ffe5                	bnez	a5,800056ec <acquire+0x1a>
  __sync_synchronize();
    800056f6:	0ff0000f          	fence
  lk->cpu = mycpu();
    800056fa:	f24fb0ef          	jal	ra,80000e1e <mycpu>
    800056fe:	e888                	sd	a0,16(s1)
}
    80005700:	60e2                	ld	ra,24(sp)
    80005702:	6442                	ld	s0,16(sp)
    80005704:	64a2                	ld	s1,8(sp)
    80005706:	6105                	addi	sp,sp,32
    80005708:	8082                	ret
    panic("acquire");
    8000570a:	00002517          	auipc	a0,0x2
    8000570e:	1f650513          	addi	a0,a0,502 # 80007900 <digits+0x20>
    80005712:	cb1ff0ef          	jal	ra,800053c2 <panic>

0000000080005716 <pop_off>:

void
pop_off(void)
{
    80005716:	1141                	addi	sp,sp,-16
    80005718:	e406                	sd	ra,8(sp)
    8000571a:	e022                	sd	s0,0(sp)
    8000571c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    8000571e:	f00fb0ef          	jal	ra,80000e1e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005722:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005726:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005728:	e78d                	bnez	a5,80005752 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    8000572a:	5d3c                	lw	a5,120(a0)
    8000572c:	02f05963          	blez	a5,8000575e <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80005730:	37fd                	addiw	a5,a5,-1
    80005732:	0007871b          	sext.w	a4,a5
    80005736:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005738:	eb09                	bnez	a4,8000574a <pop_off+0x34>
    8000573a:	5d7c                	lw	a5,124(a0)
    8000573c:	c799                	beqz	a5,8000574a <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000573e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005742:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005746:	10079073          	csrw	sstatus,a5
    intr_on();
}
    8000574a:	60a2                	ld	ra,8(sp)
    8000574c:	6402                	ld	s0,0(sp)
    8000574e:	0141                	addi	sp,sp,16
    80005750:	8082                	ret
    panic("pop_off - interruptible");
    80005752:	00002517          	auipc	a0,0x2
    80005756:	1b650513          	addi	a0,a0,438 # 80007908 <digits+0x28>
    8000575a:	c69ff0ef          	jal	ra,800053c2 <panic>
    panic("pop_off");
    8000575e:	00002517          	auipc	a0,0x2
    80005762:	1c250513          	addi	a0,a0,450 # 80007920 <digits+0x40>
    80005766:	c5dff0ef          	jal	ra,800053c2 <panic>

000000008000576a <release>:
{
    8000576a:	1101                	addi	sp,sp,-32
    8000576c:	ec06                	sd	ra,24(sp)
    8000576e:	e822                	sd	s0,16(sp)
    80005770:	e426                	sd	s1,8(sp)
    80005772:	1000                	addi	s0,sp,32
    80005774:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005776:	ef3ff0ef          	jal	ra,80005668 <holding>
    8000577a:	c105                	beqz	a0,8000579a <release+0x30>
  lk->cpu = 0;
    8000577c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005780:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80005784:	0f50000f          	fence	iorw,ow
    80005788:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    8000578c:	f8bff0ef          	jal	ra,80005716 <pop_off>
}
    80005790:	60e2                	ld	ra,24(sp)
    80005792:	6442                	ld	s0,16(sp)
    80005794:	64a2                	ld	s1,8(sp)
    80005796:	6105                	addi	sp,sp,32
    80005798:	8082                	ret
    panic("release");
    8000579a:	00002517          	auipc	a0,0x2
    8000579e:	18e50513          	addi	a0,a0,398 # 80007928 <digits+0x48>
    800057a2:	c21ff0ef          	jal	ra,800053c2 <panic>
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
