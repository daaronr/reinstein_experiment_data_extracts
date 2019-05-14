%Similarity data: quick stories

*Data input in ../inputbasicclean.do

(note, 8 observations missing because I was lazy and used cheap demo version of Stattransfer)

*ran a Prolific experiment/survey over the weekend involving charitable giving, working with Giving for Impact (Netherlands). This is not the survey we have been discussing but I think the results are also informative for our discussion
*I recruited a fairly general UK nonstudent pool, and the description did not emphasize charity, so it should not have particularly attracted altruists.

#Actual donations

##Choice where to donate £10 if win (they had a 1/20 chance of winning); donations matched at 25% rate

*Note: results are very similar if we remove the 8 entries started before the verification fix ('if afterfix')

> tab Ddon_amf_from10 Ddon_givedirect_from10

           | Ddon_givedirect_from10
Ddon_amf_  |
    from10 |         0          1 |     Total
-----------+----------------------+----------
         0 |        29          3 |        32
         1 |        16         69 |        85
-----------+----------------------+----------
     Total |        45         72 |       117


- note 72% committed to donate something (if they win)
- most people donated to *both*, although Anti-Malaria was slightly more popular

*...install univar

> univar donatedfrom10 don_amf_from10 don_givedirect_from10

                                        -------------- Quantiles --------------
Variable                    n       Mean     S.D.      Min      .25      Mdn      .75      Max
-----------------------------------------------------------------------------------------------
donatedfrom10               107     5.71     3.59     0.00     4.00     5.00    10.00    10.00
don_amf_from10              106     3.34     2.71     0.00     1.00     3.00     5.00    10.00
don_givedirect_from10       107     2.40     2.14     0.00     0.00     2.50     4.00    10.00


##Mandated donation of 50p, choice of charity

> tab Q39, sort

   Regardless of whether |
 you have won any bonus, |
   we are now giving you |
            50p to alloc |      Freq.     Percent        Cum.
-------------------------+-----------------------------------
      Cancer Research UK |         31       28.97       28.97
  Save the Children Fund |         14       13.08       42.06
             Diabetes UK |         11       10.28       52.34
                  unicef |         11       10.28       62.62
           Give Directly |          9        8.41       71.03
        Deworm the World |          9        8.41       79.44
         Against Malaria |          9        8.41       87.85
British Heart Foundation |          8        7.48       95.33
                   Oxfam |          5        4.67      100.00
-------------------------+-----------------------------------
                   Total |        107      100.00



#Most similar, distinct charities
> univar Q22_1 Q24_1 Q65_1 C3_1 C4_1 C5_1 C6_1 C7_1 C8_1 C9_1 C10_1 C11_1 C12_1 C13_1 C14_1 C15_1
> univar  C3_1	 C7_1	 C8_1	 C11_1	 C9_1	 C10_1	 C5_1	 C12_1	 C4_1	 C6_1	 Q22_1	 Q24_1	 C13_1	 Q65_1	 C14_1	 C15_1  if Dincentiverate==1
> *Note: further work done in comparingsimilaritystatstable.xlsx

*From least to most similar (assigning 1-4 to rankings, sorted by mean

Variable	Leftchar	rightchar	Mean	S.D.	Min	q25	Mdn	q75	Max
C3_1	        bhf	        oxfam	        1.2	0.58	1	1	1	1	4
C7_1	        cruk	        oxfam	        1.22	0.55	1	1	1	1	4
C8_1	        cruk	        stc	        1.23	0.56	1	1	1	1	4
C11_1	        diabetes	stc	        1.23	0.57	1	1	1	1	4
C9_1	        cruk	        unicef	        1.24	0.54	1	1	1	1	3
C10_1	        diabetes	oxfam	        1.25	0.61	1	1	1	1	4
C5_1	        bhf	        unicef	        1.26	0.65	1	1	1	1	4
C12_1	        diabetes	unicef	        1.27	0.66	1	1	1	1	4
C4_1	        bhf	        stc	        1.31	0.64	1	1	1	1	4
C6_1	        cruk	        diabetes	2.43	0.87	1	2	2	3	4
Q22_1	        cruk	        spleen	        2.49	0.91	1	1.5	3	3	4
Q24_1	        bhf	        diabetes	2.54	0.86	1	2	2.5	3	4
C13_1	        oxfam	        stc	        2.73	0.84	1	2	3	3	4
Q65_1	        bhf	        cruk	        2.75	0.94	1	2	3	3.5	4
C14_1	        oxfam	        unicef	        2.88	0.86	1	2	3	4	4
C15_1	        stc	        unicef	        3.63	0.64	1	3	4	4       4


***



